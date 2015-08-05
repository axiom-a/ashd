/**
 * Unit tests for systemState.d
 *
 */
module systemState_test;


import ashd.core.system         : System;
import ashd.fsm.engineState     : EngineState;
import ashd.fsm.ISystemProvider : ISystemProvider;



int main()
{
    (new SystemStateTests).addInstanceCreatesInstanceProvider();
    (new SystemStateTests).addSingletonCreatesSingletonProvider();
    (new SystemStateTests).addMethodCreatesMethodProvider();
    (new SystemStateTests).withPrioritySetsPriorityOnProvider();


    return 0;
}






public class SystemStateTests
{
    private EngineState mState;

    this()
    {
        mState = new EngineState();
    }

    public void addInstanceCreatesInstanceProvider()
    {
        MockSystem system1 = new MockSystem();
        mState.addInstance!MockSystem( system1 );
        assert( mState.providers().length == 1 );
        ISystemProvider[ClassInfo] providers = mState.providers;
        assert( MockSystem.classinfo in providers );
        assert( providers[MockSystem.classinfo].getSystem!MockSystem() is system1 );
    }

    public void addSingletonCreatesSingletonProvider()
    {
        mState.addSingleton( typeid(MockSystem) );
        ISystemProvider[ClassInfo] providers = mState.providers;
        assert( MockSystem.classinfo in providers );
        assert( providers[MockSystem.classinfo].getSystem!MockSystem().classinfo == MockSystem.classinfo );
    }

    public void addMethodCreatesMethodProvider()
    {
        MockSystem system = new MockSystem();
        MockSystem methodProvider() { return new MockSystem(); }

        mState.addMethod( &methodProvider );
        ISystemProvider[ClassInfo] providers = mState.providers;
        assert( MockSystem.classinfo in providers );
        assert( providers[MockSystem.classinfo].getSystem!MockSystem().classinfo == MockSystem.classinfo );
    }

    public void withPrioritySetsPriorityOnProvider()
    {
        int priority = 10;
        mState.addSingleton( typeid(MockSystem)).withPriority( priority );
        ISystemProvider[ClassInfo] providers = mState.providers;
        assert( MockSystem.classinfo in providers );
        assert( providers[MockSystem.classinfo].priority == priority );
    }
}


class MockSystem: System
{
    float dummy;
}
