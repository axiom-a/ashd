/**
 * A collection of nodes.
 * 
 * <p>Systems within the engine access the components of entities via NodeLists. A NodeList contains
 * a node for each Entity in the engine that has all the components required by the node. To iterate
 * over a NodeList, start from the head and step to the next on each loop, until the returned value
 * is null.</p>
 * 
 * <p>for( var node : Node = nodeList.head; node; node = node.next )
 * {
 *   // do stuff
 * }</p>
 * 
 * <p>It is safe to remove items from a nodelist during the loop. When a Node is removed form the 
 * NodeList it's previous and next properties still point to the nodes that were before and after
 * it in the NodeList just before it was removed.</p>
 */
module ashd.core.nodelist;

import ashd.core.node     : Node;


import std.signals; // for Signal template. 

// Delegate alias for sort functions
alias double delegate(Node, Node) SortFuncType;

class NodeList
{
    private
    {
        // The first item in the node list, or null if the list contains no nodes.
        Node mHead;

        // The last item in the node list, or null if the list contains no nodes.
        Node mTail;
    }


    /// access head node
    public Node head() { return mHead; }

    /**
     * A signal that is dispatched whenever a node is added to the node list.
     * 
     * <p>The signal will pass a single parameter to the listeners - the node that was added.</p>
     */
    public mixin Signal!( Node ) nodeAdded;

    /**
     * A signal that is dispatched whenever a node is removed from the node list.
     * 
     * <p>The signal will pass a single parameter to the listeners - the node that was removed.</p>
     */
    public mixin Signal!( Node ) nodeRemoved;


    public this() 
    {
        mHead = null;
        mTail = null;
    }
  

    public void add( Node node_a )
    {
        if ( mHead is null )
        {
            mHead = mTail = node_a;
            node_a.next = null;
            node_a.previous = null;
        }
        else
        {
            mTail.next = node_a;
            node_a.previous = mTail;
            node_a.next = null;
            mTail = node_a;
        }
        nodeAdded.emit( node_a );
    }
    
    public void remove( Node node_a )
    {
        if ( mHead == node_a )
        {
            mHead = mHead.next;
        }
        if ( mTail == node_a )
        {
            mTail = mTail.previous;
        }
        
        if ( node_a.previous )
        {
            node_a.previous.next = node_a.next;
        }
        
        if ( node_a.next )
        {
            node_a.next.previous = node_a.previous;
        }
        nodeRemoved.emit( node_a );
        // N.B. Don't set node.next and node.previous to null because that will break the list iteration if node is the current node in the iteration.
    }

    /**
     * Collect all nodes into array
     *
     * Returns:
     *  Array of nodes
     */
    public Node[] allNodes()
    {
        Node[] nodes;

        for ( Node node = mHead; node; node = node.next )
        {
            nodes ~= node;
        }
        return nodes;
    }

    /// Remove all nodes from list
    public void removeAll()
    {
        while( mHead )
        {
            Node node = mHead;
            mHead = node.next;
            node.previous = null;
            node.next = null;
            nodeRemoved.emit( node );
        }
        mTail = null;
    }

    /**
     * true if the list is empty, false otherwise.
     */
    public bool isEmpty()
    {
        return mHead is null;
    }

    /**
     * Swaps the positions of two nodes in the list. Useful when sorting a list.
     */
    public void swap( Node node1_a, Node node2_a )
    {
        if ( node1_a.previous == node2_a )
        {
            node1_a.previous = node2_a.previous;
            node2_a.previous = node1_a;
            node2_a.next = node1_a.next;
            node1_a.next  = node2_a;
        }
        else if ( node2_a.previous == node1_a )
        {
            node2_a.previous = node1_a.previous;
            node1_a.previous = node2_a;
            node1_a.next = node2_a.next;
            node2_a.next  = node1_a;
        }
        else
        {
            Node temp = node1_a.previous;
            node1_a.previous = node2_a.previous;
            node2_a.previous = temp;
            temp = node1_a.next;
            node1_a.next = node2_a.next;
            node2_a.next = temp;
        }
        if ( mHead == node1_a )
        {
            mHead = node2_a;
        }
        else if ( head == node2_a )
        {
            mHead = node1_a;
        }
        if ( mTail == node1_a )
        {
            mTail = node2_a;
        }
        else if ( mTail == node2_a )
        {
            mTail = node1_a;
        }
        if ( node1_a.previous )
        {                            
            node1_a.previous.next = node1_a;
        }
        if ( node2_a.previous )
        {
            node2_a.previous.next = node2_a;
        }
        if ( node1_a.next )
        {
            node1_a.next.previous = node1_a;
        }
        if ( node2_a.next )
        {
            node2_a.next.previous = node2_a;
        }
    } // swap()


    /**
     * Performs an insertion sort on the node list. In general, insertion sort is very efficient with short lists 
     * and with lists that are mostly sorted, but is inefficient with large lists that are randomly ordered.
     * 
     * <p>The sort function takes two nodes and returns a Number.</p>
     * 
     * <p><code>function sortFunction( node1 : MockNode, node2 : MockNode ) : Number</code></p>
     * 
     * <p>If the returned number is less than zero, the first node should be before the second. If it is greater
     * than zero the second node should be before the first. If it is zero the order of the nodes doesn't matter
     * and the original order will be retained.</p>
     * 
     * <p>This insertion sort implementation runs in place so no objects are created during the sort.</p>
     */
    public void insertionSort( SortFuncType sortFunction_a )
    {
        if ( mHead == mTail )
        {
            return;
        }
        Node remains = mHead.next;
        for ( Node node = remains; node; node = remains )
        {
            remains = node.next;
            Node other;
            for ( other = node.previous; other; other = other.previous )
            {
                if ( sortFunction_a( node, other ) >= 0 )
                {
                    // move node to after other
                    if ( node != other.next )
                    {
                        // remove from place
                        if ( mTail == node)
                        {
                            mTail = node.previous;
                        }
                        node.previous.next = node.next;
                        if (node.next)
                        {
                            node.next.previous = node.previous;
                        }
                        // insert after other
                        node.next = other.next;
                        node.previous = other;
                        node.next.previous = node;
                        other.next = node;
                    }
                    break; // exit the inner for loop
                }
            }
            if( !other ) // the node belongs at the start of the list
            {
                // remove from place
                if ( mTail == node)
                {
                    mTail = node.previous;
                }
                node.previous.next = node.next;
                if ( node.next )
                {
                    node.next.previous = node.previous;
                }
                // insert at head
                node.next = mHead;
                mHead.previous = node;
                node.previous = null;
                mHead = node;
            }
        }
    }
    
    /**
     * Performs a merge sort on the node list. In general, merge sort is more efficient than insertion sort
     * with long lists that are very unsorted.
     * 
     * <p>The sort function takes two nodes and returns a Number.</p>
     * 
     * <p><code>function sortFunction( node1 : MockNode, node2 : MockNode ) : Number</code></p>
     * 
     * <p>If the returned number is less than zero, the first node should be before the second. If it is greater
     * than zero the second node should be before the first. If it is zero the order of the nodes doesn't matter.</p>
     * 
     * <p>This merge sort implementation creates and uses a single Vector during the sort operation.</p>
     */
    public void mergeSort( SortFuncType sortFunction_a )
    {
        if( mHead == mTail )
        {
            return;
        }
        Node[] lists;
        // disassemble the list
        Node start = mHead;
        Node end;
        while( start )
        {
            end = start;
            while ( end.next && sortFunction_a( end, end.next ) <= 0 )
            {
                end = end.next;
            }
            Node next = end.next;
            start.previous = null;
            end.next = null;
            lists ~= start;
            start = next;
        }
        // reassemble it in order
        while( lists.length > 1 )
        {
            Node merged = merge( lists[0], lists[1], sortFunction_a );
            lists = lists[2..$] ~ merged;
        }
        // find the tail
        mTail = mHead = lists[0];
        while( mTail.next )
        {
            mTail = mTail.next;    
        }
    }
    
    public Node merge( Node head1_a, Node head2_a, SortFuncType sortFunction_a )
    {
        Node node;
        Node head;
        if ( sortFunction_a( head1_a, head2_a ) <= 0 )
        {
            head = node = head1_a;
            head1_a = head1_a.next;
        }
        else
        {
            head = node = head2_a;
            head2_a = head2_a.next;
        }
        while ( head1_a && head2_a )
        {
            if ( sortFunction_a( head1_a, head2_a ) <= 0 )
            {
                node.next = head1_a;
                head1_a.previous = node;
                node = head1_a;
                head1_a = head1_a.next;
            }
            else
            {
                node.next = head2_a;
                head2_a.previous = node;
                node = head2_a;
                head2_a = head2_a.next;
            }
        }
        if ( head1_a )
        {
            node.next = head1_a;
            head1_a.previous = node;
        }
        else
        {
            node.next = head2_a;
            head2_a.previous = node;
        }
        return head;
    }
}
