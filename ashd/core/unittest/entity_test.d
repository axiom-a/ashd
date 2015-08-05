/**
 * Unit tests for Entity.d
 *
 */
module entity_test;

import ashd.core.component: Component;
import ashd.core.entity   : Entity;


int main()
{
    (new EntityTests).addReturnsReferenceToEntity();
    (new EntityTests).canStoreAndRetrieveComponent();
    (new EntityTests).canStoreAndRetrieveMultipleComponents();
    (new EntityTests).canReplaceComponent();
    (new EntityTests).canStoreBaseAndExtendedComponents();
    (new EntityTests).canStoreExtendedComponentAsBaseType();
    (new EntityTests).getReturnNullIfNoComponent();
    (new EntityTests).willRetrieveAllComponents();
    (new EntityTests).hasComponentIsFalseIfComponentTypeNotPresent();
    (new EntityTests).hasComponentIsTrueIfComponentTypeIsPresent();
    (new EntityTests).canRemoveComponent();
    (new EntityTests).storingComponentTriggersAddedSignal();
    (new EntityTests).removingComponentTriggersRemovedSignal();
    (new EntityTests).componentAddedSignalContainsCorrectParameters();
    (new EntityTests).componentRemovedSignalContainsCorrectParameters();
    (new EntityTests).testEntityHasNameByDefault();
    (new EntityTests).testEntityNameStoredAndReturned();
    (new EntityTests).testEntityNameCanBeChanged();
    (new EntityTests).testChangingEntityNameDispatchesSignal();

    return 0;
}


class EntityTests
{
    void addReturnsReferenceToEntity()
    {
        Entity testEntity = new Entity();
        MockComponent component = new MockComponent;
        auto e = testEntity.add( component );
        assert( e is testEntity, "Test FAIL: addReturnsReferenceToEntity()" );
    }

    void canStoreAndRetrieveComponent()
    {
        Entity testEntity = new Entity();
        MockComponent component = new MockComponent();
        auto e = testEntity.add( component );
        assert( testEntity.get!MockComponent() is component, "Test FAIL: canStoreAndRetrieveComponent()" );
    }

    void canStoreAndRetrieveMultipleComponents()
    {
        Entity testEntity = new Entity();
        MockComponent component1 = new MockComponent();
        MockComponent2 component2 = new MockComponent2();
        testEntity.add( component1 );
        testEntity.add( component2 );
        assert( testEntity.get!MockComponent() is component1 );
        assert( testEntity.get!MockComponent2() is component2 );
    }

    void canReplaceComponent()
    {
        Entity testEntity = new Entity();
        MockComponent component1 = new MockComponent();
        MockComponent component2 = new MockComponent();
        testEntity.add( component1 );
        testEntity.add( component2 );
        assert( testEntity.get!MockComponent() is component2 );
    }

    void canStoreBaseAndExtendedComponents()
    {
        Entity testEntity = new Entity();
        MockComponent component1 = new MockComponent();
        testEntity.add( component1 );
        MockComponentExtended component2 = new MockComponentExtended();
        testEntity.add( component2 );

        assert( testEntity.get!MockComponent() is component1 );
        assert( testEntity.get!MockComponentExtended() is component2 );
    }


    void canStoreExtendedComponentAsBaseType()
    {
        Entity testEntity = new Entity();
        MockComponentExtended component = new MockComponentExtended;
        testEntity.add!MockComponent( component );
        assert( testEntity.get!MockComponent() is component );
    }

    void getReturnNullIfNoComponent()
    {
        Entity testEntity = new Entity();
        assert( testEntity.get!MockComponent() is null );
    }

    void willRetrieveAllComponents()
    {
        Entity testEntity = new Entity();
        MockComponent  component1 = new MockComponent();
        MockComponent2 component2 = new MockComponent2();
        testEntity.add( component1 );
        testEntity.add( component2 );

        auto all = testEntity.getAll();
        assert( all.length == 2 );
        bool tmp[Object];
        foreach ( cpt; all )
            tmp[cpt] = true;
        assert( component1 in tmp );
        assert( component2 in tmp );
    }

    void hasComponentIsFalseIfComponentTypeNotPresent()
    {
        Entity testEntity = new Entity();
        testEntity.add( new MockComponent2() );
        assert( testEntity.has!MockComponent() == false );
        assert( testEntity.has(MockComponent.classinfo) == false );
    }

    void hasComponentIsTrueIfComponentTypeIsPresent()
    {
        Entity testEntity = new Entity();
        testEntity.add( new MockComponent() );
        assert( testEntity.has!MockComponent() == true );
        assert( testEntity.has(MockComponent.classinfo) == true );
    }

    void canRemoveComponent()
    {
        Entity testEntity = new Entity();
        MockComponent  component1 = new MockComponent();
        testEntity.add( component1 );
        testEntity.remove!MockComponent();
        assert( testEntity.has!MockComponent() == false );
    }

    void storingComponentTriggersAddedSignal()
    {
        bool bCalled = false;
        class Watcher { void watch( Entity e, ClassInfo c ) { bCalled = true; } }
        Entity testEntity = new Entity();
        MockComponent  component1 = new MockComponent();

        Watcher testWatch = new Watcher();
        testEntity.componentAdded.connect( &testWatch.watch );
        testEntity.add!MockComponent( component1 );
        assert( bCalled == true );
    }

    void removingComponentTriggersRemovedSignal()
    {
        Entity testEntity = new Entity();
        MockComponent  component1 = new MockComponent();
        testEntity.add( component1 );

        bool bCalled = false;
        class Watcher { void watch( Entity e, ClassInfo c ) { bCalled = true; } }
        Watcher testWatch = new Watcher();
        testEntity.componentRemoved.connect( &testWatch.watch );
        testEntity.remove!MockComponent();
        assert( bCalled == true );
    }

    void componentAddedSignalContainsCorrectParameters()
    {
        Entity testEntity = new Entity();
        MockComponent component1 = new MockComponent();

        class Watcher 
        { 
            void watch( Entity e, ClassInfo c ) 
            { 
                assert( e is testEntity );
                assert( c == MockComponent.classinfo );
            } 
        }
        Watcher testWatch = new Watcher();

        testEntity.componentAdded.connect( &testWatch.watch );
        testEntity.add( component1 );
    }

    void componentRemovedSignalContainsCorrectParameters()
    {
        Entity testEntity = new Entity();
        MockComponent  component1 = new MockComponent();

        class Watcher 
        { 
            void watch( Entity e, ClassInfo c ) 
            { 
                assert( e is testEntity );
                assert( c == MockComponent.classinfo );
            } 
        }
        Watcher testWatch = new Watcher();

        testEntity.add( component1 );
        testEntity.componentRemoved.connect( &testWatch.watch );
        testEntity.remove!MockComponent();
    }

    void testEntityHasNameByDefault()
    {
        Entity testEntity = new Entity();
        assert( testEntity.name.length > 0 );
    }

    void testEntityNameStoredAndReturned()
    {
        string name = "anything";
        Entity testEntity = new Entity( name );
        assert( testEntity.name == name );
    }

    void testEntityNameCanBeChanged()
    {
        Entity testEntity = new Entity( "anything" );
        testEntity.name = "otherThing";
        assert( testEntity.name == "otherThing" );
    }

    void testChangingEntityNameDispatchesSignal()
    {
        Entity testEntity = new Entity( "anything" );
        class Watcher 
        { 
            void watch( Entity e, string oldName ) 
            { 
                assert( e is testEntity );
                assert( e.name == "otherThing" );
                assert( oldName == "anything" );
            } 
        }
        Watcher testWatch = new Watcher();

        testEntity.nameChanged.connect( &testWatch.watch );
    }

}


class MockComponent: Component
{
    int value1;
}

class MockComponent2: Component
{
    int value2;
}

class MockComponentExtended: MockComponent
{
    int other;
}
