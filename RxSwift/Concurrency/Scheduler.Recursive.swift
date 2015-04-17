//
//  Scheduler.Recursive.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/17/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public func schedule(scheduler: IScheduler, action: (() -> ()) -> ()) -> IDisposable? {
    return schedule(scheduler, action) {
        (_action, _self) in _action {_self(_action)}
    }
}

public func schedule<TState>(scheduler: IScheduler, state: TState, action: (TState, TState -> ()) -> ()) ->  IDisposable? {
    return scheduler.schedule((state: state, action: action), action: invokeRec1)
}

private func invokeRec1<TState>(scheduler: IScheduler, pair: (state: TState, action: (TState, TState -> ()) -> ())) -> IDisposable? {
    var group = CompositeDisposable()
    var lock = SpinLock()
    var state = pair.state
    let action = pair.action
    var recursiveAction: (TState -> ())? = nil
    recursiveAction = { state1 in
        action(state1) { state2 in
            var isAdded = false
            var isDone = false
            var d: IDisposable? = nil
            d = scheduler.schedule(state2) { scheduler1, state3 in
                lock.wait {
                    if isAdded {
                        if let d = d {
                            group.remove(d)
                        }
                    } else {
                        isDone = true
                    }
                }
                recursiveAction?(state3)
                return nil
            }
            
            lock.wait {
                if !isDone {
                    if let d = d {
                        group.append(d)
                    }
                    isAdded = true
                }
            }
        }
    }
    recursiveAction?(state)
    return group
}

