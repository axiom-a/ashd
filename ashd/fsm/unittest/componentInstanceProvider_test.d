/**
 * Unit tests for componentInstanceProvider.d
 *
 */
import ashd.core.component                : Component;
import ashd.fsm.componentInstanceProvider : ComponentInstanceProvider;

int main()
{
    (new ComponentInstanceProviderTests).providerReturnsTheInstance();
    (new ComponentInstanceProviderTests).providersWithSameInstanceHaveSameIdentifier();
    (new ComponentInstanceProviderTests).providersWithDifferentInstanceHaveDifferentIdentifier();

    return 0;
}





public class ComponentInstanceProviderTests
{
    public void providerReturnsTheInstance()
    {
        MockComponent instance = new MockComponent();
        ComponentInstanceProvider!MockComponent provider = new ComponentInstanceProvider!MockComponent( instance );
        assert( provider.getComponent!MockComponent() is instance );
    }

    public void providersWithSameInstanceHaveSameIdentifier()
    {
        MockComponent instance = new MockComponent();
        ComponentInstanceProvider!MockComponent provider1 = new ComponentInstanceProvider!MockComponent( instance );
        ComponentInstanceProvider!MockComponent provider2 = new ComponentInstanceProvider!MockComponent( instance );
        assert( provider1.identifier == provider2.identifier );
    }

    public void providersWithDifferentInstanceHaveDifferentIdentifier()
    {
        ComponentInstanceProvider!MockComponent provider1 = new ComponentInstanceProvider!MockComponent( new MockComponent );
        ComponentInstanceProvider!MockComponent provider2 = new ComponentInstanceProvider!MockComponent( new MockComponent );
        assert( provider1.identifier != provider2.identifier );
    }
}

class MockComponent: Component
{
    public int value;
}
