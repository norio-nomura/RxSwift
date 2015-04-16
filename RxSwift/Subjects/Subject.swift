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
    typealias Output = T
    typealias Input = T
    
    public override init() {
    }
    
    // MARK: IObservable
    public override func subscribe<TObserver : IObserver where TObserver.Input == Output>(observer: TObserver) -> IDisposable? {
        return nil
    }
    
    // MARK: IObserver
    public func onNext(value: Output) {
        
    }
    
    public func onError(error: NSError) {
        
    }
    
    public func onCompleted() {
        
    }
    
    // MARK: private


    private func unsubscribe<TObserver : IObserver where TObserver.Input == Output>(observer: TObserver) {
        
    }
    
    private var observer = ObserverOf<T>()
}

private class Subscription<T>: IDisposable {
    var subject: Subject<T>?
    var observer: ObserverOf<T>?
    init<TObserver : IObserver where TObserver.Input == T>(subject: Subject<T>, observer: TObserver) {
        self.subject = subject
        self.observer = ObserverOf(observer)
    }
    
    // MARK: IDisposable
    func dispose() {
//        var observer:
        spinLock.wait {
            if observer != nil {
//                subject?.unsubscribe(observer)
                observer = nil
                subject = nil
            }
        }
    }
    private var spinLock = SpinLock()
}

