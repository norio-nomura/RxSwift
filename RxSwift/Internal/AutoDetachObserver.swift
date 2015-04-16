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
    
    init<TObserver: IObserver where TObserver.Input == Input>(_ observer: TObserver) {
        _observer = ObserverOf(observer)
    }
    
    deinit {
        dispose()
    }
    
    // MARK: private
    override func onNextCore(value: Input) {
        _observer.onNext(value)
    }
    
    override func onErrorCore(error: NSError) {
        _observer.onError(error)
        dispose()
    }
    
    override func onCompletedCore() {
        _observer.onCompleted()
        dispose()
    }
    
    override func dispose(disposing: Bool) {
        super.dispose(disposing)
        if disposing {
            disposable?.dispose()
        }
    }
    
    private let _observer: ObserverOf<T>
    private let m = SingleAssignmentDisposable()
}
