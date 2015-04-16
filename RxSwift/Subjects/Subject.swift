//
//  Subject.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/16/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol ISubject: class, IObserver, IObservable {
}

public final class Subject<T>: Observable<T>, ISubject {
    typealias Input = T
    
    public override init() {
    }
    
    // MARK: IObservable
    public override func subscribe<TObserver : IObserver where TObserver.Input == Output>(observer: TObserver) -> IDisposable? {
        spinLock.wait {
            _observer = _observer.add(observer)
        }
        return Subscription(self, observer)
    }
    
    // MARK: IObserver
    public func onNext(value: T) {
        _observer.onNext(value)
    }
    
    public func onError(error: NSError) {
        var oldObserver: Observer<T>? = nil
        spinLock.wait {
            oldObserver = _observer
            _observer = Observer<T>([])
        }
        oldObserver?.onError(error)
    }
    
    public func onCompleted() {
        var oldObserver: Observer<T>? = nil
        spinLock.wait {
            oldObserver = _observer
            _observer = Observer<T>([])
        }
        oldObserver?.onCompleted()
    }
    
    // MARK: private


    private func unsubscribe(observer: ObserverOf<Output>) {
        spinLock.wait {
            _observer = _observer.remove(observer)
        }
    }
    
    private var _observer = Observer<T>()
    private var spinLock = SpinLock()
}

private class Subscription<T>: IDisposable {
    var subject: Subject<T>?
    var observer: ObserverOf<T>?
    init<TObserver : IObserver where TObserver.Input == T>(_ subject: Subject<T>, _ observer: TObserver) {
        self.subject = subject
        self.observer = ObserverOf(observer)
    }
    
    // MARK: IDisposable
    func dispose() {
        spinLock.wait {
            if let _observer = observer {
                subject?.unsubscribe(_observer)
                observer = nil
                subject = nil
            }
        }
    }
    var spinLock = SpinLock()
}

