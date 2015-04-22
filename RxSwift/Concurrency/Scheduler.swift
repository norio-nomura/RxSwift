//
//  Scheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public class Scheduler: IScheduler {
    // MARK: ISchedulerCore
    public func schedule<TState>(#state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    public func schedule<TState>(#state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    // MARK: IScheduler
    public var now: NSDate {
        return NSDate()
    }
}

extension Scheduler {
    // MARK: IScheduler
    public func schedule(#action: () -> ()) -> IDisposable? {
        return schedule(state: action, action: invoke)
    }
    
    public func schedule(#dueTime: NSTimeInterval, action: () -> ()) -> IDisposable? {
        return schedule(state: action, dueTime: dueTime, action: invoke)
    }

}

// MARK: private
private func invoke(_: IScheduler, action: () -> ()) -> IDisposable? {
    action()
    return nil
}

extension Scheduler {
    public static var immediate = ImmediateScheduler()
    
    public static func normalize(timeInterval: NSTimeInterval) -> NSTimeInterval {
        return timeInterval < 0 ? 0 : timeInterval
    }
}
