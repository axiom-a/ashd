/**
 * Unit tests for componentSingletonProvider.d
 *
 */
import ashd.core.component                : Component;
import ashd.fsm.componentSingletonProvider: ComponentSingletonProvider;

int main()
{
    (new ComponentSingletonProviderTests).providerReturnsAnInstanceOfType();
    (new ComponentSingletonProviderTests).providerReturnsSameInstanceEachTime();
    (new ComponentSingletonProviderTests).providersWithSameTypeHaveDifferentIdentifier();
    (new ComponentSingletonProviderTests).providersWithDifferentTypeHaveDifferentIdentifier();

    return 0;
}







public class ComponentSingletonProviderTests
{
    public void providerReturnsAnInstanceOfType()
    {
        ComponentSingletonProvider provider = new ComponentSingletonProvider( typeid(MockComponent) );
        assert( provider.getComponent!MockComponent().classinfo == MockComponent.classinfo );
    }

    public void providerReturnsSameInstanceEachTime()
    {
        ComponentSingletonProvider provider = new ComponentSingletonProvider( typeid(MockComponent) );
        assert( provider.getComponent!MockComponent().toHash == provider.getComponent!MockComponent().toHash );
    }

    public void providersWithSameTypeHaveDifferentIdentifier()
    {
        ComponentSingletonProvider provider1 = new ComponentSingletonProvider( typeid(MockComponent) );
        ComponentSingletonProvider provider2 = new ComponentSingletonProvider( typeid(MockComponent) );
        assert( provider1.identifier != provider2.identifier );
    }

    public void providersWithDifferentTypeHaveDifferentIdentifier()
    {
        ComponentSingletonProvider provider1 = new ComponentSingletonProvider( typeid(MockComponent) );
        ComponentSingletonProvider provider2 = new ComponentSingletonProvider( typeid(MockComponent2) );
        assert( provider1.identifier != provider2.identifier );
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
