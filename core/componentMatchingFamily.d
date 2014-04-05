/**
 *
 * The default class for managing a NodeList. This class creates the NodeList and adds and removes
 * nodes to/from the list as the entities and the components in the engine change.
 * 
 * It uses the basic entity matching pattern of an entity system - entities are added to the list if
 * they contain components matching all the public properties of the node class.
 */
module ashd.core.componentMatchingFamily;

import ashd.core.component: Component;
import ashd.core.engine   : Engine;
import ashd.core.entity   : Entity;
import ashd.core.ifamily  : IFamily;
import ashd.core.node     : Node;
import ashd.core.nodelist : NodeList;
import ashd.core.nodepool : NodePool;


import std.conv   : to;
import std.traits : BaseClassesTuple, CommonType, FieldTypeTuple, isInstanceOf;



// The following templates taken from orange (Jacob Carlborg)
// https://github.com/jacob-carlborg/orange/blob/master/orange/util/Reflection.d

/**
 * Evaluates to an array of strings containing the names of the fields in the given type
 */
template fieldsOf (T)
{
    enum fieldsOf = fieldsOfImpl!(T, 0);
}

/**
 * Implementation for fieldsOf
 *
 * Returns: an array of strings containing the names of the fields in the given type
 */
template fieldsOfImpl (T, size_t i)
{
    static if (T.tupleof.length == 0)
        enum fieldsOfImpl = [""];

    else static if (T.tupleof.length - 1 == i)
        enum fieldsOfImpl = [nameOfFieldAt!(T, i)];

    else
        enum fieldsOfImpl = nameOfFieldAt!(T, i) ~ fieldsOfImpl!(T, i + 1);
}

/**
 * Evaluates to a string containing the name of the field at given position in the given type.
 *
 * Params:
 * T = the type of the class/struct
 * position = the position of the field in the tupleof array
 */
template nameOfFieldAt (T, size_t position)
{
    static assert (position < T.tupleof.length, format!(`The given position "`, position, `" is greater than the number of fields (`, T.tupleof.length, `) in the type "`, T, `"`));

    enum nameOfFieldAt = __traits(identifier, T.tupleof[position]);
}

// Default NodeList management class
public class ComponentMatchingFamily(Class): IFamily
{
    private
    {
        Node[Entity]      mEntities;
        string[ClassInfo] mComponents;
        Engine            mEngine;
        NodeList          mNodes;
        NodePool!Class    mNodePool;
    }


    /**
     * The constructor. Creates a ComponentMatchingFamily to provide a NodeList for the
     * given node class.
     * 
     * @param nodeClass The type of node to create and manage a NodeList for.
     * @param engine The engine that this family is managing teh NodeList for.
     */
    public this( Engine engine_a )
    {
        this.mEngine = engine_a;
        this.init();
    }


    // Helper to determine if child is child of parent
    private bool ChildInheritsFromParent( parent, child )( ) 
    {
        foreach ( k, t; BaseClassesTuple!child ) 
        {
            if( typeid(t) == typeid(parent) )
                return true;
        }
        return false;
    }

    /**
     * Initialises the class. Creates the nodelist and other tools. Analyses the node to determine
     * what component types the node requires.
     */
    private void init()
    {
        mNodes = new NodeList();
        mNodePool = new NodePool!Class( mComponents, this );

        // Collect the components that are in the node class managed by this family. 
        auto fields = fieldsOf!Class;
        foreach ( i, x; FieldTypeTuple!Class )
        {
            static if (is( x == class ))
            {
                if ( ChildInheritsFromParent!(Component,x) )
                {
                    mComponents[x.classinfo] = fields[i];
                }
            }
        }
    }

    void resetNode( Node node_a )
    {
        Class node = to!Class(node_a);
        foreach (i, x; FieldTypeTuple!Class )
        {
            static if (is( x == class ))
            {
                if ( ChildInheritsFromParent!(Component,x) )
                {
                    mixin( "node."~(fieldsOf!Class)[i]~" = null;" );
                }
            }
        }

    }


    /**
     * The nodelist managed by this family. This is a reference that remains valid always
     * since it is retained and reused by Systems that use the list. i.e. we never recreate the list,
     * we always modify it in place.
     */
    public NodeList nodeList()
    {
        return mNodes;
    }

    /**
     * Called by the engine when an entity has been added to it. We check if the entity should be in
     * this family's NodeList and add it if appropriate.
     */
    public void newEntity( Entity entity_a )
    {
        if ( entity_a is null )
            throw new Error( "null entity passed" );
        this.addIfMatch( entity_a );
    }
    
    /**
     * Called by the engine when a component has been added to an entity. We check if the entity is not in
     * this family's NodeList and should be, and add it if appropriate.
     */
    public void componentAddedToEntity( Entity entity_a, ClassInfo class_a )
    {
        if ( entity_a is null )
            throw new Error( "null entity passed" );
        this.addIfMatch( entity_a );
    }

    /**
     * If the entity is not in this family's NodeList, tests the components of the entity to see
     * if it should be in this NodeList and adds it if so.
     */
    private void addIfMatch( Entity entity_a )
    {
        if ( entity_a !in mEntities )
        {
            foreach ( key, cpt; mComponents )
            {
                if ( !entity_a.has( key ) )
                {
                    return;
                }
            }

            Class node = to!Class(mNodePool.get());
            if ( node is null )
                throw new Error( "Null node returned !!!" );
            node.entity = entity_a;

            // Ensure that all components in the node Class are initialised to the equivalent
            // values of the components in the entity
            foreach ( i, fieldtype; FieldTypeTuple!Class )
            {
                static if (is( fieldtype == class ))
                {
                    if ( ChildInheritsFromParent!(Component,fieldtype) )
                    {
                        mixin( "node."~(fieldsOf!Class)[i]~" = cast(fieldtype)entity_a.get( fieldtype.classinfo );" );
                    }
                }
            }

            mEntities[entity_a] = node;
            mNodes.add( node );
        }
    }
 
    /**
     * Called by the engine when a component has been removed from an entity. We check if the removed component
     * is required by this family's NodeList and if so, we check if the entity is in this this NodeList and
     * remove it if so.
     */
    public void componentRemovedFromEntity( Entity entity_a, ClassInfo class_a )
    {
        if ( class_a in mComponents )
        {
            removeIfMatch( entity_a );
        }
    }
    
    /**
     * Called by the engine when an entity has been removed from it. Check if the entity is in
     * this family's NodeList and remove it if so.
     */
    public void removeEntity( Entity entity_a )
    {
        removeIfMatch( entity_a );
    }
 
    /**
     * Removes the entity if it is in this family's NodeList.
     */
    private void removeIfMatch( Entity entity_a )
    {
        if ( entity_a in mEntities )
        {
            Node node = mEntities[entity_a];
            mEntities.remove(entity_a);
            mNodes.remove( node );
            if( mEngine.updating )
            {
                mNodePool.cache( node );
                mEngine.updateComplete.connect( &releaseNodePoolCache );
            }
            else
            {
                mNodePool.dispose( node );
            }
        }
    }


    /**
     * Releases the nodes that were added to the node pool during this engine update, so they can
     * be reused.
     */
    private void releaseNodePoolCache()
    {
        mEngine.updateComplete.disconnect( &releaseNodePoolCache );
        mNodePool.releaseCache();
    }
    
    /**
     * Removes all nodes from the NodeList.
     */
    public void cleanUp()
    {
        for( Node node = mNodes.head; node; node = node.next )
        {
            mEntities.remove( node.entity );
        }
        mNodes.removeAll();
    }

 
} // class ComponentMatchingFamily


