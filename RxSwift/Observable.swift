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
    public final func subscribe() -> IDisposable? {
        return subscribe(AnonymousObserver({_ in}))
    }
    
    public final func subscribe(onNext: Output -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext))
    }
    
    public final func subscribe(onNext: Output -> (), _ onError: NSError -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext, onError))
    }
    
    public final func subscribe(onNext: Output -> (), _ onCompleted: () -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext, onCompleted))
    }
    
    public final func subscribe(onNext: Output -> (), _ onError: NSError -> (), _ onCompleted: () -> ()) -> IDisposable? {
        return subscribe(AnonymousObserver(onNext, onError, onCompleted))
    }
}

// MARK: instance methods

// MARK: class methods

func subscribeSafe<TObservable: IObservable, TObserver: IObserver where TObservable.Output == TObserver.Input>(observable: TObservable, observer: TObserver) -> IDisposable? {
    if let producer = observable as? Producer<TObservable.Output> {
        return producer.subscribeRaw(observer)
    }
    return observable.subscribe(observer)
}
