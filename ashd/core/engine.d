/**
 * The Engine class is the central point for creating and managing your game state. Add
 * entities and systems to the engine, and fetch families of nodes from the engine.
 *
 * In essence, a family manages a NodeList. So whenever a System requests a collection of nodes, 
 * the engine looks for a family that is managing such a collection. If it doesn't have one, it 
 * creates a new one. Either way, it then passes the NodeList managed by the family back to the 
 * System that requested it.
 *
 * The family is initialised with a node type. It uses reflection to determine what components 
 * that node type requires. Whenever an entity is added to the engine it is passed to every 
 * family in the engine, and the families determine whether that entity has the necessary components 
 * to join that family. If it does then the family will add it to its NodeList. If the components 
 * on an entity are changed, by adding or removing a component, then again the engine checks with 
 * all the families and each family tests whether to add or remove the entity to/from its NodeList. 
 * Finally, when an entity is removed form the engine the engine informs all the families and any 
 * family that has the entity in its NodeList will remove it.
 *
 */

module ashd.core.engine;

import ashd.core.entity    : Entity;
import ashd.core.entitylist: EntityList;
import ashd.core.iengine   : IEngine;
import ashd.core.ifamily   : IFamily;
import ashd.core.node      : Node;
import ashd.core.nodelist  : NodeList;
import ashd.core.system    : System;
import ashd.core.systemlist: SystemList;

import std.conv     : to;
import std.datetime : Duration;
import std.signals; // for Signal template. 


class Engine: IEngine
{
    private
    {
        Entity[string]     mEntityNames;          // names of entities in engine...
        EntityList         mEntityList;           
        SystemList         mSystemList;
        IFamily[ClassInfo] mFamilies;
        bool               mUpdating;
    }

    @property public bool updating() { return mUpdating; }


    /**
     * Dispatched when the update loop ends. If you want to add and remove systems from the
     * engine it is usually best not to do so during the update loop. To avoid this you can
     * listen for this signal and make the change when the signal is dispatched.
     */
    mixin Signal!() updateComplete;
    
    
    public this()
    {
        mEntityList = new EntityList();
        mSystemList = new SystemList();
    }


    /**
     * Add an entity to the engine.
     * 
     * Params:
     *   entity_a = The entity to add.
     */
    public void addEntity( Entity entity_a )
    {
        if ( entity_a.name() in mEntityNames )
        {
            throw new Error( "The entity name " ~ entity_a.name ~ " is already in use by another entity." );
        }
        mEntityList.add( entity_a );
        mEntityNames[ entity_a.name ] = entity_a;
        entity_a.componentAdded.connect( &this.componentAdded );
        entity_a.componentRemoved.connect( &this.componentRemoved );
        entity_a.nameChanged.connect( &this.entityNameChanged );

        foreach( family; mFamilies )
        {
            family.newEntity( entity_a );
        }
    }
    
    /**
     * Remove an entity from the engine.
     *
     * Params:
     *  entity_a =  The entity to remove.
     */
    public void removeEntity( Entity entity_a )
    {
        entity_a.componentAdded.disconnect( &this.componentAdded );
        entity_a.componentRemoved.disconnect( &this.componentRemoved );
        entity_a.nameChanged.disconnect( &this.entityNameChanged );

        foreach( family; mFamilies )
        {
            family.removeEntity( entity_a );
        }

        mEntityNames.remove( entity_a.name );
        mEntityList.remove( entity_a );
    }

    // callback received when entity name changed....   
    private void entityNameChanged( Entity entity_a, string oldName_a )
    {
        if ( oldName_a in mEntityNames )
        {
            if ( mEntityNames[ oldName_a ] == entity_a )
            {
                mEntityNames.remove( oldName_a );
                mEntityNames[ entity_a.name ] = entity_a;
            }
            else
            {
                throw new Error( "Entity name '" ~ oldName_a ~ "' does not match entity !" );
            }
        }
        else
        {
            throw new Error( "Entity Name '" ~ oldName_a ~ "'does not exist !" );
        }
    }
   
    /**
     * Get an entity based n its name.
     * 
     * @param name The name of the entity
     * @return The entity, or null if no entity with that name exists on the engine
     */
    public Entity getEntityByName( string name_a )
    {
        if ( name_a in mEntityNames )
            return mEntityNames[ name_a ];
        else
            return null;
    }
    
    /**
     * Remove all entities from the engine.
     */
    public void removeAllEntities()
    {
        while( mEntityList.head )
        {
            this.removeEntity( mEntityList.head );
        }
    }


    /**
     * Returns a vector containing all the entities in the engine.
     */
    public Entity[] entities()
    {
        Entity[] entities;
        for ( Entity entity = mEntityList.head; entity; entity = entity.next )
        {
            entities ~= entity;
        }
        return entities;
    }


    /*
     *  Callback received whenever component added to entity
     */
    private void componentAdded( Entity entity_a, ClassInfo cpt_a )
    {
        foreach( family; mFamilies )
            family.componentAddedToEntity( entity_a, cpt_a );
    }
    
    /*
     * Callback received whenever component removed from an entity
     */
    private void componentRemoved( Entity entity_a, ClassInfo cpt_a )
    {
        foreach( family; mFamilies )
            family.componentRemovedFromEntity( entity_a, cpt_a );
    }
   
    public void registerFamily(N)( IFamily family_a )
    {
        if (N.classinfo in mFamilies)
            throw new Error( "Family '" ~ N.stringof ~ "' already registered" );

        mFamilies[N.classinfo] = family_a;
    }

    /**
     * Get a collection of nodes from the engine, based on the type of the node required.
     * 
     * <p>The engine will create the appropriate NodeList if it doesn't already exist and 
     * will keep its contents up to date as entities are added to and removed from the
     * engine.</p>
     * 
     * <p>If a NodeList is no longer required, release it with the releaseNodeList method.</p>
     * 
     * @param nodeClass The type of node required.
     * RETURNS:
     *  A linked list of all nodes of this type from all entities in the engine.
     */
    public NodeList getNodeList( ClassInfo nodeType_a, IFamily delegate() createInstance_a=null )
    {
        if ( nodeType_a in mFamilies )
        {
            return mFamilies[nodeType_a].nodeList;
        }

        if (createInstance_a is null)
            throw new Error( "no family registered for '" ~ to!string(nodeType_a) ~ "'");
        IFamily family = createInstance_a();

        mFamilies[nodeType_a] = family;

        for( Entity entity = mEntityList.head; entity; entity = entity.next )
        {
            family.newEntity( entity );
        }
        return family.nodeList;

    }
    ///
    public NodeList getNodeList(N)( IFamily delegate() createInstance_a=null )
    {
        return this.getNodeList( N.classinfo, createInstance_a );
    }
   
    /**
     * If a NodeList is no longer required, this method will stop the engine updating
     * the list and will release all references to the list within the framework
     * classes, enabling it to be garbage collected.
     * 
     * <p>It is not essential to release a list, but releasing it will free
     * up memory and processor resources.</p>
     * 
     * @param nodeClass The type of the node class if the list to be released.
     */
    public void releaseNodeList(N)()
    {
        if ( N.classinfo in mFamilies )
        {
            mFamilies[N.classinfo].cleanUp();
            mFamilies.remove(N.classinfo);
        }
    }

    /**
     * Add a system to the engine, and set its priority for the order in which the
     * systems are updated by the engine update loop.
     * 
     * The priority dictates the order in which the systems are updated by the engine update 
     * loop. Lower numbers for priority are updated first. i.e. a priority of 1 is 
     * updated before a priority of 2.
     *
     * Params:
     *  system_a =  The system to add to the engine.
     *  priority_a = priority The priority for updating the systems during the engine loop. A 
     * lower number means the system is updated sooner.
     */
    public void addSystem(T)( ref T system_a, int priority_a )
    {
        system_a.priority = priority_a;
        system_a.type = T.classinfo;
        system_a.addToEngine( this );
        mSystemList.add( system_a );
    }

    public void addSystem( ref System system_a, ClassInfo class_a, int priority_a )
    {
        system_a.priority = priority_a;
        system_a.type = class_a;
        system_a.addToEngine( this );
        mSystemList.add( system_a );
    }



    /**
     * Get the system instance of a particular type from within the engine.
     * 
     * Params:
     *  T = system type
     * Returns:
     *  The instance of the system type that is in the engine, or
     *  null if no systems of this type are in the engine.
     */
    public System getSystem(T)()
    {
        return mSystemList.get!T();
    }

    /**
     * Returns a vector containing all the systems in the engine.
     */
    @property public System[] systems()
    {
        System[] systems;
        for ( System system = mSystemList.head; system; system = system.next )
        {
            systems ~= system;
        }

        return systems;
    }


    /**
     * Remove a system from the engine.
     * 
     * @param system The system to remove from the engine.
     */
    public void removeSystem( System system_a )
    {
        mSystemList.remove( system_a );
        system_a.removeFromEngine( this );
    }
    
    /**
     * Remove all systems from the engine.
     */
    public void removeAllSystems()
    {
        while( mSystemList.head )
        {
            removeSystem( mSystemList.head );
        }
    }

    /**
     * Update the engine. This causes the engine update loop to run, calling update on all the
     * systems in the engine.
     * 
     * Params:
     *  time_a = The duration of this update step.
     */
    public void update( Duration time_a )
    {
        mUpdating = true;
        for ( System system = mSystemList.head; system; system = system.next )
        {
            system.update( time_a );
        }
        mUpdating = false;
        updateComplete.emit();
    }
} // class Engine
