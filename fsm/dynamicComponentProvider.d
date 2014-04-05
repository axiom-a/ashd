/**
 * This component provider calls a function to get the component instance. The function must
 * return a single component of the appropriate type.
 */
module ashd.fsm.dynamicComponentProvider;

import std.conv : to;

import ashd.fsm.IComponentProvider: IComponentProvider;



public class DynamicComponentProvider(T): IComponentProvider
{
    private 
    {
        Object delegate() mClosure;
    }

    /**
     * Constructor
     * 
     * @param closure The function that will return the component instance when called.
     */
    public this( Object delegate() closure_a )
    {
        mClosure = closure_a;
    }

    /**
     * Used to request a component from this provider
     * 
     * @return The instance returned by calling the function
     */
    Object createDynamicInstance( ClassInfo type_a )
    {
        return mClosure();
    }

    /**
     * Used to compare this provider with others. Any provider that uses the function or method 
     * closure to provide the instance is regarded as equivalent.
     * 
     * @return The function
     */
    public hash_t identifier()
    {
        return IComponentProvider.toHash( to!string(mClosure.funcptr) );
    }
}
