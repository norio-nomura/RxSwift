//
//  Observers.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/16/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal final class NopObserver: IObserver {
    typealias Input = Any
    
    static let instance: NopObserver = NopObserver()
    
    func onNext(value: Input) {
    }
    
    func onError(error: NSError) {
    }
    
    func onCompleted() {
    }
}

internal final class DoneObserver: IObserver {
    typealias Input = Any
    
    static let completed: DoneObserver = DoneObserver()
    
    var error = NSError(domain: "io.github.norio-nomura.RxSwift", code: 1, userInfo: nil)
    
    func onNext(value: Input) {
    }
    
    func onError(error: NSError) {
    }
    
    func onCompleted() {
    }
}

internal final class Observer<T>: IObserver {
    typealias Input = T
    private let observers: [ObserverOf<Input>]
    
    init(_ observers: [ObserverOf<Input>]) {
        self.observers = observers
    }
    
    init() {
        self.observers = []
    }
    
    func onNext(value: Input) {
        for observer in observers {
            observer.onNext(value)
        }
    }
    
    func onError(error: NSError) {
        for observer in observers {
            observer.onError(error)
        }
    }
    
    func onCompleted() {
        for observer in observers {
            observer.onCompleted()
        }
    }
    
    func add(observer: ObserverOf<Input>) -> Observer {
        var newObservers = observers
        newObservers.append(observer)
        return Observer(newObservers)
    }
    
    func add<TObserver: IObserver where TObserver.Input == Input>(observer: TObserver) -> Observer {
        return add(ObserverOf(observer))
    }
    
    func remove(observer: ObserverOf<Input>) -> Observer {
        if observers.isEmpty {
            return self
        } else {
            let newObservers = observers.filter {$0 != observer}
            return Observer(newObservers)
        }
    }

    func remove<TObserver: IObserver where TObserver.Input == Input>(observer: TObserver) -> Observer {
        return remove(ObserverOf(observer))
    }
}
