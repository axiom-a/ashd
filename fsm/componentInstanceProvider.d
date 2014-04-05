/**
 * This component provider always returns the same instance of the component. The instance
 * is passed to the provider at initialisation.
 */

module ashd.fsm.componentInstanceProvider;

import ashd.core.component        : Component;
import ashd.fsm.IComponentProvider: IComponentProvider;

public class ComponentInstanceProvider(T): IComponentProvider
{
    private T mInstance;
    
    /**
     * Constructor
     * 
     * @param instance The instance to return whenever a component is requested.
     */
    public this( T instance_a )
    {
        mInstance = instance_a;
    }
    
    /**
     * Used to request a component from this provider
     * 
     * @return The instance
     */
    protected Object createDynamicInstance( ClassInfo type_a ){ return mInstance; }

    /**
     * Used to compare this provider with others. Any provider that returns the same component
     * instance will be regarded as equivalent.
     * 
     * @return The instance
     */
    public hash_t identifier()
    {
        return mInstance.toHash();
    }

}
