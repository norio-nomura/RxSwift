//
//  Scheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IScheduler: class {
    func schedule<TState>(state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable?
    func schedule<TState>(state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable?

    // Is absolute time scheduler needed?
//    func schedule<TState>(state: TState, dueTime: NSDate, action: (IScheduler, TState) -> IDisposable?) -> IDisposable?
}

public protocol ISchedulerPeriodic: class {
    func schedule<TState>(state: TState, period: NSTimeInterval, action: TState -> TState) -> IDisposable?
}

public struct Scheduler {
    public static func normalize(timeInterval: NSTimeInterval) -> NSTimeInterval {
        return timeInterval < 0 ? 0 : timeInterval
    }
    
    public static var immediate = ImmediateScheduler()
}

public func schedule(scheduler: IScheduler, action: () -> ()) -> IDisposable? {
    return scheduler.schedule(action, action: invoke)
}

// MARK: private

private func invoke(_: IScheduler, action: () -> ()) -> IDisposable? {
    action()
    return nil
}
