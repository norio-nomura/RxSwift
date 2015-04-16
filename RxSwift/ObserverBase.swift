//
//  ObserverBase.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

/**
*   base class of IObserver
*/
// MARK: IObserver
extension ObserverBase: IObserver {
    typealias Input = T
    
    public func onNext(value: Input) {
        if stopped == 0 {
            onNextCore(value)
        }
    }
    
    public func onError(error: NSError) {
        if stop() {
            onErrorCore(error)
        }
    }
    
    public func onCompleted() {
        if stop() {
            onCompletedCore()
        }
    }
}

// MARK: IDisposable
extension ObserverBase: IDisposable {
    public func dispose() {
        dispose(true)
    }
}

public class ObserverBase<T> {
    public func fail(error: NSError) -> Bool {
        if stop() {
            onError(error)
            return true
        }
        return false
    }
    
    // MARK: internal
    deinit {
        dispose()
    }

    func onNextCore(value: Input) {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    func onErrorCore(error: NSError) {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    func onCompletedCore() {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    func dispose(disposing: Bool) {
        if disposing {
           stop()
        }
    }

    // MARK: private
    private func stop() -> Bool {
        return OSAtomicCompareAndSwap32Barrier(0, 1, &stopped)
    }
    private var stopped: Int32 = 0
}
