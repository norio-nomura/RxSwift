//
//  Just.swift
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
public func just<T>(value: T) -> Observable<T> {
    return _just(value)
}

public func returnValue<T>(value: T) -> Observable<T> {
    return _just(value)
}

/**
Returns an observable sequence that contains a single element, using the specified scheduler to send out observer messages.

:param: value     value Single element in the resulting observable sequence.
:param: scheduler scheduler Scheduler to send the single element on. If not specified, defaults to Scheduler.immediate.

:returns: An observable sequence containing the single specified element.
*/
public func just<T>(value: T, scheduler: IScheduler) -> Observable<T> {
    return _just(value, scheduler: scheduler)
}

public func returnValue<T>(value: T, scheduler: IScheduler) -> Observable<T> {
    return _just(value, scheduler: scheduler)
}

// MARK: internal

internal func _just<T>(value: T, scheduler: IScheduler = Scheduler.immediate) -> Observable<T> {
    return Just(value, scheduler)
//    return AnonymousObservable({observer in
//        return scheduler.schedule {
//            observer.onNext(value)
//            observer.onCompleted()
//        }
//    })
}

internal class Just<TResult>: Producer<TResult> {
    init(_ value: TResult, _ scheduler: IScheduler) {
        self.value = value
        self.scheduler = scheduler
    }
    
    internal override func run<TObserver: IObserver where TObserver.Input == Output>(observer: TObserver, cancel: IDisposable?, setSink: IDisposable? -> ()) -> IDisposable? {
        var sink = JustSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
    
    private let value: TResult
    private let scheduler: IScheduler
}

private class JustSink<TResult>: Sink<TResult> {
    let parent: Just<TResult>
    
    init<TObserver : IObserver where TObserver.Input == TResult>(parent: Just<TResult>, observer: TObserver, cancel: IDisposable?) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> IDisposable? {
        return schedule(parent.scheduler, invoke)
    }
    
    func invoke() {
        super.observer?.onNext(parent.value)
        super.observer?.onCompleted()
        super.dispose()
    }
}
