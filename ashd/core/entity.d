/**
 * Port of Ash Entity system into D
 *
 */

module ashd.core.entity;

import std.conv   : to;
import std.signals; // for Signal template.

import ashd.core.component : Component;

/**
 * An entity is composed of components. As such, it is essentially a collection object for components.
 * Sometimes, the entities in a game will mirror the actual characters and objects in the game, but this
 * is not necessary.
 *
 * <p>Components are simple value objects that contain data relevant to the entity. Entities
 * with similar functionality will have instances of the same components. So we might have
 * a position component</p>
 *
 * <p><code>public class PositionComponent
 * {
 *   public var x : Number;
 *   public var y : Number;
 * }</code></p>
 *
 * <p>All entities that have a position in the game world, will have an instance of the
 * position component. Systems operate on entities based on the components they have.</p>
 */
public class Entity
{
    /**
     * The constructor
     *
     * Params:
     *  name = The name for the entity. If left blank, a default name is assigned
     *         with the form _entityN where N is an integer.
     */
    public this( string name = string.init ) nothrow @safe
    {
        if ( name != string.init )
            mName = name;
        else
            mName = "_entity"~to!string(++mNameCount);
    }


    @property
    {
        Entity next()     nothrow @safe { return mNext; }
        Entity previous() nothrow @safe { return mPrevious; }
        void   next( Entity entity )     nothrow @safe { mNext = entity; }
        void   previous( Entity entity ) nothrow @safe { mPrevious = entity; }

        /**
         * All entities have a name. If no name is set, a default name is used. Names are used to
         * fetch specific entities from the engine, and can also help to identify an entity when debugging.
         */
        public string name() nothrow @safe { return mName; }
        public void name( string value )
        {
            if ( value == string.init )
                throw new Exception("Setting Entity name to empty string");

            if ( mName != value )
            {
                string previous = mName;
                mName = value;
                nameChanged.emit( this, previous );
            }
        }
    }

    /// This signal is dispatched when a component is added to the entity.
    mixin Signal!( Entity, ClassInfo ) componentAdded;

    /// This signal is dispatched when a component is removed from the entity.
    mixin Signal!( Entity, ClassInfo ) componentRemoved;

    /// Dispatched when the name of the entity changes.
    /// Used internally by the engine to track entities based on their names.
    mixin Signal!( Entity, string ) nameChanged;


    /**
     * Add a component to the entity.
     *
     *   If a component of the same type is already attached, it will be removed
     * and replaced by the supplied component.
     *
     * Params:
     *  component_a = The component object to add.
     *  T = the type of component it is to be stored as
     *
     * Returns:
     *  A reference to the entity. This enables the chaining of calls to add, to make
     * creating and configuring entities cleaner. e.g.
     *
     * Entity entity = new Entity()
     * entity.add( new Position( 100, 200 ) )
     * entity.add( new Display( new PlayerClip() ) );
     */
    public Entity add(T)(T component)
    {
        if (T.classinfo in mComponents)
            this.removeCpt(T.classinfo);

        mComponents[T.classinfo] = component;
        componentAdded.emit(this, T.classinfo);

        return this;
    }

    public Entity add(Object component, ClassInfo class_info)
    {

        if (class_info in mComponents)
            this.removeCpt(class_info);

        mComponents[class_info] = component;
        componentAdded.emit(this, class_info);

        return this;
    }

    // Quicker internal removal method
    private void removeCpt(ClassInfo class_info)
    {
        mComponents.remove(class_info);
        componentRemoved.emit(this, class_info);
    }


    /**
     * Remove a component from the entity.
     *
     * Params:
     *  T = The class of the component to be removed.
     *
     * Returns:
     *  the component, or null if the component doesn't exist in the entity
     */
    public Object remove(T)()
    {
        T c;

        if ( T.classinfo in mComponents )
        {
            c = to!T(mComponents[T.classinfo]);
            this.removeCpt( T.classinfo );
            return c;
        }
        return null;
    }

    public Object remove( ClassInfo class_a )
    {
        Object c;

        if ( class_a in mComponents )
        {
            c = cast(Object)(mComponents[class_a]);
            this.removeCpt( class_a );
            return c;
        }
        return null;
    }


    /**
     * Get a component from the entity.
     *
     * @param componentClass The class of the component requested.
     * @return The component, or null if none was found.
     */
    public T get(T)()
    {
        if ( T.classinfo in mComponents )
        {
            return to!T(mComponents[ T.classinfo ]);
        }
        else
        {
            return null;
        }
    }
     /**
     * Get a component from the entity.
     *
     * @param componentClass The class of the component requested.
     * @return The component, or null if none was found.
     */
    public Object get( ClassInfo class_a )
    {
        if ( class_a in mComponents )
            return mComponents[ class_a ];
        else
            return null;
    }

    /**
     * Get all components from the entity.
     *
     * Returns:
     *  An array containing all the components that are on the entity.
     */
    public Object[] getAll()
    {
        Object[] componentArray;
        ulong i;

        componentArray.length = mComponents.length;
        foreach( component; mComponents )
        {
            componentArray[i++] = component;
        }
        return componentArray;
    }

    /**
     * Does the entity have a component of a particular type.
     *
     * @param componentClass The class of the component sought.
     * @return true if the entity has a component of the type, false if not.
     */
    public bool has(T)()
    {
        return ( T.classinfo in mComponents ) !is null;
    }

    public bool has( ClassInfo class_a )
    {
        return ( class_a in mComponents ) !is null;
    }

private:
    string            mName;         // Optional, give the entity a name.
                                     // This can help with debugging and with serialising the entity.
    static int        mNameCount;    // Used if name not specified
    Object[ClassInfo] mComponents;   // List of components attached to entity

    // Used by the EntityList class to form linked list
    Entity            mPrevious;
    Entity            mNext;


} // class Entity


