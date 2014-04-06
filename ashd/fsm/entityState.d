/**
 * Represents a state for an EntityStateMachine. The state contains any number of ComponentProviders which
 * are used to add components to the entity when this state is entered.
 */
module ashd.fsm.entityState;

import std.conv: to;


import ashd.core.component                : Component;
import ashd.fsm.componentInstanceProvider : ComponentInstanceProvider;
import ashd.fsm.componentSingletonProvider: ComponentSingletonProvider;
import ashd.fsm.componentTypeProvider     : ComponentTypeProvider;
import ashd.fsm.dynamicComponentProvider  : DynamicComponentProvider;
import ashd.fsm.IComponentProvider        : IComponentProvider;


///
public class EntityState
{
    private
    {
        IComponentProvider[ClassInfo] mProviders;
    }


    @property IComponentProvider[ClassInfo] providers() { return mProviders; };

    /**
     * Add a new ComponentMapping to this state. The mapping is a utility class that is used to
     * map a component type to the provider that provides the component.
     * 
     * @param type The type of component to be mapped
     * @return The component mapping to use when setting the provider for the component
     */
    public StateComponentMapping add( ClassInfo class_a )
    {
        return new StateComponentMapping( this, class_a );
    }
   
    /**
     * Get the ComponentProvider for a particular component type.
     * 
     * @param type The type of component to get the provider for
     * @return The ComponentProvider
     */
    public IComponentProvider get( ClassInfo class_a )
    {
        if ( class_a in mProviders )
            return mProviders[ class_a ];
        else
            return null;
    }


    /**
     * To determine whether this state has a provider for a specific component type.
     * 
     * @param type The type of component to look for a provider for
     * @return true if there is a provider for the given type, false otherwise
     */
    public bool has( ClassInfo class_a )
    {
        return ( class_a in mProviders) != null;
    }

}


/**
 * Used by the EntityState class to create the mappings of components to providers via a fluent interface.
 */
private class StateComponentMapping
{
    private
    {
        EntityState        mCreatingState;
        IComponentProvider mProvider;
        ClassInfo          mComponentType;
    }

    /**
     * Used internally, the constructor creates a component mapping. The constructor
     * creates a ComponentTypeProvider as the default mapping, which will be replaced
     * by more specific mappings if other methods are called.
     *
     * @param creatingState The EntityState that the mapping will belong to
     * @param type The component type for the mapping
     */
    public this( EntityState creatingState_a, ClassInfo class_a )
    {
        mCreatingState = creatingState_a;
        mComponentType = class_a;
        this.withType( class_a );
    }

    /**
     * Creates a mapping for the component type to a specific component instance. A
     * ComponentInstanceProvider is used for the mapping.
     *
     * @param component The component instance to use for the mapping
     * @return This ComponentMapping, so more modifications can be applied
     */
    public StateComponentMapping withInstance(T)( T component_a )
    {
        setProvider( new ComponentInstanceProvider!T( component_a ), T.classinfo );
        return this;
    }

    /**
     * Creates a mapping for the component type to new instances of the provided type.
     * The type should be the same as or extend the type for this mapping. A ComponentTypeProvider
     * is used for the mapping.
     *
     * @param type The type of components to be created by this mapping
     * @return This ComponentMapping, so more modifications can be applied
     */
    public StateComponentMapping withType( ClassInfo type_a )
    {
        setProvider( new ComponentTypeProvider( type_a ), type_a );
        return this;
    }

    /**
     * Creates a mapping for the component type to a single instance of the provided type.
     * The instance is not created until it is first requested. The type should be the same
     * as or extend the type for this mapping. A ComponentSingletonProvider is used for
     * the mapping.
     *
     * @param The type of the single instance to be created. If omitted, the type of the
     * mapping is used.
     * @return This ComponentMapping, so more modifications can be applied
     */
    public StateComponentMapping withSingleton( ClassInfo type_a = null )
    {
        if ( !type_a )
        {
            type_a = mComponentType;
        }
        setProvider( new ComponentSingletonProvider( type_a ), type_a );
        return this;
    }

    /**
     * Creates a mapping for the component type to a method call. A
     * DynamicComponentProvider is used for the mapping.
     *
     * @param method The method to return the component instance
     * @return This ComponentMapping, so more modifications can be applied
     */
    public StateComponentMapping withMethod(T)( T delegate() method_a )
    {
        setProvider( new DynamicComponentProvider!T( method_a ), T.classinfo );
        return this;
    }
 
    /**
     * Creates a mapping for the component type to any ComponentProvider.
     *
     * @param provider The component provider to use.
     * @return This ComponentMapping, so more modifications can be applied.
     */
    public StateComponentMapping withProvider( IComponentProvider provider_a, ClassInfo class_a )
    {
        setProvider( provider_a, class_a );
        return this;
    }

    /**
     * Maps through to the add method of the EntityState that this mapping belongs to
     * so that a fluent interface can be used when configuring entity states.
     *
     * @param type The type of component to add a mapping to the state for
     * @return The new ComponentMapping for that type
     */
    public StateComponentMapping add( ClassInfo class_a )
    {
        return mCreatingState.add( class_a );
    }

    private void setProvider( IComponentProvider provider_a, ClassInfo class_a )
    {
        mProvider = provider_a;

        mCreatingState.mProviders[ class_a ] = provider_a;
    }
}

