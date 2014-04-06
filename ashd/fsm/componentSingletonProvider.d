/**
 * This component provider always returns the same instance of the component. The instance
 * is created when first required and is of the type passed in to the constructor.
 */
module ashd.fsm.componentSingletonProvider;

import ashd.core.component        : Component;
import ashd.fsm.IComponentProvider: IComponentProvider;


public class ComponentSingletonProvider: IComponentProvider
{
    private
    {
        ClassInfo mComponentType;
        Object mInstance;
    }

    /**
     * Constructor
     * 
     * @param type The type of the single instance
     */
    public this( ClassInfo type_a )
    {
        mComponentType = type_a;
    }
    
    /**
     * Used to request a component from this provider
     * 
     * @return The single instance
     */
    protected Object createDynamicInstance( ClassInfo type_a )
    { 
        if( !mInstance )
        {
            mInstance = type_a.create();
        }
        return mInstance; 
    }
    
    /**
     * Used to compare this provider with others. Any provider that returns the same single
     * instance will be regarded as equivalent.
     * 
     * @return The single instance
     */
    public hash_t identifier()
    {
        if (!mInstance)
        {
            mInstance = mComponentType.create();
        }
        return mInstance.toHash();
    }
}
