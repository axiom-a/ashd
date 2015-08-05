/**
 * Unit tests for systemSingletonProvider.d
 *
 */
module systemSingletonProvider_test;

import ashd.core.system                : System;
import ashd.fsm.systemSingletonProvider: SystemSingletonProvider;

int main()
{
    (new SystemSingletonProviderTests).providerReturnsAnInstanceOfSystem();
    (new SystemSingletonProviderTests).providerReturnsSameInstanceEachTime();
    (new SystemSingletonProviderTests).providersWithSameSystemHaveDifferentIdentifier();
    (new SystemSingletonProviderTests).providersWithDifferentSystemsHaveDifferentIdentifier();

    return 0;
}




public class SystemSingletonProviderTests
{
    public void providerReturnsAnInstanceOfSystem()
    {
        SystemSingletonProvider provider = new SystemSingletonProvider( typeid(MockSystem) );
        assert( provider.getSystem!MockSystem.classinfo == MockSystem.classinfo );
    }

    public void providerReturnsSameInstanceEachTime()
    {
        SystemSingletonProvider provider = new SystemSingletonProvider( typeid(MockSystem) );
        assert( provider.getSystem!MockSystem.classinfo == provider.getSystem!MockSystem.classinfo );
    }

    public void providersWithSameSystemHaveDifferentIdentifier()
    {
        SystemSingletonProvider provider1 = new SystemSingletonProvider( typeid(MockSystem) );
        SystemSingletonProvider provider2 = new SystemSingletonProvider( typeid(MockSystem) );
        assert( provider1.identifier != provider2.identifier );
    }

    public void providersWithDifferentSystemsHaveDifferentIdentifier()
    {
        SystemSingletonProvider provider1 = new SystemSingletonProvider( typeid(MockSystem) );
        SystemSingletonProvider provider2 = new SystemSingletonProvider( typeid(MockSystem2) );
        assert( provider1.identifier != provider2.identifier );
    }
}


class MockSystem: System
{
    public int value;
}

class MockSystem2: System
{
    public string value;
}
