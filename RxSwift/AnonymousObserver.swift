//
//  AnonymousObserver.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: internal
internal final class AnonymousObserver<T>: Observer<T> {
    typealias Next = T -> ()
    typealias Error = NSError -> ()
    typealias Completed = () -> ()
    
    init(_ onNext: Next, _ onError: Error, _ onCompleted: Completed) {
        println("\(__FUNCTION__)")
        _next = onNext
        _error = onError
        _completed = onCompleted
    }
    
    convenience init(_ onNext: Next) {
        self.init(onNext, {_ in}, {})
    }
    
    convenience init(_ onNext: Next, _ onError: Error) {
        self.init(onNext, onError, {})
    }
    
    convenience init(_ onNext: Next, _ onCompleted: Completed) {
        self.init(onNext, {_ in}, onCompleted)
    }
    
    deinit {
        println("\(__FUNCTION__)")
    }
    
    // MARK: override Observer
    override func next(value: T) {
        _next(value)
    }
    
    override func error(error: NSError) {
        _error(error)
    }
    
    override func completed() {
        _completed()
    }
    
    // MARK: private
    private var _next: Next
    private var _error: Error
    private var _completed: Completed
}
