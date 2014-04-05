
module ashd.fsm.ISystemProvider;

import std.conv: to;

import ashd.core.system: System;

public interface ISystemProvider
{
    /**
     * Used to request a system from this provider
     */
    T getSystem(T)()
    {
        auto i = cast(T)createDynamicInstance( typeid(T) );
        if ( i is null ) 
            throw new Exception( "Unable to create " ~ T.stringof );
        return i;
    }

    protected Object createDynamicInstance( ClassInfo type_a );

    final System getSystem( ClassInfo class_a )
    {
        System i = cast(System)createDynamicInstance( class_a );
        if ( i is null ) 
            throw new Exception( "Unable to create system " ~ to!string(class_a) );
        return i;
    }


    @property
    {
        hash_t identifier();

        int  priority();
        void priority( int );
    }

    final public hash_t toHash( string str_a )
    {
        try 
        {
            return to!long( str_a );
        } 
        catch(Exception e) 
        {
            hash_t hash; foreach (char c; str_a ) hash = (hash * 9) + c;
            return hash;
        }
    }


}
