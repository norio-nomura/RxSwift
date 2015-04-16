//
//  Select.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: public

/**
Projects each element of an observable sequence into a new form.

:param: observable IObservable
:param: selector   selector A transform function to apply to each source element

:returns: observable An observable sequence whose elements are the result of invoking the transform function on each element of source.
*/
public func map<TSource, TResult>(observable: Observable<TSource>, selector: TSource -> TResult) -> Observable<TResult> {
    return _map(observable, selector)
}

/**
Projects each element of an observable sequence into a new form by incorporating the element's index.

:param: observable IObservable
:param: selector   selector A transform function to apply to each source element; the second parameter of the function represents the index of the source element.

:returns: observable An observable sequence whose elements are the result of invoking the transform function on each element of source.
*/
public func select<TSource, TResult>(observable: Observable<TSource>, selectorI: (TSource, Int) -> TResult) -> Observable<TResult> {
    return _select(observable, selectorI)
}


// MARK: internal

internal func _map<TSource, TResult>(observable: Observable<TSource>, selector: TSource -> TResult) -> Observable<TResult> {
    return Select(observable, selector)
}

internal func _select<TSource, TResult>(observable: Observable<TSource>, selectorI: (TSource, Int) -> TResult) -> Observable<TResult> {
    return Select(observable, selectorI)
}

// MARK: private
internal final class Select<TSource, TResult>: Producer<TResult> {

    private let source: Observable<TSource>
    private var selector: (TSource -> TResult)? = nil
    private var selectorI: ((TSource, Int) -> TResult)? = nil
    
    init(_ source: Observable<TSource>, _ selector: TSource -> TResult) {
        self.source = source
        self.selector = selector
    }

    init(_ source: Observable<TSource>, _ selectorI: (TSource, Int) -> TResult) {
        self.source = source
        self.selectorI = selectorI
    }
    
    override func run<TObserver : IObserver where TObserver.Value == Value>(observer: TObserver, cancel: IDisposable?, setSink: IDisposable? -> ()) -> IDisposable? {
        if let selector = selector {
            var sink = SelectSink(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return subscribeSafe(source, sink)
        } else if let selectorI = selectorI {
            var sink = SelectISink(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return subscribeSafe(source, sink)
        } else {
            fatalError("something wrong")
        }
    }
}

internal final class SelectSink<TSource, TResult>: Sink<TResult>, IObserver {
    typealias Value = TSource
    
    init<TObserver : IObserver where TObserver.Value == TResult>(parent: Select<TSource, TResult>, observer: TObserver, cancel: IDisposable?) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func onNext(value: Value) {
        var result = parent.selector!(value)
        observer?.onNext(result)
    }
    
    func onError(error: NSError) {
        observer?.onError(error)
        dispose()
    }
    
    func onCompleted() {
        observer?.onCompleted()
        dispose()
    }

    // MARK: private
    private let parent: Select<TSource, TResult>
}

internal final class SelectISink<TSource, TResult>: Sink<TResult>, IObserver {
    typealias Value = TSource
    
    init<TObserver : IObserver where TObserver.Value == TResult>(parent: Select<TSource, TResult>, observer: TObserver, cancel: IDisposable?) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func onNext(value: Value) {
        var result = parent.selectorI!(value, index++)
        observer?.onNext(result)
    }
    
    func onError(error: NSError) {
        observer?.onError(error)
        dispose()
    }
    
    func onCompleted() {
        observer?.onCompleted()
        dispose()
    }
    
    // MARK: private
    private let parent: Select<TSource, TResult>
    private var index = 0
}
