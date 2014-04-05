/**
 * Unit tests for system.d and IFamily
 *
 */
import ashd.core.component              : Component;
import ashd.core.componentMatchingFamily: ComponentMatchingFamily;
import ashd.core.engine                 : Engine, IFamily, Node, NodeList;
import ashd.core.entity                 : Entity;


import std.datetime  : dur, Duration, SysTime;


int main()
{
    (new EngineAndFamilyIntegrationTests).testFamilyIsInitiallyEmpty();
    (new EngineAndFamilyIntegrationTests).testNodeContainsEntityProperties();
    (new EngineAndFamilyIntegrationTests).testCorrectEntityAddedToFamilyWhenAccessFamilyFirst();
    (new EngineAndFamilyIntegrationTests).testCorrectEntityAddedToFamilyWhenAccessFamilySecond();
    (new EngineAndFamilyIntegrationTests).testCorrectEntityAddedToFamilyWhenComponentsAdded();
    (new EngineAndFamilyIntegrationTests).testIncorrectEntityNotAddedToFamilyWhenAccessFamilyFirst();
    (new EngineAndFamilyIntegrationTests).testIncorrectEntityNotAddedToFamilyWhenAccessFamilySecond();
    (new EngineAndFamilyIntegrationTests).testEntityRemovedFromFamilyWhenComponentRemovedAndFamilyAlreadyAccessed();
    (new EngineAndFamilyIntegrationTests).testEntityRemovedFromFamilyWhenComponentRemovedAndFamilyNotAlreadyAccessed();
    (new EngineAndFamilyIntegrationTests).testEntityRemovedFromFamilyWhenRemovedFromEngineAndFamilyAlreadyAccessed();
    (new EngineAndFamilyIntegrationTests).testEntityRemovedFromFamilyWhenRemovedFromEngineAndFamilyNotAlreadyAccessed();
    (new EngineAndFamilyIntegrationTests).familyContainsOnlyMatchingEntities();
    (new EngineAndFamilyIntegrationTests).familyContainsAllMatchingEntities();
    (new EngineAndFamilyIntegrationTests).releaseFamilyEmptiesNodeList();
    (new EngineAndFamilyIntegrationTests).releaseFamilySetsNextNodeToNull();
    (new EngineAndFamilyIntegrationTests).removeAllEntitiesDoesWhatItSays();


    return 0;
}

/**
 * Tests the family class through the engine class. Left over from a previous 
 * architecture but retained because all tests shoudl still pass.
 */
public class EngineAndFamilyIntegrationTests
{
    Engine mEngine;
    ComponentMatchingFamily!MockNode mMockNodeFamily;


    public this()
    {
        mEngine = new Engine();
        mMockNodeFamily = new ComponentMatchingFamily!MockNode( mEngine );
        mEngine.registerFamily!MockNode( mMockNodeFamily );
    }

    public void testFamilyIsInitiallyEmpty()
    {
        NodeList nodes = mEngine.getNodeList!MockNode();
        assert( nodes.head is null );
    }

    public void testNodeContainsEntityProperties()
    {
        Entity entity = new Entity();
        Point point   = new Point();
        Matrix matrix = new Matrix();
        entity.add( point );
        entity.add( matrix );
        
        NodeList nodes = mEngine.getNodeList!MockNode( );
        mEngine.addEntity( entity );
        assert( nodes.head.entity.get!Point is point );
        assert( nodes.head.entity.get!Matrix is matrix );
    }

    public void testCorrectEntityAddedToFamilyWhenAccessFamilyFirst()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        entity.add( new Matrix() );
        NodeList nodes = mEngine.getNodeList!MockNode();
        mEngine.addEntity( entity );

        assert( nodes.head.entity is entity );
    }

    public void testCorrectEntityAddedToFamilyWhenAccessFamilySecond()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        entity.add( new Matrix() );
        mEngine.addEntity( entity );
        NodeList nodes = mEngine.getNodeList!MockNode();
        assert( nodes.head.entity is entity );
    }

    public void testCorrectEntityAddedToFamilyWhenComponentsAdded()
    {
        Entity entity = new Entity();
        mEngine.addEntity( entity );
        NodeList nodes = mEngine.getNodeList!MockNode();
        entity.add( new Point() );
        entity.add( new Matrix() );
        assert( nodes.head.entity is entity );
    }

    public void testIncorrectEntityNotAddedToFamilyWhenAccessFamilyFirst()
    {
        Entity entity = new Entity();
        NodeList nodes = mEngine.getNodeList!MockNode();
        mEngine.addEntity( entity );
        assert( nodes.head is null );
    }

    public void testIncorrectEntityNotAddedToFamilyWhenAccessFamilySecond()
    {
        Entity entity = new Entity();
        mEngine.addEntity( entity );
        NodeList nodes = mEngine.getNodeList!MockNode();
        assert( nodes.head is null );
    }

    public void testEntityRemovedFromFamilyWhenComponentRemovedAndFamilyAlreadyAccessed()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        entity.add( new Matrix() );
        mEngine.addEntity( entity );
        NodeList nodes = mEngine.getNodeList!MockNode();
        entity.remove!Point();
        assert( nodes.head is null );
    }

    public void testEntityRemovedFromFamilyWhenComponentRemovedAndFamilyNotAlreadyAccessed()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        entity.add( new Matrix() );
        mEngine.addEntity( entity );
        entity.remove!Point();
        NodeList nodes = mEngine.getNodeList!MockNode();
        assert( nodes.head is null );
    }

    public void testEntityRemovedFromFamilyWhenRemovedFromEngineAndFamilyAlreadyAccessed()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        entity.add( new Matrix() );
        mEngine.addEntity( entity );
        NodeList nodes = mEngine.getNodeList!MockNode();
        mEngine.removeEntity( entity );
        assert( nodes.head is null );
    }

    public void testEntityRemovedFromFamilyWhenRemovedFromEngineAndFamilyNotAlreadyAccessed()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        entity.add( new Matrix() );
        mEngine.addEntity( entity );
        mEngine.removeEntity( entity );
        NodeList nodes = mEngine.getNodeList!MockNode();
        assert( nodes.head is null );
    }

    public void familyContainsOnlyMatchingEntities()
    {
        Entity[] entities;
        for ( int i = 0; i < 5; ++i )
        {
            Entity entity = new Entity();
            entity.add( new Point() );
            entity.add( new Matrix() );
            entities ~= entity;
            mEngine.addEntity( entity );
        }
        
        NodeList nodes = mEngine.getNodeList!MockNode();
        Node node;
        int i;
        for( node = nodes.head; node; node = node.next )
        {
            assert( entities[i++] is node.entity );
        }
    }

    public void familyContainsAllMatchingEntities() 
    {
        Entity[] entities;
        for ( int i = 0; i < 5; ++i )
        {
            Entity entity = new Entity();
            entity.add( new Point() );
            entity.add( new Matrix() );
            entities ~= entity;
            mEngine.addEntity( entity );
        }
        
        NodeList nodes = mEngine.getNodeList!MockNode();
        Node node;
        int i;
        for( node = nodes.head; node; node = node.next )
        {
            assert( entities[i++] is node.entity );
        }
        assert( i==5 );
    }

    public void releaseFamilyEmptiesNodeList()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        entity.add( new Matrix() );
        mEngine.addEntity( entity );
        NodeList nodes = mEngine.getNodeList!MockNode();
        mEngine.releaseNodeList!MockNode();
        assert( nodes.head is null );
    }

    public void releaseFamilySetsNextNodeToNull()
    {
        Entity[] entities;
        for( int i = 0; i < 5; ++i )
        {
            Entity entity = new Entity();
            entity.add( new Point() );
            entity.add( new Matrix() );
            entities ~= entity;
            mEngine.addEntity( entity );
        }
        
        NodeList nodes = mEngine.getNodeList!MockNode();
        Node node = nodes.head.next;
        mEngine.releaseNodeList!MockNode();
        assert( node.next is null );
    }

    public void removeAllEntitiesDoesWhatItSays()
    {
        Entity entity = new Entity();
        entity.add( new Point() );
        entity.add( new Matrix() );
        mEngine.addEntity( entity );
        entity = new Entity();
        entity.add( new Point() );
        entity.add( new Matrix() );
        mEngine.addEntity( entity );
        NodeList nodes = mEngine.getNodeList!MockNode();
        mEngine.removeAllEntities();
        assert( nodes.head is null );
    }


} // EngineAndFamilyIntegrationTests

class MockNode: Node
{
    public Point point;
    public Matrix matrix;
}

class Point: Component
{ 
    int x; int y; 
}

class Matrix: Component
{
    int[2][2] data;
}


