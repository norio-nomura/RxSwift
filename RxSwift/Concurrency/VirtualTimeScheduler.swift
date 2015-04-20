//
//  VirtualTimeScheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/20/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public class VirtualTimeSchedulerBase<TAbsolute: Comparable, TRelative>: IScheduler {
    
    // MARK: IScheduler
    
    public var now: NSDate {
        return toDate(clock)
    }
    
    public func schedule<TState>(state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        return scheduleAbsolute(state, dueTime: clock, action: action)
    }
    
    public func schedule<TState>(state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        return scheduleRelative(state, dueTime: toRelative(dueTime), action: action)
    }
    
    // MARK: public
    public private(set) var clock: TAbsolute
    public private(set) var isEnabled = false
    
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
            preconditionFailure("can't advance while runninng")
        }
        
    }
    
    // MARK: internal
    init(initialClock: TAbsolute) {
        clock = initialClock
    }
    
    func add(absolute: TAbsolute, relative: TRelative) -> TAbsolute {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    func toDate(absolute: TAbsolute) -> NSDate {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    func toRelative(timeInterval: NSTimeInterval) -> TRelative {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    func scheduleAbsolute<TState>(state: TState, dueTime: TAbsolute, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    func scheduleRelative<TState>(state: TState, dueTime: TRelative, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
        var runAt = add(clock, relative: dueTime)
        return scheduleAbsolute(state, dueTime: runAt, action: action)
    }
    
    func getNext() -> ScheduledItemBase<TAbsolute>? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
}

public class VirtualTimeScheduler<TAbsolute: Comparable, TRelative>: VirtualTimeSchedulerBase<TAbsolute, TRelative> {
    // MARK: public
    
    public override func scheduleAbsolute<TState>(state: TState, dueTime: TAbsolute, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
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
    
    // MARK: internal
    override func getNext() -> ScheduledItemBase<TAbsolute>? {
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
