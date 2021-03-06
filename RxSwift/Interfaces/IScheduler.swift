//
//  IScheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/17/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IScheduler: class {
    var now: NSDate {get}
    
    func schedule<TState>(#state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable?
    func schedule<TState>(#state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable?
    
    // Is absolute time scheduler needed?
    //    func schedule<TState>(state: TState, dueTime: NSDate, action: (IScheduler, TState) -> IDisposable?) -> IDisposable?

    // Scheduler.Simple.cs
    func schedule(#action: () -> ()) -> IDisposable?
    func schedule(#dueTime: NSTimeInterval, action: () -> ()) -> IDisposable?
}

public protocol ISchedulerPeriodic: class {
    func schedule<TState>(#state: TState, period: NSTimeInterval, action: TState -> TState) -> IDisposable?
}

public protocol ISchedulerLongRunning: class {
    func scheduleLongRunning<TState>(#state: TState, action: (TState, ICancelable) -> ()) -> IDisposable?
}