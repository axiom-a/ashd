/**
 * Unit tests for engine.d
 *
 */
module engine_test;

import ashd.core.component : Component;
import ashd.core.entity    : Entity;
import ashd.core.engine    : Engine;
import ashd.core.ifamily   : IFamily;
import ashd.core.node      : Node;
import ashd.core.nodelist  : NodeList;



int main()
{
    (new EngineTests).entitiesGetterReturnsAllTheEntities();
    (new EngineTests).getEntityByNameReturnsCorrectEntity();
    (new EngineTests).getEntityByNameReturnsNullIfNoEntity();
    (new EngineTests).addEntityChecksWithAllFamilies();
    (new EngineTests).removeEntityChecksWithAllFamilies();
    (new EngineTests).removeEntityChecksWithAllFamilies2();
    (new EngineTests).removeAllEntitiesChecksWithAllFamilies();

    (new EngineTests).componentAddedChecksWithAllFamilies();
    (new EngineTests).componentRemovedChecksWithAllFamilies();
    (new EngineTests).getNodeListCreatesFamily();

    (new EngineTests).getNodeListChecksAllEntities();
    (new EngineTests).entityCanBeObtainedByName();
    (new EngineTests).getEntityByInvalidNameReturnsNull();
    (new EngineTests).entityCanBeObtainedByNameAfterRenaming();
    (new EngineTests).entityCannotBeObtainedByOldNameAfterRenaming();

    return 0;
}

class EngineTests
{
    Engine mEngine;

    IFamily createNewMockFamily() { return new MockFamily; }

    public this()
    {
        mEngine = new Engine();
    }

    public void entitiesGetterReturnsAllTheEntities()
    {
        Entity entity1 = new Entity();
        mEngine.addEntity( entity1 );
        Entity entity2 = new Entity();
        mEngine.addEntity( entity2 );
        assert( mEngine.entities.length == 2 );
        assert( mEngine.entities == [ entity1, entity2 ] );
    }

    public void getEntityByNameReturnsCorrectEntity()
    {
        Entity entity1 = new Entity();
        entity1.name = "otherEntity";
        mEngine.addEntity( entity1 );
        Entity entity2 = new Entity();
        entity2.name = "myEntity";
        mEngine.addEntity( entity2 );

        assert( mEngine.getEntityByName( "myEntity" ) is entity2 );
    }

    public void getEntityByNameReturnsNullIfNoEntity()
    {
        Entity entity1 = new Entity();
        entity1.name = "otherEntity";
        mEngine.addEntity( entity1 );
        Entity entity2 = new Entity();
        entity2.name = "myEntity";
        mEngine.addEntity( entity2 );

        assert( mEngine.getEntityByName( "wrongName" ) is null );
    }

    public void addEntityChecksWithAllFamilies()
    {
        MockFamily.reset();
        auto family1=new MockFamily;
        mEngine.registerFamily!MockNode( family1 );
        auto family2=new MockFamily;
        mEngine.registerFamily!MockNode2( family2 );
        mEngine.getNodeList!(MockNode)( );
        //mEngine.getNodeList!(MockNode)( &createNewMockFamily );
        //mEngine.getNodeList!(MockNode2)( &createNewMockFamily );
        mEngine.getNodeList!(MockNode2)( );
        Entity entity = new Entity();
        mEngine.addEntity( entity );

        assert( MockFamily.mInstances[0].mNewEntityCalls == 1);
        assert( MockFamily.mInstances[1].mNewEntityCalls == 1 );
    }

    public void removeEntityChecksWithAllFamilies()
    {
        MockFamily.reset();
        mEngine.getNodeList!(MockNode)( &createNewMockFamily );
        mEngine.getNodeList!(MockNode2)( &createNewMockFamily );

        Entity entity = new Entity();
        mEngine.addEntity( entity );

        mEngine.removeEntity( entity );

        assert( MockFamily.mInstances[0].mRemoveEntityCalls == 1 );
        assert( MockFamily.mInstances[1].mRemoveEntityCalls == 1 );
    }

    public void removeEntityChecksWithAllFamilies2()
    {
        MockFamily.reset();
        mEngine.getNodeList!(MockNode)( &createNewMockFamily );
        mEngine.getNodeList!(MockNode2)( &createNewMockFamily );

        Entity entity = new Entity();
        Entity entity2 = new Entity();
        mEngine.addEntity( entity );
        mEngine.addEntity( entity2 );

        mEngine.removeEntity( entity );
        mEngine.removeEntity( entity2 );

        assert( MockFamily.mInstances[0].mRemoveEntityCalls == 2 );
        assert( MockFamily.mInstances[1].mRemoveEntityCalls == 2 );
    }


    public void removeAllEntitiesChecksWithAllFamilies()
    {
        MockFamily.reset();
        mEngine.getNodeList!(MockNode)( &createNewMockFamily );
        mEngine.getNodeList!(MockNode2)( &createNewMockFamily );

        Entity entity  = new Entity();
        Entity entity2 = new Entity();

        mEngine.addEntity( entity );
        mEngine.addEntity( entity2 );

        mEngine.removeAllEntities();

        assert( MockFamily.mInstances[0].mRemoveEntityCalls == 2 );
        assert( MockFamily.mInstances[1].mRemoveEntityCalls == 2 );
    }

    public void componentAddedChecksWithAllFamilies()
    {
        MockFamily.reset();
        mEngine.getNodeList!(MockNode)( &createNewMockFamily );
        mEngine.getNodeList!(MockNode2)( &createNewMockFamily );

        Entity entity  = new Entity();
        mEngine.addEntity( entity );
        entity.add!Point( new Point() );

        assert( MockFamily.mInstances[0].mComponentAddedCalls == 1 );
        assert( MockFamily.mInstances[1].mComponentAddedCalls == 1 );
    }

    public void componentRemovedChecksWithAllFamilies()
    {
        MockFamily.reset();
        mEngine.getNodeList!(MockNode)( &createNewMockFamily );
        mEngine.getNodeList!(MockNode2)( &createNewMockFamily );

        Entity entity  = new Entity();
        mEngine.addEntity( entity );
        entity.add!Point( new Point() );
        entity.remove!Point();

        assert( MockFamily.mInstances[0].mComponentRemovedCalls == 1 );
        assert( MockFamily.mInstances[1].mComponentRemovedCalls == 1 );
    }

    public void getNodeListCreatesFamily()
    {
        MockFamily.reset();
        mEngine.getNodeList!(MockNode)( &createNewMockFamily );

        assert( MockFamily.mInstances.length == 1 );
    }

    public void getNodeListChecksAllEntities()
    {
        MockFamily.reset();
        mEngine.addEntity( new Entity() );
        mEngine.addEntity( new Entity() );
        mEngine.getNodeList!(MockNode)( &createNewMockFamily );
        assert( MockFamily.mInstances[0].mNewEntityCalls == 2 );
    }

    public void releaseNodeListCallsCleanUp()
    {
        MockFamily.reset();
        mEngine.getNodeList!(MockNode)( &createNewMockFamily );
        mEngine.releaseNodeList!MockNode( );
        assert( MockFamily.mInstances[0].mCleanUpCalls == 1 );
    }

    public void entityCanBeObtainedByName()
    {
        MockFamily.reset();
        Entity entity  = new Entity( "anything" );
        mEngine.addEntity( entity );

        Entity other = mEngine.getEntityByName( "anything" );
        assert( other is entity );
    }

    public void getEntityByInvalidNameReturnsNull()
    {
        MockFamily.reset();
        Entity entity = mEngine.getEntityByName( "anything" );
        assert( entity is null );
    }

    public void entityCanBeObtainedByNameAfterRenaming()
    {
        MockFamily.reset();
        Entity entity  = new Entity( "anything" );
        mEngine.addEntity( entity );
        entity.name = "otherName";
        Entity other = mEngine.getEntityByName( "otherName" );
        assert( other is entity );
    }

    public void entityCannotBeObtainedByOldNameAfterRenaming()
    {
        MockFamily.reset();
        Entity entity  = new Entity( "anything" );
        mEngine.addEntity( entity );
        entity.name = "otherName";
        Entity other = mEngine.getEntityByName( "anything" );
        assert( other is null );
    }

}

class Point: Component
{
    int x; int y;
}

class MockNode: Node
{
    public Point point;
}

class MockNode2: Node
{
    public int foo;
}


class MockFamily: IFamily
{
    private
    {
        static MockFamily[] mInstances;
        int mNewEntityCalls;
        int mRemoveEntityCalls;
        int mComponentAddedCalls;
        int mComponentRemovedCalls;
        int mCleanUpCalls;
    }

    public this()
    {
        mInstances ~= this;
    }

    static public void reset() { mInstances.length = 0; }

    public NodeList nodeList()
    {
        return null;
    }

    public void newEntity( Entity entity_a )
    {
        mNewEntityCalls++;
    }

    public void removeEntity( Entity entity_a )
    {
        mRemoveEntityCalls++;
    }

    public void componentAddedToEntity( Entity entity_a, ClassInfo class_a )
    {
        mComponentAddedCalls++;
    }

    public void componentRemovedFromEntity( Entity entity_a, ClassInfo class_a )
    {
        mComponentRemovedCalls++;
    }

    public void cleanUp()
    {
        mCleanUpCalls++;
    }

    public void resetNode( Node node_a ) {}
}



