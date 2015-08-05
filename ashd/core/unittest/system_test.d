/**
 * Unit tests for system.d
 *
 */
module system_test;

import ashd.core.engine   : Engine;
import ashd.core.iengine  : IEngine;
import ashd.core.system   : System;


import std.datetime  : dur, Duration, SysTime;


int main()
{
    (new SystemTests).systemsGetterReturnsAllTheSystems();
    (new SystemTests).addSystemCallsAddToEngine();
    (new SystemTests).removeSystemCallsRemovedFromEngine();
    (new SystemTests).engineCallsUpdateOnSystems();
    (new SystemTests).defaultPriorityIsZero();
    (new SystemTests).canSetPriorityWhenAddingSystem();
    (new SystemTests).systemsUpdatedInPriorityOrderIfSameAsAddOrder();
    (new SystemTests).systemsUpdatedInPriorityOrderIfReverseOfAddOrder();
    (new SystemTests).systemsUpdatedInPriorityOrderIfPrioritiesAreNegative();
    (new SystemTests).updatingIsFalseBeforeUpdate();
    (new SystemTests).updatingIsTrueDuringUpdate();
    (new SystemTests).updatingIsFalseAfterUpdate();
    (new SystemTests).completeSignalIsDispatchedAfterUpdate();
    (new SystemTests).getSystemReturnsTheSystem();
    (new SystemTests).getSystemReturnsNullIfNoSuchSystem();
    (new SystemTests).removeAllSystemsDoesWhatItSays();
    (new SystemTests).removeSystemAndAddItAgainDontCauseInvalidLinkedList();

    return 0;
}

class SystemTests
{
    Engine mEngine;

    bool mAddedCallbackCalled;
    bool mRemovedCallbackCalled;
    bool mUpdatedCallbackCalled;
    bool mUpdateCompleteCallbackCalled;

    void delegate(System sys_a, string action_a, IEngine engine_a) mCallbackType1;
    void delegate(System sys_a, string action_a, Duration time_a)  mCallbackType2;

    public this()
    {
        mEngine = new Engine();
    }

    public void systemsGetterReturnsAllTheSystems()
    {
        MockSystem system1 = new MockSystem( this );
        mEngine.addSystem( system1, 1 );
        MockSystem system2 = new MockSystem( this );
        mEngine.addSystem( system2, 1 );
        assert( mEngine.systems.length == 2 );
        bool tmp[System];
        foreach ( sys; mEngine.systems )
            tmp[sys] = true;
        assert( system1 in tmp );
        assert( system2 in tmp );
    }

    public void addSystemCallsAddToEngine()
    {
        mAddedCallbackCalled = false;
        MockSystem system = new MockSystem( this );
        mCallbackType1 = &this.addedCallbackMethod;
        mEngine.addSystem( system, 0 );
        assert( mAddedCallbackCalled == true );
    }

    private void addedCallbackMethod( System sys_a, string action_a, IEngine engine_a )
    {
        mAddedCallbackCalled = true;
        assert( action_a == "added" );
        assert( engine_a is mEngine );
    }

    public void removeSystemCallsRemovedFromEngine()
    {
        mRemovedCallbackCalled = false;
        MockSystem system = new MockSystem( this );
        mEngine.addSystem( system, 0 );
        mCallbackType1 = &this.removedCallbackMethod;
        mEngine.removeSystem( system );
        assert( mRemovedCallbackCalled == true );
    }

    private void removedCallbackMethod( System sys_a, string action_a, IEngine engine_a )
    {
        mRemovedCallbackCalled = true;
        assert( action_a == "removed" );
        assert( engine_a is mEngine );
    }

    public void engineCallsUpdateOnSystems()
    {
        mUpdatedCallbackCalled = false;
        MockSystem system = new MockSystem( this );
        mEngine.addSystem( system, 0 );
        mCallbackType2 = &this.updateCallbackMethod;
        mEngine.update( dur!"seconds"(3) );
        assert( mUpdatedCallbackCalled == true );
    }
    private void updateCallbackMethod( System system_a, string action_a, Duration time_a )
    {
        mUpdatedCallbackCalled = true;
        assert( action_a == "update" );
        assert( time_a == dur!"seconds"(3) );
    }

    public void defaultPriorityIsZero()
    {
        MockSystem system = new MockSystem( this );
        assert( system.priority == 0 );
    }

    public void canSetPriorityWhenAddingSystem()
    {
        MockSystem system = new MockSystem( this );
        mEngine.addSystem( system, 10 );
        assert( system.priority == 10 );
    }

    MockSystem tmpSys1, tmpSys2;
    public void systemsUpdatedInPriorityOrderIfSameAsAddOrder()
    {
        mUpdatedCallbackCalled = false;
        tmpSys1 = new MockSystem( this );
        mEngine.addSystem( tmpSys1, 10 );
        tmpSys2 = new MockSystem( this );
        mEngine.addSystem( tmpSys2, 20 );
        mCallbackType2 = &this.updateCallbackMethod1;
        mEngine.update( dur!"seconds"(3) );
        assert( mUpdatedCallbackCalled == true );
    }

    private void updateCallbackMethod1( System system_a, string action_a, Duration time_a )
    {
        assert( system_a is tmpSys1 );
        mCallbackType2 = &this.updateCallbackMethod2;
    }

    private void updateCallbackMethod2( System system_a, string action_a, Duration time_a )
    {
        mUpdatedCallbackCalled = true;
        assert( system_a is tmpSys2 );
    }

    public void systemsUpdatedInPriorityOrderIfReverseOfAddOrder()
    {
        mUpdatedCallbackCalled = false;
        tmpSys2 = new MockSystem( this );
        mEngine.addSystem( tmpSys2, 20 );
        tmpSys1 = new MockSystem( this );
        mEngine.addSystem( tmpSys1, 10 );
        mCallbackType2 = &this.updateCallbackMethod1;
        mEngine.update( dur!"seconds"(3) );
        assert( mUpdatedCallbackCalled == true );
    }

    public void systemsUpdatedInPriorityOrderIfPrioritiesAreNegative()
    {
        tmpSys2 = new MockSystem( this );
        mEngine.addSystem( tmpSys2, 20 );
        tmpSys1 = new MockSystem( this );
        mEngine.addSystem( tmpSys1, -20 );
        mCallbackType2 = &this.updateCallbackMethod1;
        mEngine.update( dur!"seconds"(3) );
    }

    public void updatingIsFalseBeforeUpdate()
    {
        assert( mEngine.updating == false );
    }

    public void updatingIsTrueDuringUpdate()
    {
        MockSystem system = new MockSystem( this );
        mEngine.addSystem( system, 0 );
        mCallbackType2 = &this.assertUpdatingIsTrue;
        mEngine.update( dur!"seconds"(3) );
    }

    private void assertUpdatingIsTrue( System system_a, string action_a, Duration time_a )
    {
        assert( mEngine.updating == true );
    }

    public void updatingIsFalseAfterUpdate()
    {
        mEngine.update( dur!"seconds"(3) );
        assert( mEngine.updating == false );
    }

    public void completeSignalIsDispatchedAfterUpdate()
    {
        mUpdateCompleteCallbackCalled = false;
        MockSystem system = new MockSystem( this );
        mEngine.addSystem( system, 0 );
        mCallbackType2 = &this.listensForUpdateComplete;
        mEngine.update( dur!"seconds"(3) );
        assert( mUpdatedCallbackCalled == true );
        assert( mUpdateCompleteCallbackCalled == true );
    }

    private void listensForUpdateComplete( System system_a, string action_a, Duration time_a )
    {
        mUpdatedCallbackCalled = true;
        class Watcher { void watch() { mUpdateCompleteCallbackCalled = true; } }
        Watcher testWatch = new Watcher();
        mEngine.updateComplete.connect( &testWatch.watch );
    }

    public void getSystemReturnsTheSystem()
    {
        MockSystem system1 = new MockSystem( this );
        mEngine.addSystem( system1, 0 );
        MockSystem2 system2 = new MockSystem2;
        mEngine.addSystem( system2, 0 );
        assert( mEngine.getSystem!MockSystem() is system1 );
    }

    public void getSystemReturnsNullIfNoSuchSystem()
    {
        MockSystem2 system2 = new MockSystem2;
        mEngine.addSystem( system2, 0 );
        assert( mEngine.getSystem!MockSystem() is null );
    }

    public void removeAllSystemsDoesWhatItSays()
    {
        MockSystem system1 = new MockSystem( this );
        mEngine.addSystem( system1, 0 );
        MockSystem2 system2 = new MockSystem2;
        mEngine.addSystem( system2, 0 );
        mEngine.removeAllSystems();
        assert( mEngine.getSystem!MockSystem() is null );
        assert( mEngine.getSystem!MockSystem2() is null );
    }

    public void removeSystemAndAddItAgainDontCauseInvalidLinkedList()
    {
        auto systemB  = new MockSystem2();
        auto systemC  = new MockSystem2();
        mEngine.addSystem( systemB, 0 );
        mEngine.addSystem( systemC, 0 );
        mEngine.removeSystem( systemB );
        mEngine.addSystem( systemB, 0 );
        assert( systemC.previous is null );
        assert( systemB.next is null );
    }
 

}


class MockSystem: System
{
    private SystemTests mTests;

    public this( SystemTests tests_a )
    {
        this.mTests = tests_a;
    }

    override public void addToEngine( IEngine engine_a )
    {
        if( mTests.mCallbackType1 != null )
            mTests.mCallbackType1( this, "added", engine_a );
    }

    override public void removeFromEngine( IEngine engine_a )
    {
        if( mTests.mCallbackType1 != null )
            mTests.mCallbackType1( this, "removed", engine_a );
    }

    override public void update( Duration time_a )
    {
        if( mTests.mCallbackType2 != null )
            mTests.mCallbackType2( this, "update", time_a );
    }
    
}

class MockSystem2: System
{
   
}

