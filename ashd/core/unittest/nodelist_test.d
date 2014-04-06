/**
 * Unit tests for nodelist.d
 *
 */
import ashd.core.node     : Node;
import ashd.core.nodelist : NodeList, SortFuncType;



int main()
{
    (new NodeListTests).addingNodeTriggersAddedSignal();
    (new NodeListTests).removingNodeTriggersRemovedSignal();
    (new NodeListTests).AllNodesAreCoveredDuringIteration();
    (new NodeListTests).removingCurrentNodeDuringIterationIsValid();
    (new NodeListTests).removingNextNodeDuringIterationIsValid();
    (new NodeListTests).componentAddedSignalContainsCorrectParameters();
    (new NodeListTests).componentRemovedSignalContainsCorrectParameters();
    (new NodeListTests).nodesInitiallySortedInOrderOfAddition();
    (new NodeListTests).swappingOnlyTwoNodesChangesTheirOrder();
    (new NodeListTests).swappingAdjacentNodesChangesTheirPositions();
    (new NodeListTests).swappingNonAdjacentNodesChangesTheirPositions();
    (new NodeListTests).swappingEndNodesChangesTheirPositions();
    (new NodeListTests).insertionSortCorrectlySortsSortedNodes();
    (new NodeListTests).insertionSortCorrectlySortsReversedNodes();
    (new NodeListTests).insertionSortCorrectlySortsMixedNodes();
    (new NodeListTests).insertionSortRetainsTheOrderOfEquivalentNodes();
    (new NodeListTests).mergeSortCorrectlySortsSortedNodes();
    (new NodeListTests).mergeSortCorrectlySortsMixedNodes();
    (new NodeListTests).mergeSortCorrectlySortsReversedNodes();

    return 0;
}

class NodeListTests
{
    NodeList mNodes;

    public this()
    {
        mNodes = new NodeList();
    }


    public void addingNodeTriggersAddedSignal()
    {
        MockNode node = new MockNode();

        bool bCalled = false;
        class Watcher { void watch( Node n ) { bCalled = true; } }
        Watcher testWatch = new Watcher();

        mNodes.nodeAdded.connect( &testWatch.watch );
        mNodes.add( node );

        assert( bCalled == true );
    }

    public void removingNodeTriggersRemovedSignal()
    {
        MockNode node = new MockNode();
        mNodes.add( node );

        bool bCalled = false;
        class Watcher { void watch( Node n ) { bCalled = true; } }
        Watcher testWatch = new Watcher();

        mNodes.nodeRemoved.connect( &testWatch.watch );
        mNodes.remove( node );

        assert( bCalled == true );
    }

    public void AllNodesAreCoveredDuringIteration()
    {
        Node[] nodeArray;
        foreach ( int i; 0..5 )
        {
            MockNode node = new MockNode();
            nodeArray ~= node;
            mNodes.add( node );
        }

        for ( Node node = mNodes.head; node; node = node.next )
        {
            assert( nodeArray[0] == node );
            nodeArray = nodeArray[1..$];
        }
        assert( nodeArray.length == 0 );
    }

    public void removingCurrentNodeDuringIterationIsValid()
    {
        Node[] nodeArray;
        foreach ( int i; 0..5 )
        {
            MockNode node = new MockNode();
            nodeArray ~= node;
            mNodes.add( node );
        }
       
        int count;
        for ( Node node = mNodes.head; node; node = node.next )
        {
            nodeArray = nodeArray[1..$];
            if( ++count == 2 )
            {
                mNodes.remove( node );
            }
        }
        assert( nodeArray.length == 0 );
    }

    public void removingNextNodeDuringIterationIsValid()
    {
        Node[] nodeArray;
        foreach ( int i; 0..5 )
        {
            MockNode node = new MockNode();
            nodeArray ~= node;
            mNodes.add( node );
        }
        
        int count;
        for ( Node node = mNodes.head; node; node = node.next )
        {
            nodeArray = nodeArray[1..$];
            if( ++count == 2 )
            {
                mNodes.remove( node.next );
            }
        }
        assert( nodeArray.length == 1 );
    }

    public void componentAddedSignalContainsCorrectParameters()
    {
        Node tempNode = new MockNode();
        class Watcher { void watch( Node n ) { assert( n is tempNode ); } }
        Watcher testWatch = new Watcher();

        mNodes.nodeAdded.connect( &testWatch.watch );
        mNodes.add( tempNode );
    }

    public void componentRemovedSignalContainsCorrectParameters()
    {
        Node tempNode = new MockNode();
        mNodes.add( tempNode );

        class Watcher { void watch( Node n ) { assert( n is tempNode ); } }
        Watcher testWatch = new Watcher();

        mNodes.nodeRemoved.connect( &testWatch.watch );
        mNodes.remove( tempNode );
    }

    public void nodesInitiallySortedInOrderOfAddition()
    {
        MockNode node1 = new MockNode();
        MockNode node2 = new MockNode();
        MockNode node3 = new MockNode();
        mNodes.add( node1 );
        mNodes.add( node2 );
        mNodes.add( node3 );

        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node2, node3 ] );
    }
 
    public void swappingOnlyTwoNodesChangesTheirOrder()
    {
        MockNode node1 = new MockNode();
        MockNode node2 = new MockNode();
        mNodes.add( node1 );
        mNodes.add( node2 );
        mNodes.swap( node1, node2 );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node2, node1 ] );
    }

    public void swappingAdjacentNodesChangesTheirPositions()
    {
        MockNode node1 = new MockNode();
        MockNode node2 = new MockNode();
        MockNode node3 = new MockNode();
        MockNode node4 = new MockNode();
        mNodes.add( node1 );
        mNodes.add( node2 );
        mNodes.add( node3 );
        mNodes.add( node4 );
        mNodes.swap( node2, node3 );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node3, node2, node4 ] );
    }

    public void swappingNonAdjacentNodesChangesTheirPositions()
    {
        MockNode node1 = new MockNode();
        MockNode node2 = new MockNode();
        MockNode node3 = new MockNode();
        MockNode node4 = new MockNode();
        MockNode node5 = new MockNode();
        mNodes.add( node1 );
        mNodes.add( node2 );
        mNodes.add( node3 );
        mNodes.add( node4 );
        mNodes.add( node5 );
        mNodes.swap( node2, node4 );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node4, node3, node2, node5 ] );
    }

    public void swappingEndNodesChangesTheirPositions()
    {
        MockNode node1 = new MockNode();
        MockNode node2 = new MockNode();
        MockNode node3 = new MockNode();
        mNodes.add( node1 );
        mNodes.add( node2 );
        mNodes.add( node3 );

        mNodes.swap( node1, node3 );

        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node3, node2, node1 ] );
    }

    private double sortFunction( MockNode node1_a, MockNode node2_a )
    {
        return node1_a.mPos - node2_a.mPos;
    }

    public void insertionSortCorrectlySortsSortedNodes()
    {
        MockNode node1 = new MockNode(1);
        MockNode node2 = new MockNode(2);
        MockNode node3 = new MockNode(3);
        MockNode node4 = new MockNode(4);
        mNodes.add( node1 );
        mNodes.add( node2 );
        mNodes.add( node3 );
        mNodes.add( node4 );

        mNodes.insertionSort( cast(SortFuncType)&sortFunction );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node2, node3, node4 ] );
    }

    public void insertionSortCorrectlySortsReversedNodes()
    {
        MockNode node1 = new MockNode(1);
        MockNode node2 = new MockNode(2);
        MockNode node3 = new MockNode(3);
        MockNode node4 = new MockNode(4);
        mNodes.add( node4 );
        mNodes.add( node3 );
        mNodes.add( node2 );
        mNodes.add( node1 );

        mNodes.insertionSort( cast(SortFuncType)&sortFunction );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node2, node3, node4 ] );
    }

    public void insertionSortCorrectlySortsMixedNodes()
    {
        MockNode node1 = new MockNode(1);
        MockNode node2 = new MockNode(2);
        MockNode node3 = new MockNode(3);
        MockNode node4 = new MockNode(4);
        MockNode node5 = new MockNode(5);
        mNodes.add( node3 );
        mNodes.add( node4 );
        mNodes.add( node1 );
        mNodes.add( node5 );
        mNodes.add( node2 );

        mNodes.insertionSort( cast(SortFuncType)&sortFunction );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node2, node3, node4, node5 ] );
    }

    public void insertionSortRetainsTheOrderOfEquivalentNodes()
    {
        MockNode node1 = new MockNode(1);
        MockNode node2 = new MockNode(1);
        MockNode node3 = new MockNode(3);
        MockNode node4 = new MockNode(4);
        MockNode node5 = new MockNode(4);
        mNodes.add( node3 );
        mNodes.add( node4 );
        mNodes.add( node1 );
        mNodes.add( node5 );
        mNodes.add( node2 );

        mNodes.insertionSort( cast(SortFuncType)&sortFunction );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node2, node3, node4, node5 ] );
    }

    public void mergeSortCorrectlySortsSortedNodes()
    {
        MockNode node1 = new MockNode(1);
        MockNode node2 = new MockNode(2);
        MockNode node3 = new MockNode(3);
        MockNode node4 = new MockNode(4);
        mNodes.add( node1 );
        mNodes.add( node2 );
        mNodes.add( node3 );
        mNodes.add( node4 );

        mNodes.mergeSort( cast(SortFuncType)&sortFunction );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node2, node3, node4 ] );
    }
 
    public void mergeSortCorrectlySortsReversedNodes()
    {
        MockNode node1 = new MockNode(1);
        MockNode node2 = new MockNode(2);
        MockNode node3 = new MockNode(3);
        MockNode node4 = new MockNode(4);
        mNodes.add( node4 );
        mNodes.add( node3 );
        mNodes.add( node2 );
        mNodes.add( node1 );

        mNodes.mergeSort( cast(SortFuncType)&sortFunction );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node2, node3, node4 ] );

    }
    
    public void mergeSortCorrectlySortsMixedNodes()
    {
        MockNode node1 = new MockNode(1);
        MockNode node2 = new MockNode(2);
        MockNode node3 = new MockNode(3);
        MockNode node4 = new MockNode(4);
        MockNode node5 = new MockNode(5);
        mNodes.add( node3 );
        mNodes.add( node4 );
        mNodes.add( node1 );
        mNodes.add( node5 );
        mNodes.add( node2 );

        mNodes.mergeSort( cast(SortFuncType)&sortFunction );
        Node[] nodes = mNodes.allNodes();
        assert( nodes == [ node1, node2, node3, node4, node5 ] );
    }
 
} // class NodeListTests


class MockNode: Node
{
    public int mPos;
  
    this( int value_a = 0 )
    {
        mPos = value_a;
    }
}




