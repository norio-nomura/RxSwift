//
//  Observable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

/**
*  Abstract base class of IObservable
*/
public class Observable<T>: IObservable {
    // MARK: IObservable
    typealias Output = T
    
    public func subscribe<TObserver: IObserver where TObserver.Input == Output>(observer: TObserver) -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    // MARK: internal
//    init() {}
}

// MARK: - Extensions

/**
*  Place extensions in separate file cause link error. So, place below.
*/

// MARK: subscribe

public extension Observable {
    public func subscribe(onNext: Output -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext))
    }
    
    public func subscribe(onNext: Output -> (), _ onError: NSError -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext, onError))
    }
    
    public func subscribe(onNext: Output -> (), _ onCompleted: () -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext, onCompleted))
    }
    
    public func subscribe(onNext: Output -> (), _ onError: NSError -> (), _ onCompleted: () -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext, onError, onCompleted))
    }
}

// MARK: instance methods

public extension Observable {
    /**
    Projects each element of an observable sequence into a new form
    
    :param: selector selector selector A transform function to apply to each source element
    
    :returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    public func map<TResult>(selector: Output -> TResult) -> Observable<TResult> {
        return _map(self, selector)
    }
    
    /**
    Projects each element of an observable sequence into a new form by incorporating the element's index.
    
    :param: selector selector A transform function to apply to each source element; the second parameter of the function represents the index of the source element.
    
    :returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    public func select<TResult>(selector: (Output, Int) -> TResult) -> Observable<TResult> {
        return _select(self, selector)
    }
}


// MARK: class methods

public extension Observable {
    /**
    Returns an observable sequence that contains a single element, using the specified scheduler to send out observer messages.
    
    :param: value Single element in the resulting observable sequence.
    
    :returns: An observable sequence containing the single specified element.
    */
    public class func just(value: Output) -> Observable {
        return _just(value)
    }
    
    public class func returnValue(value: Output) -> Observable {
        return _just(value)
    }
    
    /**
    Returns an observable sequence that contains a single element, using the specified scheduler to send out observer messages.
    
    :param: value     value Single element in the resulting observable sequence.
    :param: scheduler scheduler Scheduler to send the single element on. If not specified, defaults to Scheduler.immediate.
    
    :returns: An observable sequence containing the single specified element.
    */
    public class func just(value: Output, scheduler: IScheduler) -> Observable {
        return _just(value, scheduler: scheduler)
    }
    
    public class func returnValue(value: Output, scheduler: IScheduler) -> Observable {
        return _just(value, scheduler: scheduler)
    }
}

func subscribeSafe<TObservable: IObservable, TObserver: IObserver where TObservable.Output == TObserver.Input>(observable: TObservable, observer: TObserver) -> IDisposable? {
    if let producer = observable as? Producer<TObservable.Output> {
        return producer.subscribeRaw(observer)
    }
    return observable.subscribe(observer)
}
