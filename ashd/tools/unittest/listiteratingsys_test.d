/**
 * Unit tests for listiteratingsystem.d
 *
 */
module listiteratingsys_test;

import ashd.core.component              : Component;
import ashd.core.componentMatchingFamily: ComponentMatchingFamily;
import ashd.core.engine                 : Engine;
import ashd.core.iengine                : IEngine;
import ashd.core.entity                 : Entity;
import ashd.core.node                   : Node;
import ashd.core.nodelist               : NodeList;
import ashd.tools.listIteratingSystem   : ListIteratingSystem;


import std.datetime                     : dur, Duration, SysTime;



int main()
{
    (new ListIteratingSystemTests).updateIteratesOverNodes();
    return 0;
}

class ListIteratingSystemTests
{

    Entity[] mEntities;
    int      mCallCount;


    public void updateIteratesOverNodes()
    {
        ComponentMatchingFamily!MockNode mockNodeFamily;
        Engine engine = new Engine();
        mockNodeFamily = new ComponentMatchingFamily!MockNode( engine );
        engine.registerFamily!MockNode( mockNodeFamily );

        Entity entity1 = new Entity();
        Point component1 = new Point();
        entity1.add( component1 );
        engine.addEntity( entity1 );
        Entity entity2 = new Entity();
        Point component2 = new Point();
        entity2.add( component2 );
        engine.addEntity( entity2 );
        Entity entity3 = new Entity();
        Point component3 = new Point();
        entity3.add( component3 );
        engine.addEntity( entity3 );

        ListIteratingSystem!MockNode system1 = new ListIteratingSystem!MockNode( &updateNode );
        engine.addSystem!(ListIteratingSystem!MockNode)( system1, 1 );
        mEntities = [entity1, entity2, entity3];
        mCallCount = 0;
        engine.update( dur!"msecs"(100) );

        assert( mCallCount == 3 );

    }

    private void updateNode( Node node_a, Duration time_a )
    {
        assert( node_a.entity is mEntities[mCallCount] );
        assert( time_a == dur!"msecs"(100) );
        mCallCount++;
    }

}

class Point: Component
{
    int x,y;
}

class MockNode: Node
{
    public Point value;
}

