//
//  AnonymousObservable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: internal
public final class AnonymousObservable<T>: ObservableBase<T> {
    public init<TObserver: IObserver where TObserver.Input == Output>(_ subscribe: TObserver -> IDisposable?) {
        _subscribe = subscribe as! AnyObject -> IDisposable?
        super.init()
    }
    
    override func subscribeCore<TObserver: IObserver where TObserver.Input == Output>(observer: TObserver) -> IDisposable? {
        return _subscribe(observer)
    }
    
    // MARK: private
    private let _subscribe: AnyObject -> IDisposable?
}
