//
//  Sink.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/15/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal class Sink<TSource>: IDisposable {
    init<TObserver: IObserver where TObserver.Input == TSource>(observer: TObserver, cancel: IDisposable?) {
        self.observer = ObserverOf(observer)
        self.cancel = cancel
    }
    
    func dispose() {
        var cancel: IDisposable? = nil
        spinLock.wait {
            observer = nil
            cancel = self.cancel
            self.cancel = nil
        }
        cancel?.dispose()
    }
    
    func getForwarder<TObserver: IObserver where TObserver.Input == TSource>() -> TObserver {
        return Forwarder<TSource>(self) as! TObserver
    }
    
    var observer: ObserverOf<TSource>?
    // MARK: private
    private var cancel: IDisposable?
    private var spinLock = SpinLock()
}

internal final class Forwarder<TSource>: IObserver {
    typealias Input = TSource
    let forward: Sink<TSource>

    init(_ forward: Sink<TSource>) {
        self.forward = forward
    }
    
    func onNext(value: Input) {
        forward.observer?.onNext(value)
    }
    
    func onError(error: NSError) {
        forward.observer?.onError(error)
        forward.dispose()
    }
    
    func onCompleted() {
        forward.observer?.onCompleted()
        forward.dispose()
    }
}
