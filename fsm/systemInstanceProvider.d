/**
 * This System provider always returns the same instance of the component. The system
 * is passed to the provider at initialisation.
 */
module ashd.fsm.systemInstanceProvider;


import ashd.core.system        : System;
import ashd.fsm.ISystemProvider: ISystemProvider;


public class SystemInstanceProvider(T): ISystemProvider
{
    private
    {
        T   mInstance;
        int mSystemPriority;
    }

    /**
     * Constructor
     *
     * @param instance The instance to return whenever a System is requested.
     */
    public this ( T instance_a )
    {
        mInstance = instance_a;
    }

    /**
     * Used to request a component from this provider
     *
     * @return The instance of the System
     */
    protected Object createDynamicInstance( ClassInfo type_a ){ return mInstance; }


    @property
    {
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

        /**
         * The priority at which the System should be added to the Engine
         */
        public int  priority() { return mSystemPriority; }
        public void priority( int value_a ) { mSystemPriority = value_a; }

    }
}
