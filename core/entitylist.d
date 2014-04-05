/**
 * An internal class for a linked list of entities. Used inside the framework for
 * managing the entities.
 */

module ashd.core.entitylist;

import ashd.core.entity: Entity;

class EntityList
{
    private
    {
        Entity mHead = null;
        Entity mTail = null;
    }

    @property Entity head() { return mHead; }


    public void add( Entity entity_a )
    {
        if ( ! mHead )
        {
            mHead = mTail = entity_a;
            entity_a.next = null;
            entity_a.previous = null;
        }
        else
        {
            mTail.next = entity_a;
            entity_a.previous = mTail;
            entity_a.next = null;
            mTail = entity_a;
        }
    }
    
    public void remove( Entity entity_a )
    {
        if ( mHead == entity_a )
        {
            mHead = mHead.next;
        }
        if ( mTail == entity_a )
        {
            mTail = mTail.previous;
        }
        
        if ( entity_a.previous )
        {
            entity_a.previous.next = entity_a.next;
        }
        
        if ( entity_a.next )
        {
            entity_a.next.previous = entity_a.previous;
        }
        // N.B. Don't set node.next and node.previous to null because that will break the list iteration if node is the current node in the iteration.
    }
    
    public void removeAll()
    {
        while( mHead )
        {
            Entity entity = mHead;
            mHead = mHead.next;
            entity.previous = null;
            entity.next = null;
        }
        mTail = null;
    }
}
