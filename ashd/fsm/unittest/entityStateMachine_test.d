/**
 * Unit tests for entityState.d
 *
 */
import ashd.core.component           : Component;
import ashd.core.entity              : Entity;
import ashd.fsm.componentTypeProvider: ComponentTypeProvider;
import ashd.fsm.entityState          : EntityState;
import ashd.fsm.entityStateMachine   : EntityStateMachine;
import ashd.fsm.IComponentProvider   : IComponentProvider;






int main()
{
    (new EntityStateMachineTests).enterStateAddsStatesComponents();
    (new EntityStateMachineTests).enterSecondStateAddsSecondStatesComponents();
    (new EntityStateMachineTests).enterSecondStateRemovesFirstStatesComponents();
    (new EntityStateMachineTests).enterSecondStateDoesNotRemoveOverlappingComponents();
    (new EntityStateMachineTests).enterSecondStateRemovesDifferentComponentsOfSameType();

    return 0;
}



public class EntityStateMachineTests
{

    EntityStateMachine mFsm;
    Entity mEntity;

    public this()
    {
        mEntity = new Entity();
        mFsm = new EntityStateMachine( mEntity );
    }

    public void enterStateAddsStatesComponents()
    {
        EntityState state = new EntityState();
        MockComponent component = new MockComponent();
        state.add( typeid(MockComponent) ).withInstance!MockComponent( component );
        mFsm.addState( "test", state );
        mFsm.changeState( "test" );
        assert( mEntity.get!MockComponent() is component );
    }

    public void enterSecondStateAddsSecondStatesComponents()
    {
        EntityState state1 = new EntityState();
        MockComponent component1 = new MockComponent();
        state1.add( typeid(MockComponent) ).withInstance!MockComponent( component1 );
        mFsm.addState( "test1", state1 );
        mFsm.changeState( "test1" );

        EntityState state2 = new EntityState();
        MockComponent2 component2 = new MockComponent2();
        state2.add( typeid(MockComponent2) ).withInstance!MockComponent2( component2 );
        mFsm.addState( "test2", state2 );
        mFsm.changeState( "test2" );

        assert( mEntity.get!MockComponent2() is component2 );
    }

    public void enterSecondStateRemovesFirstStatesComponents()
    {
        EntityState state1 = new EntityState();
        MockComponent component1 = new MockComponent();
        state1.add( typeid(MockComponent) ).withInstance!MockComponent( component1 );
        mFsm.addState( "test1", state1 );
        mFsm.changeState( "test1" );

        EntityState state2 = new EntityState();
        MockComponent2 component2 = new MockComponent2();
        state2.add( typeid(MockComponent2) ).withInstance!MockComponent2( component2 );
        mFsm.addState( "test2", state2 );
        mFsm.changeState( "test2" );

        assert( mEntity.has!MockComponent() == false );
    }

    public void enterSecondStateDoesNotRemoveOverlappingComponents()
    {   
        class Watcher 
        { 
            void failIfCalled( Entity entity_a, ClassInfo class_a )
            {
                assert( "Component was removed when it shouldn't have been." );
            }
        }
        Watcher testWatch = new Watcher();

        mEntity.componentRemoved.connect( &testWatch.failIfCalled );
        
        EntityState state1 = new EntityState();
        MockComponent component1 = new MockComponent();
        state1.add( typeid(MockComponent) ).withInstance!MockComponent( component1 );
        mFsm.addState( "test1", state1 );
        mFsm.changeState( "test1" );

        EntityState state2 = new EntityState();
        MockComponent2 component2 = new MockComponent2();
        state2.add( typeid(MockComponent) ).withInstance!MockComponent( component1 );
        state2.add( typeid(MockComponent2) ).withInstance!MockComponent2( component2 );
        mFsm.addState( "test2", state2 );
        mFsm.changeState( "test2" );

        assert( mEntity.get!MockComponent() is component1 );
    }

    public void enterSecondStateRemovesDifferentComponentsOfSameType()
    {
        EntityState state1 = new EntityState();
        MockComponent component1 = new MockComponent();
        state1.add( typeid(MockComponent) ).withInstance!MockComponent( component1 );
        mFsm.addState( "test1", state1 );
        mFsm.changeState( "test1" );

        EntityState state2 = new EntityState();
        MockComponent component3 = new MockComponent();
        MockComponent2 component2 = new MockComponent2();
        state2.add( typeid(MockComponent) ).withInstance!MockComponent( component3 );
        state2.add( typeid(MockComponent2) ).withInstance!MockComponent2( component2 );
        mFsm.addState( "test2", state2 );
        mFsm.changeState( "test2" );

        assert( mEntity.get!MockComponent() is component3 );
    }
}

class MockComponent: Component
{
    public int value;
}

class MockComponent2: Component
{
    public string value;
}
