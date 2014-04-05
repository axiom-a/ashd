/**
 * Unit tests for entityState.d
 *
 */
import ashd.fsm.componentTypeProvider: ComponentTypeProvider;
import ashd.fsm.entityState          : EntityState;
import ashd.fsm.IComponentProvider   : IComponentProvider;



int main()
{
    (new EntityStateTests).addWithNoQualifierCreatesTypeProvider();
    (new EntityStateTests).addWithTypeQualifierCreatesTypeProvider();
    (new EntityStateTests).addWithInstanceQualifierCreatesInstanceProvider();
    (new EntityStateTests).addWithSingletonQualifierCreatesSingletonProvider();
    (new EntityStateTests).addWithMethodQualifierCreatesDynamicProvider();

    return 0;
}



public class EntityStateTests
{
    EntityState           mState;

    public this()
    {
        mState = new EntityState( );
    }

    
    public void addWithNoQualifierCreatesTypeProvider()
    {
        mState.add( typeid(MockComponent) );
        IComponentProvider provider = mState.get( typeid(MockComponent) );
        assert( (provider.getComponent!MockComponent()).classinfo == MockComponent.classinfo );
    }


    public void addWithTypeQualifierCreatesTypeProvider()
    {
        mState.add( typeid(MockComponent) ).withType( typeid(MockComponent2) );
        IComponentProvider provider = mState.get( typeid(MockComponent) );
        assert( (provider.getComponent!MockComponent2()).classinfo == MockComponent2.classinfo );
    }

    public void addWithInstanceQualifierCreatesInstanceProvider()
    {
        MockComponent component = new MockComponent();
        mState.add( typeid(MockComponent) ).withInstance!MockComponent( component );
        IComponentProvider provider = mState.get( typeid(MockComponent) );
        assert( provider.getComponent!MockComponent() is component );
    }

    public void addWithSingletonQualifierCreatesSingletonProvider()
    {
        mState.add( typeid(MockComponent) ).withSingleton( typeid(MockComponent) );
        IComponentProvider provider = mState.get( typeid(MockComponent) );
        assert( (provider.getComponent!MockComponent()).classinfo == MockComponent.classinfo );
    }

    public void addWithMethodQualifierCreatesDynamicProvider()
    {
        MockComponent dynamicProvider() { return new MockComponent(); } 
        mState.add( typeid(MockComponent) ).withMethod!MockComponent( &dynamicProvider );
        IComponentProvider provider = mState.get( typeid(MockComponent ) );
        assert( (provider.getComponent!MockComponent()).classinfo == MockComponent.classinfo );
    }


}

class MockComponent
{
    public int value;
}

class MockComponent2: MockComponent
{
    
}



