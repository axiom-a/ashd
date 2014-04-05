/**
 * This System provider always returns the same instance of the System. The instance
 * is created when first required and is of the type passed in to the constructor.
 */
module ashd.fsm.systemSingletonProvider;


import ashd.core.system        : System;
import ashd.fsm.ISystemProvider: ISystemProvider;



public class SystemSingletonProvider: ISystemProvider
{
    private
    {
        ClassInfo mSystemType;
        Object    mInstance;
        int       mSystemPriority;
    }

    /**
     * Constructor
     *
     * @param type The type of the single System instance
     */
    public this( ClassInfo type_a )
    {
        mSystemType = type_a;
    }

    /**
     * Used to request a System from this provider
     *
     * @return The single instance
     */
    protected Object createDynamicInstance( ClassInfo type_a )
    {
        if ( !mInstance )
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
            mInstance = mSystemType.create();
        }
        return mInstance.toHash();
    }

    @property
    {
        /**
         * The priority at which the System should be added to the Engine
         */
        public int  priority() { return mSystemPriority; }
        public void priority( int value_a ) { mSystemPriority = value_a; }
    }
}
