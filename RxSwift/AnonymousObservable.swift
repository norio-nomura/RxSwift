//
//  AnonymousObservable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: internal
internal final class AnonymousObservable<T: IObserver>: ObservableBase<T> {
    typealias Subscribe = T -> IDisposable?
    
    init(_ subscribe: Subscribe) {
        _subscribe = subscribe
        super.init()
    }
    
    override func subscribeCore(observer: T) -> IDisposable? {
        return _subscribe(observer)
    }
    
    // MARK: private
    private let _subscribe: Subscribe
}
