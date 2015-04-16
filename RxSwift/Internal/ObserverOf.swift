//
//  ObserverOf.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/15/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal class ObserverOf<T>: IObserver {
    typealias Value = T
    
    // MARK: IObserver
    func onNext(value: Value) {
        _next(value)
    }
    
    func onError(error: NSError) {
        _error(error)
    }
    
    func onCompleted() {
        _completed()
    }
    
    // MARK: internal
    init() {
        
    }
    
    init(_ next: Value -> (), _ error: NSError -> (), _ completed: () -> ()) {
        _next = next
        _error = error
        _completed = completed
    }
    
    convenience init<TObserver: IObserver where TObserver.Value == Value>(_ observer: TObserver) {
        self.init(observer.onNext, observer.onError, observer.onCompleted)
    }
    
    // MARK: private
    private var _next: Value -> () = {_ in}
    private var _error: NSError -> () = {_ in}
    private var _completed: () -> () = {}
}

internal class WeakObserverOf<T>: ObserverOf<T> {
    init<TObserver: IObserver where TObserver.Value == Value>(
        _ observer: TObserver,
        _ bindNext: TObserver -> Value -> (),
        _ bindError: TObserver -> NSError -> (),
        _ bindCompleted: TObserver -> () -> ())
    {
        super.init({ [weak observer] in
            if let b = observer {
                bindNext(b)($0)
            }
        }, { [weak observer] in
            if let b = observer {
                bindError(b)($0)
            }
        }, { [weak observer] in
            if let b = observer {
                bindCompleted(b)($0)
            }
        })
    }
}
