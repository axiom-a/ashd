/**
 * The base class for a node.
 * 
 * A node is a set of different components that are required by a system.
 *
 * A system can request a collection of nodes from the engine. 
 * Subsequently the Engine object creates a node for every entity that has _all_ of the components 
 * in the node class and adds these nodes to the list obtained by the system. 
 *
 * The engine keeps the list up to date as entities are added
 * to and removed from the engine and as the components on entities change.</p>
 */

module ashd.core.node;

import ashd.core.entity   : Entity;


abstract class Node
{
    protected
    {
        /**
         * The entity whose components are included in the node.
         */
        Entity mEntity;
 
        /**
         * Used by the NodeList class. The previous node in a node list.
         */
        Node mPrevious;
        
        /**
         * Used by the NodeList class. The next node in a node list.
         */
        Node mNext;

    }

    @property
    {
        Entity entity() { return mEntity; }
        void entity( Entity entity_a ) { mEntity = entity_a; }
    }

    @property
    {
        Node next() { return mNext; }
        void next( Node node_a ) { mNext = node_a; }
    }

    @property
    {
        Node previous() { return mPrevious; }
        void previous( Node node_a ) { mPrevious = node_a; }
    }

}

