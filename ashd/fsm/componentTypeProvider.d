/**
 * This component provider always returns a new instance of a component. An instance
 * is created when requested and is of the type passed in to the constructor.
 */

module ashd.fsm.componentTypeProvider;

import std.conv: to;

import ashd.fsm.IComponentProvider: IComponentProvider;


public class ComponentTypeProvider: IComponentProvider
{
    private
    {
        ClassInfo mComponentType;
    }

    /**
     * Constructor
     * 
     * @param type The type of the instances to be created
     */
    public this( ClassInfo type_a )
    {
        mComponentType = type_a;
    }

    /**
     * Used to compare this provider with others. Any ComponentTypeProvider that returns
     * the same type will be regarded as equivalent.
     * 
     * @return The type of the instances created
     */
    public hash_t identifier()
    {
        return IComponentProvider.toHash( to!string(mComponentType) );
    }

    Object createDynamicInstance( ClassInfo type_a )
    {

        return type_a.create();
    }


}
