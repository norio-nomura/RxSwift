//
//  Tap.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/17/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

extension Observable {
    public final func tap(next: Output -> ()) -> Observable {
        return _tap(self, next, {_ in}, {})
    }
    
    public final func tap(next: Output -> (), completed: () -> ()) -> Observable {
        return _tap(self, next, {_ in}, completed)
    }
    
    public final func tap(next: Output -> (), error: NSError -> ()) -> Observable {
        return _tap(self, next, error, {})
    }
    
    public final func tap(next: Output -> (), error: NSError -> (), completed: () -> ()) -> Observable {
        return _tap(self, next, error, completed)
    }
    
    public final func tap<TObserver: IObserver where TObserver.Input == Output>(observer: TObserver) -> Observable {
        return _tap(self, observer.onNext, observer.onError, observer.onCompleted)
    }
}

public func tap<TSource>(observable: Observable<TSource>, next: TSource -> ()) -> Observable<TSource> {
    return _tap(observable, next, {_ in}, {})
}

public func tap<TSource>(observable: Observable<TSource>, next: TSource -> (), completed: () -> ()) -> Observable<TSource> {
    return _tap(observable, next, {_ in}, completed)
}

public func tap<TSource>(observable: Observable<TSource>, next: TSource -> (), error: NSError -> ()) -> Observable<TSource> {
    return _tap(observable, next, error, {})
}

public func tap<TSource>(observable: Observable<TSource>, next: TSource -> (), error: NSError -> (), completed: () -> ()) -> Observable<TSource> {
    return _tap(observable, next, error, completed)
}

public func tap<TSource, TObserver: IObserver where TSource == TObserver.Input>(observable: Observable<TSource>, observer: TObserver) -> Observable<TSource> {
    return _tap(observable, observer.onNext, observer.onError, observer.onCompleted)
}

// MARK: private

private func _tap<TSource>(observable: Observable<TSource>, next: TSource -> (), error: NSError -> (), completed: () -> ()) -> Observable<TSource> {
    return Tap(observable, next, error, completed)
}

private final class Tap<TSource>: Producer<TSource> {
    let source: Observable<TSource>
    let _next: TSource -> ()
    let _error: NSError -> ()
    let _completed: () -> ()
    
    init(_ source: Observable<TSource>, _ next: TSource -> (), _ error: NSError -> (), _ completed: () -> ()) {
        self.source = source
        _next = next
        _error = error
        _completed = completed
    }
    
    override func run<TObserver : IObserver where TObserver.Input == Output>(observer: TObserver, cancel: IDisposable?, setSink: IDisposable? -> ()) -> IDisposable? {
        var sink = TapSink(parent: self, observer: observer, cancel: cancel);
        setSink(sink)
        return subscribeSafe(source, sink)
    }
}

private final class TapSink<TSource>: Sink<TSource>, IObserver {
    typealias Input = TSource
    
    let parent: Tap<TSource>
    
    init<TObserver : IObserver where TObserver.Input == TSource>(parent: Tap<TSource>, observer: TObserver, cancel: IDisposable?) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func onNext(value: Input) {
        parent._next(value)
        observer?.onNext(value)
    }
    
    func onError(error: NSError) {
        parent._error(error)
        observer?.onError(error)
        dispose()
    }
    
    func onCompleted() {
        parent._completed()
        observer?.onCompleted()
        dispose()
    }
}
