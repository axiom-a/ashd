/**
 * Unit tests from componentMatchingFamily.d
 *
 */
import ashd.core.componentMatchingFamily: ComponentMatchingFamily;
import ashd.core.component              : Component;
import ashd.core.entity                 : Entity;
import ashd.core.engine                 : Engine;
import ashd.core.ifamily                : IFamily;
import ashd.core.node                   : Node;
import ashd.core.nodelist               : NodeList;


int main()
{
    (new ComponentMatchingFamilyTests).testNodeListIsInitiallyEmpty();
    (new ComponentMatchingFamilyTests).testMatchingEntityIsAddedWhenAccessNodeListFirst();
    (new ComponentMatchingFamilyTests).testMatchingEntityIsAddedWhenAccessNodeListSecond();
    (new ComponentMatchingFamilyTests).testNodeContainsEntityProperties();
    (new ComponentMatchingFamilyTests).testMatchingEntityIsAddedWhenComponentAdded();
    (new ComponentMatchingFamilyTests).testNonMatchingEntityIsNotAdded();
    (new ComponentMatchingFamilyTests).testNonMatchingEntityIsNotAddedWhenComponentAdded();
    (new ComponentMatchingFamilyTests).testEntityIsRemovedWhenAccessNodeListFirst();
    (new ComponentMatchingFamilyTests).testEntityIsRemovedWhenAccessNodeListSecond();
    (new ComponentMatchingFamilyTests).testEntityIsRemovedWhenComponentRemoved();
    (new ComponentMatchingFamilyTests).nodeListContainsOnlyMatchingEntities();
    (new ComponentMatchingFamilyTests).nodeListContainsAllMatchingEntities();
    (new ComponentMatchingFamilyTests).cleanUpEmptiesNodeList();
    (new ComponentMatchingFamilyTests).cleanUpSetsNextNodeToNull();

    return 0;
}


public class ComponentMatchingFamilyTests
{
    ComponentMatchingFamily!MockNode mFamily;
    Engine                           mEngine;


    public this()
    {
        mEngine = new Engine;
        mFamily = new ComponentMatchingFamily!MockNode( mEngine );
    }

    public void testNodeListIsInitiallyEmpty()
    {
        NodeList nodes = mFamily.nodeList();
        assert( nodes.head is null );
    }


    public void testMatchingEntityIsAddedWhenAccessNodeListFirst()
    {
        NodeList nodes = mFamily.nodeList();
        Entity entity = new Entity();
        entity.add( new Point() );
        mFamily.newEntity( entity );
        assert( nodes.head.entity is entity );
    }


    public void testMatchingEntityIsAddedWhenAccessNodeListSecond()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        mFamily.newEntity( entity );
        NodeList nodes = mFamily.nodeList;
        assert( nodes.head.entity is entity );
    }

    public void testNodeContainsEntityProperties()
    {
        Entity entity = new Entity();
        Point point = new Point();
        entity.add( point );
        mFamily.newEntity( entity );
        NodeList nodes = mFamily.nodeList;
        assert( nodes.head.entity.get!Point is point );
    }

    public void testMatchingEntityIsAddedWhenComponentAdded()
    {
        NodeList nodes = mFamily.nodeList;
        Entity entity = new Entity();
        entity.add( new Point() );
        mFamily.componentAddedToEntity( entity, Point.classinfo );
        assert( nodes.head.entity is entity );
    }

    public void testNonMatchingEntityIsNotAdded()
    {
        Entity entity = new Entity();
        mFamily.newEntity( entity );
        NodeList nodes = mFamily.nodeList;
        assert( nodes.head is null );
    }
 
    public void testNonMatchingEntityIsNotAddedWhenComponentAdded()
    {
        Entity entity = new Entity();
        entity.add( new Class2() );
        mFamily.componentAddedToEntity( entity, Class2.classinfo );
        NodeList nodes = mFamily.nodeList;
        assert( nodes.head is null );
    }

    public void testEntityIsRemovedWhenAccessNodeListFirst()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        mFamily.newEntity( entity );
        NodeList nodes = mFamily.nodeList;
        assert( nodes.head.entity is entity );
        mFamily.removeEntity( entity );
        assert( nodes.head is null );
    }
 
    public void testEntityIsRemovedWhenAccessNodeListSecond()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        mFamily.newEntity( entity );
        mFamily.removeEntity( entity );
        NodeList nodes = mFamily.nodeList;
        assert( nodes.head is null );
    }


    public void testEntityIsRemovedWhenComponentRemoved()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        mFamily.newEntity( entity );
        entity.remove!Point();
        mFamily.componentRemovedFromEntity( entity, Point.classinfo );
        NodeList nodes = mFamily.nodeList;
        assert( nodes.head is null );
    }

    public void nodeListContainsOnlyMatchingEntities()
    {
        Entity[] entities;
        for ( int i = 0; i < 5; ++i )
        {
            Entity entity = new Entity();
            entity.add( new Point() );
            entities ~= entity;
            mFamily.newEntity( entity );
            mFamily.newEntity( new Entity() );
        }
        
        NodeList nodes = mFamily.nodeList;
        Node node;
        int i;
        for ( node = nodes.head; node; node = node.next )
        {
            assert( entities[i++] is node.entity );
        }
    }


    public void nodeListContainsAllMatchingEntities()
    {
        Entity[] entities;
        for ( int i = 0; i < 5; ++i )
        {
            Entity entity = new Entity();
            entity.add( new Point() );
            entities ~= entity;
            mFamily.newEntity( entity );
            mFamily.newEntity( new Entity() );
        }
        NodeList nodes = mFamily.nodeList;
        Node node;
        int i;
        for ( node = nodes.head; node; node = node.next )
        {
            assert( entities[i++] is node.entity );
        }
        assert( i==5 );
    }

    public void cleanUpEmptiesNodeList()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        mFamily.newEntity( entity );
        NodeList nodes = mFamily.nodeList;
        mFamily.cleanUp();
        assert( nodes.head is null );
    }

    public void cleanUpSetsNextNodeToNull()
    {
        Entity[] entities;
        for ( int i = 0; i < 5; ++i )
        {
            Entity entity = new Entity();
            entity.add( new Point() );
            entities ~= entity;
            mFamily.newEntity( entity );
        }
        
        NodeList nodes = mFamily.nodeList;
        Node node = nodes.head.next;
        mFamily.cleanUp();
        assert( node.next is null );
    }

}

class MockNode: Node
{
    Point point;
    int dummy;
}

@Cxmponent class Point: Component
{ 
    int x; int y; 
}

@Cxmponent class Class2: Component
{
    int dummy;
}

