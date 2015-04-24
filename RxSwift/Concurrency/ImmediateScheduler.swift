//
//  ImmediateScheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/13/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public final class ImmediateScheduler: LocalScheduler {
    // MARK: scheduleCore
    override func scheduleCore(#state: Any, action: IScheduler -> IDisposable?) -> IDisposable? {
        return action(AsyncLockScheduler())
    }
    
    override func scheduleCore(#state: Any, dueTime: NSTimeInterval, action: IScheduler -> IDisposable?) -> IDisposable? {
        Stopwatch().sleep(Scheduler.normalize(dueTime))
        return action(AsyncLockScheduler())
    }
}

internal final class AsyncLockScheduler: LocalScheduler {
    private var lock = AsyncLock()
    
    // MARK: scheduleCore
    override func scheduleCore(#state: Any, action: IScheduler -> IDisposable?) -> IDisposable? {
        var m = SingleAssignmentDisposable()
        lock.wait {
            if !m.isDisposed {
                m.disposable = action(self)
            }
        }
        return m
    }

    override func scheduleCore(#state: Any, dueTime: NSTimeInterval, action: IScheduler -> IDisposable?) -> IDisposable? {
        if dueTime <= 0 {
            return scheduleCore(state: state, action: action)
        }
        let stopwatch = Stopwatch()
        var m = SingleAssignmentDisposable()
        lock.wait {
            if !m.isDisposed {
                stopwatch.sleep(dueTime)
                m.disposable = action(self)
            }
        }
        return m
    }
}
