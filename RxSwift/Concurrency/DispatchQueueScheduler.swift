//
//  DispatchQueueScheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/13/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public class DispatchQueueScheduler: Scheduler {
    private let queue: dispatch_queue_t
    
    public init(_ queue: dispatch_queue_t) {
        self.queue = queue
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

public final class MainQueueScheduler: DispatchQueueScheduler {
    public static let instance = MainQueueScheduler()
    
    public init() {
        super.init(dispatch_get_main_queue())
    }
}

public final class SerialQueueScheduler: DispatchQueueScheduler {
    public static let instance = SerialQueueScheduler()
    
    public init() {
        super.init(dispatch_queue_create("io.github.norio-nomura.RxSwift", DISPATCH_QUEUE_SERIAL))
    }
    
    public init(_ label: String) {
        super.init(dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL))
    }
}

public final class ConcurrentQueueScheduler: DispatchQueueScheduler {
    public static let instance = ConcurrentQueueScheduler()
    
    public convenience init() {
        self.init(DISPATCH_QUEUE_PRIORITY_DEFAULT)
    }
    
    public init(_ qos_class: qos_class_t) {
        super.init(dispatch_get_global_queue(qos_class, 0))
    }
    
    public init(_ priority: dispatch_queue_priority_t) {
        super.init(dispatch_get_global_queue(priority, 0))
    }
}

extension Scheduler: ISchedulerLongRunning {
    public func scheduleLongRunning<TState>(#state: TState, action: (TState, ICancelable) -> ()) -> IDisposable? {
        var d = BooleanDisposable()
        dispatch_async(ConcurrentQueueScheduler.instance.queue) {
            action(state, d)
        }
        return d
    }
}
