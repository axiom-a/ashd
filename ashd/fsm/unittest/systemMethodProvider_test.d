/**
 * Unit tests for systemMethodProvider.d
 *
 */
module systemMethodProvider_test;

import ashd.core.system              : System;
import ashd.fsm.dynamicSystemProvider: DynamicSystemProvider;

int main()
{
    (new SystemMethodProviderTests).providerReturnsTheInstance();
    (new SystemMethodProviderTests).providersWithSameMethodHaveSameIdentifier();
    (new SystemMethodProviderTests).providersWithDifferentMethodHaveDifferentIdentifier();

    return 0;
}





public class SystemMethodProviderTests
{
    public void providerReturnsTheInstance()
    {
        MockSystem instance = new MockSystem();
        Object providerMethod() { return instance; }

        DynamicSystemProvider provider = new DynamicSystemProvider( &providerMethod );
        assert( provider.getSystem!MockSystem() is instance );
    }

    public void providersWithSameMethodHaveSameIdentifier()
    {
        MockSystem instance = new MockSystem();
        Object providerMethod() { return instance; }
        DynamicSystemProvider provider1 = new DynamicSystemProvider( &providerMethod );
        DynamicSystemProvider provider2 = new DynamicSystemProvider( &providerMethod );
        assert( provider1.identifier == provider2.identifier );
    }

    public void providersWithDifferentMethodHaveDifferentIdentifier()
    {
        MockSystem instance = new MockSystem();
        Object providerMethod1() { return instance; }
        Object providerMethod2() { return instance; }

        DynamicSystemProvider provider1 = new DynamicSystemProvider( &providerMethod1 );
        DynamicSystemProvider provider2 = new DynamicSystemProvider( &providerMethod2 );
        assert( provider1.identifier != provider2.identifier );
    }
}

class MockSystem: System
{
    uint dummy;
}
