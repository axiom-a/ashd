/**
 * This is the Interface for component providers. Component providers are used to supply components 
 * for states within an EntityStateMachine. Ash includes three standard component providers,
 * ComponentTypeProvider, ComponentInstanceProvider and ComponentSingletonProvider. Developers
 * may wish to create more.
 */
module ashd.fsm.IComponentProvider;

import std.conv: to;

public interface IComponentProvider
{
    /**
     * Used to request a component from the provider.
     * 
     * @return A component for use in the state that the entity is entering
     */
    // This is a final method (templates can't be virtual)
    T getComponent(T)()
    {
        auto i = cast(T)createDynamicInstance( typeid(T) );
        if ( i is null ) 
            throw new Exception( "Unable to create " ~ T.stringof );
        return i;
    }

    protected Object createDynamicInstance( ClassInfo type_a );
  
    final Object getComponent( ClassInfo class_a )
    {
        Object i = createDynamicInstance( class_a );
        if ( i is null ) 
            throw new Exception( "Unable to create component " ~ to!string(class_a) );
        return i;
    }


    /**
     * Returns an identifier that is used to determine whether two component providers will
     * return the equivalent components.
     * 
     * <p>If an entity is changing state and the state it is leaving and the state is is 
     * entering have components of the same type, then the identifiers of the component
     * provders are compared. If the two identifiers are the same then the component
     * is not removed. If they are different, the component from the old state is removed
     * and a component for the new state is added.</p>
     * 
     * @return An object
     */
    hash_t identifier();

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
