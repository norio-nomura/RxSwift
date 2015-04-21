//
//  Scheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public struct Scheduler {
    public static var now: NSDate {
        return NSDate()
    }
    
    public static func normalize(timeInterval: NSTimeInterval) -> NSTimeInterval {
        return timeInterval < 0 ? 0 : timeInterval
    }
    
    public static var immediate = ImmediateScheduler()
}

public func schedule(scheduler: IScheduler, action: () -> ()) -> IDisposable? {
    return scheduler.schedule(state: action, action: invoke)
}

public func schedule(scheduler: IScheduler, dueTime: NSTimeInterval, action: () -> ()) -> IDisposable? {
    return scheduler.schedule(state: action, dueTime: dueTime, action: invoke)
}

private func invoke(_: IScheduler, action: () -> ()) -> IDisposable? {
    action()
    return nil
}
