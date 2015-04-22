//
//  DispatchQueueScheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/13/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public final class DispatchQueueScheduler: Scheduler {
    private let queue = dispatch_queue_create("io.github.norio-nomura.RxSwift", DISPATCH_QUEUE_SERIAL)
    
    public init(_ queue: dispatch_queue_t) {
        dispatch_set_target_queue(self.queue, queue)
    }
    
    // MARK: scheduleCore
    override func scheduleCore(#state: Any, action: IScheduler -> IDisposable?) -> IDisposable? {
        var m = SingleAssignmentDisposable()
        dispatch_async(queue) {
            if !m.isDisposed {
                m.disposable = action(self)
            }
        }
        return m
    }

    override func scheduleCore(#state: Any, dueTime: NSTimeInterval, action: IScheduler -> IDisposable?) -> IDisposable? {
        var m = SingleAssignmentDisposable()
        dispatch_after(dueTime.dispatchTimeFromNow(), queue) {
            if !m.isDisposed {
                m.disposable = action(self)
            }
        }
        return m
    }
}
