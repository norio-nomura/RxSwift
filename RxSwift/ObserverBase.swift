//
//  ObserverBase.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IObserver: class {
    typealias Value
    func onNext(value: Value)
    func onError(error: NSError)
    func onCompleted()
}

/**
*   base class of IObserver
*/
public class ObserverBase<T>: IObserver, IDisposable {
    typealias Value = T
    
    // MARK: IObserver
    public func onNext(value: Value) {
        if stop() {
            _observer.onNext(value)
        }
    }
    
    public func onError(error: NSError) {
        if stop() {
            _observer.onError(error)
        }
    }
    
    public func onCompleted() {
        if stop() {
            _observer.onCompleted()
        }
    }
    
    // MARK: IDisposable
    public func dispose() {
        if stop() {
            _dispose()
        }
    }
    
    public func fail(error: NSError) -> Bool {
        if stop() {
            _observer.onError(error)
            return true
        }
        return false
    }
    
    // MARK: internal
    init(_ next: Value -> (), _ error: NSError -> (), _ completed: () -> ()) {
        _observer = ObserverOf(next, error, completed)
    }
    
//    init<TObserver: IObserver where TObserver.Value == Value>(_ observer: TObserver) {
//        _observer = ObserverOf(observer)
//    }
//    
    typealias BindNext = ObserverBase -> Value -> ()
    typealias BindError = ObserverBase -> NSError -> ()
    typealias BindCompleted = ObserverBase -> () -> ()
    typealias BindDispose = ObserverBase -> () -> ()
    
    init(_ bindNext: BindNext, _ bindError: BindError, _ bindCompleted: BindCompleted, _ bindDispose: BindDispose)
    {
        _observer = WeakObserverOf(self, bindNext, bindError, bindCompleted)
        _dispose = { [weak self] in
            if let s = self {
                bindDispose(s)($0)
            }
        }
    }
    
    deinit {
        dispose()
    }
    
    // MARK: private
    /**
    :returns: true if isStopped changed from 0 to 1
    */
    private var _observer = ObserverOf<Value>()
    private var _dispose: () -> () = {}
    
    private func stop() -> Bool {
        return OSAtomicCompareAndSwap32Barrier(0, 1, &stopped)
    }
    private var stopped: Int32 = 0
}
