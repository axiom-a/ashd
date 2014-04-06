/**
 * This is a state machine for the Engine. The state machine manages a set of states,
 * each of which has a set of System providers. When the state machine changes the state, it removes
 * Systems associated with the previous state and adds Systems associated with the new state.
 */
module ashd.fsm.engineStateMachine;

import ashd.core.engine        : Engine;
import ashd.core.system        : System;
import ashd.fsm.engineState    : EngineState;
import ashd.fsm.ISystemProvider: ISystemProvider;




public class EngineStateMachine
{
    private
    {
        Engine              mEngine;
        EngineState[string] mStates;
        EngineState         mCurrentState;
    }
    /**
     * Constructor. Creates an SystemStateMachine.
     */
    public this( Engine engine_a )
    {
        mEngine = engine_a;
    }

    /**
     * Add a state to this state machine.
     *
     * @param name The name of this state - used to identify it later in the changeState method call.
     * @param state The state.
     * @return This state machine, so methods can be chained.
     */
    public EngineStateMachine addState( string name_a, EngineState state_a )
    {
        mStates[name_a] = state_a;
        return this;
    }

    /**
     * Create a new state in this state machine.
     *
     * @param name The name of the new state - used to identify it later in the changeState method call.
     * @return The new EntityState object that is the state. This will need to be configured with
     * the appropriate component providers.
     */
    public EngineState createState( string name_a )
    {
        EngineState state = new EngineState();

        mStates[name_a] = state;
        return state;
    }

    /**
     * Change to a new state. The Systems from the old state will be removed and the Systems
     * for the new state will be added.
     *
     * @param name The name of the state to change to.
     */
    public void changeState( string name_a )
    {
        if ( name_a !in mStates )
        {
            throw( new Exception( "Engine state "~name_a~" doesn't exist" ) );
        }

        EngineState newState = mStates[name_a];
        if ( newState == mCurrentState )
        {
            newState = null;
            return;
        }


        ISystemProvider[ClassInfo] toAdd = newState.providers();

        if ( mCurrentState )
        {
            foreach ( key, provider; mCurrentState.providers )
            {
                hash_t id = provider.identifier;
                if ( (key in toAdd) && (toAdd[key].identifier == id) )
                {
                    toAdd.remove(key);
                }
                else
                {
                    mEngine.removeSystem( provider.getSystem(key) );
                }
            }
        }

        foreach ( key, provider; toAdd )
        {
            System tmpSystem = provider.getSystem(key);
            mEngine.addSystem( tmpSystem, key, provider.priority );
        }
        mCurrentState = newState;
    }
}
