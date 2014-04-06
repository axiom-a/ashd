/**
 * This is a state machine for an entity. The state machine manages a set of states,
 * each of which has a set of component providers. When the state machine changes the state, it removes
 * components associated with the previous state and adds components associated with the new state.
 */
module ashd.fsm.entityStateMachine;


import ashd.core.entity           : Entity;
import ashd.fsm.entityState       : EntityState;
import ashd.fsm.IComponentProvider: IComponentProvider;
import ashd.fsm.ISystemProvider   : ISystemProvider;


public class EntityStateMachine
{
    private
    {
        Entity              mEntity;            // The entity whose state machine this is
        EntityState[string] mStates;            // available states
        EntityState         mCurrentState;      // The current state of the state machine.
    }

    /**
     * Constructor. Creates an EntityStateMachine.
     */
    public this( Entity entity_a )
    {
        mEntity = entity_a;
    }

    /**
     * Add a state to this state machine.
     * 
     * @param name The name of this state - used to identify it later in the changeState method call.
     * @param state The state.
     * @return This state machine, so methods can be chained.
     */
    public EntityStateMachine addState( string name_a, EntityState state_a )
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
    public EntityState createState( string name_a )
    {
        EntityState state = new EntityState();
        mStates[name_a] = state;
        return state;
    }

    /**
     * Change to a new state. The components from the old state will be removed and the components
     * for the new state will be added.
     * 
     * @param name The name of the state to change to.
     */
    public void changeState( string name_a )
    {
        if ( name_a !in mStates )
        {
            throw new Exception( "State '" ~ name_a ~ "' does not exist." );
        }

        EntityState newState = mStates[name_a];
        if ( newState == mCurrentState )
        {
            newState = null;
            return;
        }

        IComponentProvider[ClassInfo] toAdd = newState.providers();

        if ( mCurrentState )
        {
            foreach ( ClassInfo key, IComponentProvider t; mCurrentState.providers() )
            {
                IComponentProvider other;
                if ( key in toAdd )
                    other = toAdd[key];

                if ( other && other.identifier == mCurrentState.providers[key].identifier )
                {
                    toAdd.remove(key);
                }
                else
                {
                    mEntity.remove( key );
                }
            }
        }

        foreach ( ClassInfo key, IComponentProvider provider; toAdd )
        {
            mEntity.add( provider.getComponent( key ), key );
        }
        mCurrentState = newState;
    }
}
