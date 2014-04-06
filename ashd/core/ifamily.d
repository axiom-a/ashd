/**
 * The interface for classes that are used to manage NodeLists (set as the familyClass property 
 * in the Engine object). Most developers don't need to use this since the default implementation
 * is used by default and suits most needs.
 */
module ashd.core.ifamily;

import ashd.core.entity  : Entity;
import ashd.core.node    : Node;
import ashd.core.nodelist: NodeList;



interface IFamily
{
    /**
     * Returns the NodeList managed by this class. This should be a reference that remains valid always
     * since it is retained and reused by Systems that use the list. i.e. never recreate the list,
     * always modify it in place.
     */
    NodeList nodeList();

    /**
     * clean the node (reset component pointers)
     */
    void resetNode( Node node_a );

    /**
     * An entity has been added to the engine. It may already have components so test the entity
     * for inclusion in this family's NodeList.
     */
    void newEntity( Entity entity_a );

    /**
     * An entity has been removed from the engine. If it's in this family's NodeList it should be removed.
     */
    void removeEntity( Entity entity_a );

    /**
     * A component has been added to an entity. Test whether the entity's inclusion in this family's
     * NodeList should be modified.
     */
    void componentAddedToEntity( Entity entity_a, ClassInfo class_a );

    /**
     * A component has been removed from an entity. Test whether the entity's inclusion in this family's
     * NodeList should be modified.
     */
    void componentRemovedFromEntity( Entity entity_a, ClassInfo class_a );

    /**
     * The family is about to be discarded. Clean up all properties as necessary. Usually, you will
     * want to empty the NodeList at this time.
     */
    void cleanUp();

}
