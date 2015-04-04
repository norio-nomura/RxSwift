//
//  Observer.swift
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
public class Observer<T>: IObserver, IDisposable {
    typealias Value = T
    
    // MARK: IObserver
    public func onNext(value: Value) {
        if stop() {
            next(value)
        }
    }
    
    public func onError(error: NSError) {
        if stop() {
            self.error(error)
        }
    }
    
    public func onCompleted() {
        if stop() {
            completed()
        }
    }
    
    // MARK: IDisposable
    public func dispose() {
        stop()
    }
    
    public func fail(error: NSError) -> Bool {
        if stop() {
            self.error(error)
            return true
        }
        return false
    }
    
    // MARK: internal
    deinit {
        dispose()
    }
    
    func next(_: Value) {
        fatalError("subclass needs overrided \(__FUNCTION__)")
    }
    
    func error(_: NSError) {
        fatalError("subclass needs overrided \(__FUNCTION__)")
    }
    
    func completed() {
        fatalError("subclass needs overrided \(__FUNCTION__)")
    }
    
    // MARK: private
    
    /**
    :returns: true if isStopped changed from 0 to 1
    */
    private func stop() -> Bool {
        return OSAtomicCompareAndSwap32Barrier(0, 1, &stopped)
    }
    private var stopped: Int32 = 0
}
