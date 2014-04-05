/**
 * Unit tests for dynamicComponentProvider.d
 *
 */
import ashd.core.component               : Component;
import ashd.fsm.dynamicComponentProvider : DynamicComponentProvider;

int main()
{
    (new DynamicComponentProviderTests).providerReturnsTheInstance();
    (new DynamicComponentProviderTests).providersWithSameMethodHaveSameIdentifier();
    (new DynamicComponentProviderTests).providersWithDifferentMethodsHaveDifferentIdentifier();

    return 0;
}




public class DynamicComponentProviderTests
{
    public void providerReturnsTheInstance()
    {
        MockComponent instance = new MockComponent();
        Object providerMethod() { return instance; }
        auto provider = new DynamicComponentProvider!MockComponent( &providerMethod );
        assert( provider.getComponent!MockComponent() is instance );
    }

    public void providersWithSameMethodHaveSameIdentifier()
    {
        MockComponent instance = new MockComponent();
        Object providerMethod() { return instance; }
        auto provider1 = new DynamicComponentProvider!MockComponent( &providerMethod );
        auto provider2 = new DynamicComponentProvider!MockComponent( &providerMethod );
        assert( provider1.identifier == provider2.identifier );
    }

    public void providersWithDifferentMethodsHaveDifferentIdentifier()
    {
        MockComponent instance = new MockComponent();
        Object providerMethod1() { return instance; }
        Object providerMethod2() { return instance; }
        auto provider1 = new DynamicComponentProvider!MockComponent( &providerMethod1 );
        auto provider2 = new DynamicComponentProvider!MockComponent( &providerMethod2 );
        assert( provider1.identifier != provider2.identifier);
    }
}

class MockComponent
{
    public int value;
}
