/**
 * Unit tests for systemInstanceProvider.d
 *
 */
import ashd.core.system                : System;
import ashd.fsm.systemInstanceProvider : SystemInstanceProvider;

int main()
{
    (new SystemInstanceProviderTests).providerReturnsTheInstance();
    (new SystemInstanceProviderTests).providersWithSameInstanceHaveSameIdentifier();
    (new SystemInstanceProviderTests).providersWithDifferentInstanceHaveDifferentIdentifier();

    return 0;
}


public class SystemInstanceProviderTests
{
    public void providerReturnsTheInstance()
    {
        MockSystem instance = new MockSystem();
        SystemInstanceProvider!MockSystem provider = new SystemInstanceProvider!MockSystem( instance );
        assert( provider.getSystem!MockSystem() is instance );
    }

    public void providersWithSameInstanceHaveSameIdentifier()
    {
        MockSystem instance = new MockSystem();
        SystemInstanceProvider!MockSystem provider1 = new SystemInstanceProvider!MockSystem( instance );
        SystemInstanceProvider!MockSystem provider2 = new SystemInstanceProvider!MockSystem( instance );
        assert( provider1.identifier == provider2.identifier );
    }

    public void providersWithDifferentInstanceHaveDifferentIdentifier()
    {
        SystemInstanceProvider!MockSystem provider1 = new SystemInstanceProvider!MockSystem( new MockSystem() );
        SystemInstanceProvider!MockSystem provider2 = new SystemInstanceProvider!MockSystem( new MockSystem() );
        assert( provider1.identifier != provider2.identifier );
    }
}


class MockSystem: System
{
    public int value;
}
