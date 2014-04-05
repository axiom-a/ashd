/**
 * This internal class maintains a pool of deleted nodes for reuse by the framework. This reduces the overhead
 * from object creation and garbage collection.
 * 
 * Because nodes may be deleted from a NodeList while in use, by deleting Nodes from a NodeList
 * while iterating through the NodeList, the pool also maintains a cache of nodes that are added to the pool
 * but should not be reused yet. They are then released into the pool by calling the releaseCache method.
 */
module ashd.core.nodepool;

import ashd.core.entity   : Entity;
import ashd.core.ifamily  : IFamily;
import ashd.core.node     : Node;


private class NodePool(Class)
{
    private
    {
        string[ClassInfo] *mComponents;
        Node               mTail;
        Node               mCacheTail;
        IFamily            mFamily;
    }


    /**
     * Creates a pool for the given node class.
     */
    public this( ref string[ClassInfo] components_a, IFamily family_a )
    {
        mComponents = &components_a;
        mFamily = family_a;
    }

    /**
     * Fetches a node from the pool.
     */
    public Node get()
    {
        if ( mTail )
        {
            Node node = mTail;
            mTail = mTail.previous;
            node.previous = null;
            return node;
        }
        else
        {
            Node tmp = new Class;
            if ( tmp is null )
                throw new Error( "Error creating new class !" );
            return tmp;
        }
    }

    /**
     * Adds a node to the pool.
     */
    public void dispose( Node node_a )
    {

        mFamily.resetNode( node_a );
        node_a.entity = null;
        
        node_a.next = null;
        node_a.previous = mTail;
        mTail = node_a;
    }
 
    /**
     * Adds a node to the cache
     */
    public void cache( Node node_a )
    {
        node_a.previous = mCacheTail;
        mCacheTail = node_a;
    }
 
    /**
     * Releases all nodes from the cache into the pool
     */
    public void releaseCache()
    {
        while( mCacheTail )
        {
            Node node = mCacheTail;
            mCacheTail = node.previous;
            this.dispose( node );
        }
    }
} // private class NodePool
