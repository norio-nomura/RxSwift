//
//  ObserverOf.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/15/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal class ObserverOf<T>: IObserver {
    typealias Input = T
    
    // MARK: IObserver
    func onNext(value: Input) {
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
        objectIdentifier = ObjectIdentifier(self)
    }
    
    init(_ identifierObject: AnyObject?, _ next: Input -> (), _ error: NSError -> (), _ completed: () -> ()) {
        _next = next
        _error = error
        _completed = completed
        objectIdentifier = ObjectIdentifier(identifierObject ?? self)
    }
    
    convenience init<TObserver: IObserver where TObserver.Input == Input>(_ observer: TObserver) {
        self.init(nil, observer.onNext, observer.onError, observer.onCompleted)
    }
    
    // MARK: private
    private var _next: Input -> () = {_ in}
    private var _error: NSError -> () = {_ in}
    private var _completed: () -> () = {}
    private var objectIdentifier: ObjectIdentifier?
}

internal class WeakObserverOf<T>: ObserverOf<T> {
    init<TObserver: IObserver where TObserver.Input == Input>(
        _ observer: TObserver,
        _ bindNext: TObserver -> Input -> (),
        _ bindError: TObserver -> NSError -> (),
        _ bindCompleted: TObserver -> () -> ())
    {
        super.init(observer, { [weak observer] in
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

extension ObserverOf: Equatable {
}

func == <T>(lhs: ObserverOf<T>, rhs: ObserverOf<T>) -> Bool {
    return lhs.objectIdentifier == rhs.objectIdentifier
}
