//
//  Observable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IObservable: class {
    typealias ObserverType: IObserver
    func subscribe(observer: ObserverType) -> IDisposable?
}

public class Observable<T: IObserver>: IObservable {
    // MARK: IObservable
    public typealias ObserverType = T
    
    public func subscribe(observer: ObserverType) -> IDisposable? {
        return _subscribeSelf(self, observer)
    }
    
    // MARK: public
    public typealias Value = ObserverType.Value
    
    // MARK: internal
    internal typealias SubscribeSelf = (Observable, ObserverType) -> IDisposable?
    
    internal init(_ subscribeSelf: SubscribeSelf) {
        _subscribeSelf = subscribeSelf
    }
    
    /// MARK: private
    private let _subscribeSelf: SubscribeSelf
}

// MARK: - Extensions

/**
*  Place extensions in separate file cause link error. So, place below.
*/

// MARK: subscribe

public extension Observable {
    
    public func subscribe(onNext: Value -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext) as! ObserverType)
    }
    
    public func subscribe(onNext: Value -> (), _ onError: NSError -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext, onError) as! ObserverType)
    }
    
    public func subscribe(onNext: Value -> (), _ onCompleted: () -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext, onCompleted) as! ObserverType)
    }
    
    public func subscribe(onNext: Value -> (), _ onError: NSError -> (), _ onCompleted: () -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext, onError, onCompleted) as! ObserverType)
    }
}

// MARK: instance methods

public extension Observable {
    /**
    Projects each element of an observable sequence into a new form
    
    :param: selector selector selector A transform function to apply to each source element
    
    :returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    public func map<TResult>(selector: Value -> TResult) -> Observable<Observer<TResult>> {
        return _map(self, selector)
    }
    
    /**
    Projects each element of an observable sequence into a new form by incorporating the element's index.
    
    :param: selector selector A transform function to apply to each source element; the second parameter of the function represents the index of the source element.
    
    :returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    public func select<TResult>(selector: (Value, Int) -> TResult) -> Observable<Observer<TResult>> {
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
    public class func just(value: Value) -> Observable {
        return _just(value)
    }
    
    public class func returnValue(value: Value) -> Observable {
        return _just(value)
    }
    
    /**
    Returns an observable sequence that contains a single element, using the specified scheduler to send out observer messages.
    
    :param: value     value Single element in the resulting observable sequence.
    :param: scheduler scheduler Scheduler to send the single element on. If not specified, defaults to Scheduler.immediate.
    
    :returns: An observable sequence containing the single specified element.
    */
    public class func just(value: Value, scheduler: IScheduler) -> Observable {
        return _just(value, scheduler: scheduler)
    }
    
    public class func returnValue(value: Value, scheduler: IScheduler) -> Observable {
        return _just(value, scheduler: scheduler)
    }
}
