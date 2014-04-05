/**
 * This System provider returns results of a method call. The method
 * is passed to the provider at initialisation.
 */
module ashd.fsm.dynamicSystemProvider;

import std.conv: to;

import ashd.core.system        : System;
import ashd.fsm.ISystemProvider: ISystemProvider;


public class DynamicSystemProvider: ISystemProvider
{
    private
    {
        Object delegate() mMethod;
        int               mSystemPriority;
    }

    /**
     * Constructor
     *
     * @param method The method that returns the System instance;
     */
    public this( Object delegate() method_a )
    {
        mMethod = method_a;
    }

    /**
     * Used to request a component from this provider
     *
     * @return The instance of the System
     */
    Object createDynamicInstance( ClassInfo type_a )
    {
        return mMethod();
    }

    /**
     * Used to compare this provider with others. Any provider that returns the same component
     * instance will be regarded as equivalent.
     *
     * @return The method used to call the System instances
     */
    public hash_t identifier()
    {
        return ISystemProvider.toHash( to!string(mMethod.funcptr) );
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
