//
//  AutoDetachObserver.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: internal
internal class AutoDetachObserver<U: IObserver>: Observer<U.Value> {
    // MARK: IDisposable
    override func dispose() {
        super.dispose()
        disposable?.dispose()
    }
    
    // MARK: internal
    var disposable: IDisposable? {
        get {
            return m.disposable
        }
        set {
            m.disposable = newValue
        }
    }
    
    init(_ observer: U) {
        self.observer = observer
    }
    
    deinit {
        dispose()
    }
    
    // MARK: override Observer
    override func next(value: U.Value) {
        observer.onNext(value)
    }
    
    override func error(error: NSError) {
        observer.onError(error)
        dispose()
    }
    
    override func completed() {
        observer.onCompleted()
        dispose()
    }
    
    // MARK: private
    private let observer: U
    private let m = SingleAssignmentDisposable()
}
