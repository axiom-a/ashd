/**
 * Represents a state for a SystemStateMachine. The state contains any number of SystemProviders which
 * are used to add Systems to the Engine when this state is entered.
 */
module ashd.fsm.engineState;

import std.conv: to;

import ashd.core.system                : System;
import ashd.fsm.dynamicSystemProvider  : DynamicSystemProvider;
import ashd.fsm.ISystemProvider        : ISystemProvider;
import ashd.fsm.systemInstanceProvider : SystemInstanceProvider;
import ashd.fsm.systemSingletonProvider: SystemSingletonProvider;



public class EngineState
{
    private
    {
        ISystemProvider[ClassInfo] mProviders;
    }

    ISystemProvider[ClassInfo] providers() { return mProviders; }

    /**
     * Creates a mapping for the System type to a specific System instance. A
     * SystemInstanceProvider is used for the mapping.
     *
     * @param system The System instance to use for the mapping
     * @return This StateSystemMapping, so more modifications can be applied
     */
    public StateSystemMapping addInstance(T)( T system_a )
    {
        return this.addProvider( new SystemInstanceProvider!T( system_a ), T.classinfo );
    }

    /**
     * Creates a mapping for the System type to a single instance of the provided type.
     * The instance is not created until it is first requested. The type should be the same
     * as or extend the type for this mapping. A SystemSingletonProvider is used for
     * the mapping.
     *
     * @param type The type of the single instance to be created. If omitted, the type of the
     * mapping is used.
     * @return This StateSystemMapping, so more modifications can be applied
     */
    public StateSystemMapping addSingleton( ClassInfo type_a )
    {
        return addProvider( new SystemSingletonProvider( type_a ), type_a );

    }

    /**
     * Creates a mapping for the System type to a method call.
     * The method should return a System instance. A DynamicSystemProvider is used for
     * the mapping.
     *
     * @param method The method to provide the System instance.
     * @return This StateSystemMapping, so more modifications can be applied.
     */
    public StateSystemMapping addMethod(T)( T delegate() method_a )
    {
        return addProvider( new DynamicSystemProvider( method_a ), T.classinfo );
    }

    /**
     * Adds any SystemProvider.
     *
     * @param provider The component provider to use.
     * @return This StateSystemMapping, so more modifications can be applied.
     */
    public StateSystemMapping addProvider( ISystemProvider provider_a, ClassInfo class_a )
    {
        StateSystemMapping mapping = new StateSystemMapping( this, provider_a );
        mProviders[class_a] = provider_a;
        return mapping;
    }
}



class StateSystemMapping
{
    private
    {
        EngineState     mCreatingState;
        ISystemProvider mProvider;
    }

    /**
     * Used internally, the constructor creates a component mapping. The constructor
     * creates a SystemSingletonProvider as the default mapping, which will be replaced
     * by more specific mappings if other methods are called.
     *
     * @param creatingState The SystemState that the mapping will belong to
     * @param type The System type for the mapping
     */
    private this( EngineState creatingState_a, ISystemProvider provider_a )
    {
        mCreatingState = creatingState_a;
        mProvider = provider_a;
    }

    /**
     * Applies the priority to the provider that the System will be.
     *
     * @param priority The component provider to use.
     * @return This StateSystemMapping, so more modifications can be applied.
     */
    public StateSystemMapping withPriority( int priority_a )
    {
        mProvider.priority = priority_a;
        return this;
    }

    /**
     * Creates a mapping for the System type to a specific System instance. A
     * SystemInstanceProvider is used for the mapping.
     *
     * @param system The System instance to use for the mapping
     * @return This StateSystemMapping, so more modifications can be applied
     */
    public StateSystemMapping addInstance(T)( System system_a )
    {
        return mCreatingState.addInstance!T( system_a );
    }

    /**
     * Creates a mapping for the System type to a single instance of the provided type.
     * The instance is not created until it is first requested. The type should be the same
     * as or extend the type for this mapping. A SystemSingletonProvider is used for
     * the mapping.
     *
     * @param type The type of the single instance to be created. If omitted, the type of the
     * mapping is used.
     * @return This StateSystemMapping, so more modifications can be applied
     */
    public StateSystemMapping addSingleton( ClassInfo type_a )
    {
        return mCreatingState.addSingleton( type_a );
    }

    /**
     * Creates a mapping for the System type to a method call.
     * The method should return a System instance. A DynamicSystemProvider is used for
     * the mapping.
     *
     * @param method The method to provide the System instance.
     * @return This StateSystemMapping, so more modifications can be applied.
     */
    public StateSystemMapping addMethod( Object delegate() method_a )
    {
        return mCreatingState.addMethod( method_a );
    }

    /**
     * Maps through to the addProvider method of the SystemState that this mapping belongs to
     * so that a fluent interface can be used when configuring entity states.
     *
     * @param provider The component provider to use.
     * @return This StateSystemMapping, so more modifications can be applied.
     */
    public StateSystemMapping addProvider( ISystemProvider provider_a, ClassInfo class_a )
    {
        return mCreatingState.addProvider( provider_a, class_a );
    }
}

