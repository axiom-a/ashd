/**
 * Unit tests for engineStateMachine.d
 */
module engineStateMachine_test;


import ashd.core.engine           : Engine;
import ashd.core.iengine          : IEngine;
import ashd.core.system           : System;
import ashd.fsm.engineState       : EngineState;
import ashd.fsm.engineStateMachine: EngineStateMachine;


int main()
{
    (new EngineStateMachineTests).enterStateAddsStatesSystems();
    (new EngineStateMachineTests).enterSecondStateAddsSecondStatesSystems();
    (new EngineStateMachineTests).enterSecondStateRemovesFirstStatesSystems();
    (new EngineStateMachineTests).enterSecondStateDoesNotRemoveOverlappingSystems();
    (new EngineStateMachineTests).enterSecondStateRemovesDifferentSystemsOfSameType();

    return 0;
}


public class EngineStateMachineTests
{
    private
    {
        Engine mEngine;
        EngineStateMachine mFsm;
    }

    this()
    {
        mEngine = new Engine();
        mFsm = new EngineStateMachine( mEngine );
    }


    public void enterStateAddsStatesSystems()
    {
        EngineState state = new EngineState();
        MockSystem system = new MockSystem();
        state.addInstance( system );
        mFsm.addState( "test", state );
        mFsm.changeState( "test" );
        assert( mEngine.getSystem!MockSystem() is system );
    }

    public void enterSecondStateAddsSecondStatesSystems()
    {
        EngineState state1 = new EngineState();
        MockSystem system1 = new MockSystem();
        state1.addInstance( system1 );
        mFsm.addState( "test1", state1 );
        mFsm.changeState( "test1" );

        EngineState state2 = new EngineState();
        MockSystem2 system2 = new MockSystem2();
        state2.addInstance( system2 );
        mFsm.addState( "test2", state2 );
        mFsm.changeState( "test2" );

        assert( mEngine.getSystem!MockSystem2() is system2 );
    }

    public void enterSecondStateRemovesFirstStatesSystems()
    {
        EngineState state1 = new EngineState();
        MockSystem system1 = new MockSystem();
        state1.addInstance( system1 );
        mFsm.addState( "test1", state1 );
        mFsm.changeState( "test1" );

        EngineState state2 = new EngineState();
        MockSystem2 system2 = new MockSystem2();
        state2.addInstance( system2 );
        mFsm.addState( "test2", state2 );
        mFsm.changeState( "test2" );

        assert( mEngine.getSystem!MockSystem is null );
    }

    public void enterSecondStateDoesNotRemoveOverlappingSystems()
    {
        EngineState state1 = new EngineState();
        MockSystem system1 = new MockSystem();
        state1.addInstance( system1 );
        mFsm.addState( "test1", state1 );
        mFsm.changeState( "test1" );

        EngineState state2 = new EngineState();
        MockSystem2 system2 = new MockSystem2();
        state2.addInstance( system1 );
        state2.addInstance( system2 );
        mFsm.addState( "test2", state2 );
        mFsm.changeState( "test2" );

        assert( system1.wasRemoved == false );
        assert( mEngine.getSystem!MockSystem is system1 );
    }

    public void enterSecondStateRemovesDifferentSystemsOfSameType()
    {
        EngineState state1 = new EngineState();
        MockSystem system1 = new MockSystem();
        state1.addInstance( system1 );
        mFsm.addState( "test1", state1 );
        mFsm.changeState( "test1" );

        EngineState state2 = new EngineState();
        MockSystem system3 = new MockSystem();
        MockSystem2 system2 = new MockSystem2();
        state2.addInstance( system3 );
        state2.addInstance( system2 );
        mFsm.addState( "test2", state2 );
        mFsm.changeState( "test2" );

        assert( mEngine.getSystem!MockSystem is system3 );
    }
}



class MockSystem: System
{
    public bool wasRemoved = false;

    override public void removeFromEngine( IEngine engine_a )
    {
        wasRemoved = true;
    }

}

class MockSystem2: System
{
    public string value;
}
