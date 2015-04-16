//
//  AutoDetachObserver.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: internal
internal final class AutoDetachObserver<T>: ObserverBase<T> {
    // MARK: internal
    var disposable: IDisposable? {
        get {
            return m.disposable
        }
        set {
            m.disposable = newValue
        }
    }
    
    init<TObserver: IObserver where TObserver.Value == Value>(_ observer: TObserver) {
        _observer = ObserverOf(observer)
        super.init(
            AutoDetachObserver.nextImpl as! BindNext,
            AutoDetachObserver.errorImpl as! BindError,
            AutoDetachObserver.completedImpl as! BindCompleted,
            AutoDetachObserver.disposeImpl as! BindDispose
        )
    }
    
    deinit {
        dispose()
    }
    
    // MARK: private
    func nextImpl(value: T) {
        _observer.onNext(value)
    }
    
    func errorImpl(error: NSError) {
        _observer.onError(error)
        dispose()
    }
    
    func completedImpl() {
        _observer.onCompleted()
        dispose()
    }
    
    func disposeImpl() {
        disposable?.dispose()
    }
    
    private let _observer: ObserverOf<T>
    private let m = SingleAssignmentDisposable()
}
