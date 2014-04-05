/**
 * Used internally, this is an ordered list of Systems for use by the engine update loop.
 */
module ashd.core.systemlist;

import ashd.core.system: System;


class SystemList
{
    private
    {
        System mHead;
        System mTail;
    } 

    @property System head() { return mHead; }

    public void add( System system_a )
    {
        if ( ! mHead )
        {
            mHead = mTail = system_a;
            system_a.next = null;
            system_a.previous = null;
        }
        else
        {
            System node;
            for( node = mTail; node; node = node.previous )
            {
                if ( node.priority <= system_a.priority )
                {
                    break;
                }
            }
            if ( node == mTail )
            {
                mTail.next = system_a;
                system_a.previous = mTail;
                system_a.next = null;
                mTail = system_a;
            }
            else if ( !node )
            {
                system_a.next = mHead;
                system_a.previous = null;
                mHead.previous = system_a;
                mHead = system_a;
            }
            else
            {
                system_a.next = node.next;
                system_a.previous = node;
                node.next.previous = system_a;
                node.next = system_a;
            }
        }
    }
    
    public void remove( System system_a )
    {
        if ( mHead == system_a )
        {
            mHead = mHead.next;
        }
        if ( mTail == system_a )
        {
            mTail = mTail.previous;
        }
        
        if ( system_a .previous )
        {
            system_a.previous.next = system_a.next;
        }
        
        if ( system_a.next )
        {
            system_a.next.previous = system_a.previous;
        }
        // N.B. Don't set system.next and system.previous to null because that will break the list iteration if node is the current node in the iteration.
    }
    
    public void removeAll()
    {
        while( mHead )
        {
            System system = mHead;
            mHead = mHead.next;
            system.previous = null;
            system.next = null;
        }
        mTail = null;
    }

    public System get(T)()
    {
        for ( System system = head; system; system = system.next )
        {
            if ( system.type == T.classinfo )
            {
                return system;
            }
        }
        return null;
    }
}
