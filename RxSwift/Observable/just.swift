//
//  just.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/2/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: public

/**
Returns an observable sequence that contains a single element, using the specified scheduler to send out observer messages.

:param: value Single element in the resulting observable sequence.

:returns: An observable sequence containing the single specified element.
*/
public func just<T>(value: T) -> Observable<Observer<T>> {
    return _just(value)
}

public func returnValue<T>(value: T) -> Observable<Observer<T>> {
    return _just(value)
}

/**
Returns an observable sequence that contains a single element, using the specified scheduler to send out observer messages.

:param: value     value Single element in the resulting observable sequence.
:param: scheduler scheduler Scheduler to send the single element on. If not specified, defaults to Scheduler.immediate.

:returns: An observable sequence containing the single specified element.
*/
public func just<T: IObserver>(value: T.Value, scheduler: IScheduler) -> Observable<T> {
    return _just(value, scheduler: scheduler)
}

public func returnValue<T: IObserver>(value: T.Value, scheduler: IScheduler) -> Observable<T> {
    return _just(value, scheduler: scheduler)
}

// MARK: internal

internal func _just<T: IObserver>(value: T.Value, scheduler: IScheduler = Scheduler.immediate) -> Observable<T> {
    return AnonymousObservable({observer in
        return scheduler.schedule {
            observer.onNext(value)
            observer.onCompleted()
        }
    })
}
