//
//  AnonymousObserver.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: internal
public final class AnonymousObserver<T>: ObserverBase<T> {
    public init(_ next: Input -> (), _ error: NSError -> (), _ completed: () -> ()) {
        _observer = ObserverOf(nil, next, error, completed)
    }
    
    public convenience init(_ next: Input -> ()) {
        self.init(next, {_ in}, {})
    }
    
    public convenience init(_ next: Input -> (), _ error: NSError -> ()) {
        self.init(next, error, {})
    }
    
    public convenience init(_ next: Input -> (), _ completed: () -> ()) {
        self.init(next, {_ in}, completed)
    }
    
    public init<TObserver: IObserver where TObserver.Input == Input>(_ observer: TObserver) {
        _observer = ObserverOf(observer)
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
    
    private let _observer: ObserverOf<T>
}
