//
//  Scheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public class Scheduler: IScheduler {
    
    /**
    Swift 1.2 can't allow overriding generic methods of non-generic class with generic class.
    So, I use methods for overriding `scheduleCore()`
    See: https://devforums.apple.com/thread/268824
    */
    
    // MARK: ISchedulerCore
    public final func schedule<TState>(#state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        return scheduleCore(state: state, action: {return action($0, state)})
    }
    
    public final func schedule<TState>(#state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        return scheduleCore(state: state, dueTime: dueTime, action: {return action($0, state)})
    }
    
    // MARK: IScheduler
    public var now: NSDate {
        return NSDate()
    }
    
    // MARK: internal
    func scheduleCore(#state: Any, action: IScheduler -> IDisposable?) -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    func scheduleCore(#state: Any, dueTime: NSTimeInterval, action: IScheduler -> IDisposable?) -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
}

extension Scheduler {
    // MARK: IScheduler
    public final func schedule(#action: () -> ()) -> IDisposable? {
        return schedule(state: action, action: invoke)
    }
    
    public final func schedule(#dueTime: NSTimeInterval, action: () -> ()) -> IDisposable? {
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
