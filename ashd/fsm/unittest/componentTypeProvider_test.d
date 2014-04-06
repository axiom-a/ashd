/**
 * Unit tests for componentTypeProvider.d
 *
 */
import ashd.core.component            : Component;
import ashd.fsm.componentTypeProvider : ComponentTypeProvider;

int main()
{
    (new ComponentTypeProviderTests).providerReturnsAnInstanceOfType();
    (new ComponentTypeProviderTests).providerReturnsNewInstanceEachTime();
    (new ComponentTypeProviderTests).providersWithSameTypeHaveSameIdentifier();
    (new ComponentTypeProviderTests).providersWithDifferentTypeHaveDifferentIdentifier();

    return 0;
}


public class ComponentTypeProviderTests
{
    public void providerReturnsAnInstanceOfType()
    {
        ComponentTypeProvider provider = new ComponentTypeProvider( typeid(MockComponent) );
        assert( provider.getComponent!MockComponent().classinfo == MockComponent.classinfo );
    }

    public void providerReturnsNewInstanceEachTime()
    {
        ComponentTypeProvider provider = new ComponentTypeProvider( typeid(MockComponent) );
        assert( provider.getComponent!MockComponent() !is provider.getComponent!MockComponent() );
    }

    public void providersWithSameTypeHaveSameIdentifier()
    {
        ComponentTypeProvider provider1 = new ComponentTypeProvider( typeid(MockComponent) );
        ComponentTypeProvider provider2 = new ComponentTypeProvider( typeid(MockComponent) );
        assert( provider1.identifier == provider2.identifier );
    }

    public void providersWithDifferentTypeHaveDifferentIdentifier()
    {
        ComponentTypeProvider provider1 = new ComponentTypeProvider( typeid(MockComponent) );
        ComponentTypeProvider provider2 = new ComponentTypeProvider( typeid(MockComponent2) );
        assert( provider1.identifier != provider2.identifier );
    }
}

class MockComponent
{
    public int value;
}

class MockComponent2
{
    public string value;
}
