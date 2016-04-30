/**
 * A useful class for systems which simply iterate over a set of nodes, performing the same action 
 * on each node. This class removes the need for a lot of boilerplate code in such systems.
 * Extend this class and pass the node type and a node update method into the constructor.
 * The node update method will be called once per node on the update cycle
 * with the node instance and the frame time as parameters. e.g.
 *
 *   public class MySystem: ListIteratingSystem
 *   {
 *     override public void MySystem()
 *     {
 *       super( MyNode, updateNode );
 *     }
 *
 *     override private void updateNode( MyNode node, Duration time )
 *     {
 *       // process the node here
 *     }
 *   }
 * }
 */
module ashd.tools.listIteratingSystem;


import ashd.core.system   : System;
import ashd.core.iengine  : IEngine;
import ashd.core.engine   : Engine;
import ashd.core.node     : Node;
import ashd.core.nodelist : NodeList;


import std.datetime       : Duration;


public class ListIteratingSystem(N): System
{
    private
    {
        NodeList mNodeList;
        void delegate( Node, Duration ) mNodeUpdateFunction;
        void delegate( Node ) mNodeAddedFunction;
        void delegate( Node ) mNodeRemovedFunction;
    }

    public this( void delegate( Node, Duration ) nodeUpdateFunction_a,
                 void delegate( Node ) nodeAddedFunction_a = null,
                 void delegate( Node ) nodeRemovedFunction_a = null )
    {
        this.mNodeUpdateFunction = nodeUpdateFunction_a;
        this.mNodeAddedFunction = nodeAddedFunction_a;
        this.mNodeRemovedFunction = nodeRemovedFunction_a;
    }



    override public void addToEngine( IEngine engine_a )
    {
        mNodeList = engine_a.getNodeList( N.classinfo );
        if ( mNodeAddedFunction !is null )
        {
            for ( Node node = mNodeList.head; node; node = node.next )
            {
                mNodeAddedFunction( node );
            }
            mNodeList.nodeAdded.connect( mNodeAddedFunction );

        }
        if( mNodeRemovedFunction !is null )
        {
            mNodeList.nodeRemoved.connect( mNodeRemovedFunction );
        }
    }
    
    override public void removeFromEngine( IEngine engine_a )
    {
        if ( mNodeAddedFunction !is null )
        {
            mNodeList.nodeAdded.disconnect( mNodeAddedFunction );
        }
        if( mNodeRemovedFunction !is null )
        {
            mNodeList.nodeRemoved.disconnect( mNodeRemovedFunction );
        }
        mNodeList = null;
    }
    
    override public void update( Duration time_a )
    {
        for ( Node node = mNodeList.head; node; node = node.next )
        {
            mNodeUpdateFunction( node, time_a );
        }
    }
}
