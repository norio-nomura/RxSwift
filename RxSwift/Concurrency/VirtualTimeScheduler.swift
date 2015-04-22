//
//  VirtualTimeScheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/20/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol VirtualTimeConverter {
    typealias AbsoluteTime
    typealias RelativeTime
    
    static func add(absolute: AbsoluteTime, relative: RelativeTime) -> AbsoluteTime
    static func toDate(absolute: AbsoluteTime) -> NSDate
    static func toRelative(timeInterval: NSTimeInterval) -> RelativeTime
}

public class VirtualTimeSchedulerBase<TAbsolute: Comparable, TRelative, Converter: VirtualTimeConverter where Converter.AbsoluteTime == TAbsolute, Converter.RelativeTime == TRelative>: Scheduler {
    
    // MARK: IScheduler
    public override var now: NSDate {
        return Converter.toDate(clock)
    }
    
    public func schedule<TState>(#state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        return scheduleAbsolute(state: state, dueTime: clock, action: action)
    }
    
    public func schedule<TState>(#state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        return scheduleRelative(state: state, dueTime: Converter.toRelative(dueTime), action: action)
    }
    
    // MARK: public
    public init(_ initialClock: TAbsolute) {
        clock = initialClock
    }
    
    public func start() {
        if !isEnabled {
            isEnabled = true
            while let next = getNext() {
                if next.dueTime > clock {
                    clock = next.dueTime
                }
                next.invoke()
            }
            isEnabled = false
        }
    }
    
    public func stop() {
        isEnabled = false
    }
    
    public func advanceTo(time: TAbsolute) {
        if time < clock {
            preconditionFailure("time(\(time)) < clock(\(clock))")
        }
        
        if time == clock {
            return
        }
        
        if !isEnabled {
            isEnabled = true
            while let next = getNext() where next.dueTime <= time {
                if next.dueTime > clock {
                    clock = next.dueTime
                }
                next.invoke()
            }
            isEnabled = false
        } else {
            preconditionFailure("advanceTo: can't advance while runninng")
        }
    }
    
    public func advanceBy(time: TRelative) {
        let dt = Converter.add(clock, relative: time)
        if dt < clock {
            preconditionFailure("dt(\(dt)) < clock(\(clock))")
        }
        
        if dt == clock {
            return
        }
        
        if !isEnabled {
            advanceTo(dt)
        } else {
            preconditionFailure("advanceBy: can't advance while runninng")
        }
    }
    
    public func sleep(time: TRelative) {
        let dt = Converter.add(clock, relative: time)
        if dt < clock {
            preconditionFailure("dt(\(dt)) < clock(\(clock))")
        }
        
        clock = dt
    }
    
    public func scheduleRelative<TState>(#state: TState, dueTime: TRelative, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        var runAt = Converter.add(clock, relative: dueTime)
        return scheduleAbsolute(state: state, dueTime: runAt, action: action)
    }
    
    public func scheduleAbsolute<TState>(#state: TState, dueTime: TAbsolute, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    public func getNext() -> ScheduledItemBase<TAbsolute>? {
        fatalError("Abstract method \(__FUNCTION__)")
    }

    // MARK: internal
    private(set) var clock: TAbsolute
    private(set) var isEnabled = false
}

public class VirtualTimeScheduler<TAbsolute: Comparable, TRelative, Converter: VirtualTimeConverter where Converter.AbsoluteTime == TAbsolute, Converter.RelativeTime == TRelative>: VirtualTimeSchedulerBase<TAbsolute, TRelative, Converter> {
    // MARK: public
    
    public override init(_ initialClock: TAbsolute) {
        super.init(initialClock)
    }
    
    public override func scheduleAbsolute<TState>(#state: TState, dueTime: TAbsolute, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        var si: ScheduledItemBase<TAbsolute>! = nil
        
        let run = {[unowned self] (scheduler: IScheduler, state: TState) -> IDisposable? in
            self.spinLock.wait {
                if let si = si {
                    if let index = find_instance(self.queue, si) {
                        removeAtIndex(&self.queue, index)
                    }
                }
            }
            return action(scheduler, state)
        }
        si = ScheduledItem(scheduler: self, state: state, action: action, dueTime: dueTime)
        spinLock.wait {
            queue.append(si)
            sort(&queue, {$0.dueTime < $1.dueTime})
        }
        return Disposable.create(si.cancel)
    }
    
    public override func getNext() -> ScheduledItemBase<TAbsolute>? {
        return spinLock.wait {
            if self.queue.isEmpty {
                return nil
            } else {
                return removeAtIndex(&self.queue, 0)
            }
        }
    }
    
    // MARK: private
    private var queue = [ScheduledItemBase<TAbsolute>]()
    private let spinLock = SpinLock()
}
