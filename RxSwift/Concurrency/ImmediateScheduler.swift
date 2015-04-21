//
//  ImmediateScheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/13/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public final class ImmediateScheduler: IScheduler {
    public var now: NSDate {
        return Scheduler.now
    }
    
    public func schedule<TState>(#state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        return action(AsyncLockScheduler(), state)
    }
    
    public func schedule<TState>(#state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        Stopwatch().sleep(Scheduler.normalize(dueTime))
        return action(AsyncLockScheduler(), state)
    }
}

internal final class AsyncLockScheduler: IScheduler {
    var now: NSDate {
        return Scheduler.now
    }
    
    private var lock = AsyncLock()
    
    func schedule<TState>(#state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        var m = SingleAssignmentDisposable()
        lock.wait {
            if !m.isDisposed {
                m.disposable = action(self, state)
            }
        }
        return m
    }
    
    func schedule<TState>(#state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        if dueTime <= 0 {
            return schedule(state: state, action: action)
        }
        let stopwatch = Stopwatch()
        var m = SingleAssignmentDisposable()
        lock.wait {
            if !m.isDisposed {
                stopwatch.sleep(dueTime)
                m.disposable = action(self, state)
            }
        }
        return m
    }
}
