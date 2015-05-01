//
//  ToObservable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 5/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: public

public extension Observable {
    public static func from<U: SequenceType where U.Generator.Element == T>(source: U) -> Observable<U.Generator.Element> {
        return _toObservable(source)
    }

    public static func from<U: SequenceType where U.Generator.Element == T>(source: U, scheduler: IScheduler) -> Observable<U.Generator.Element> {
        return _toObservable(source, scheduler: scheduler)
    }
}

// MARK: private

private func _toObservable<T: SequenceType>(source: T, scheduler: IScheduler = SchedulerDefaults.iteration) -> Observable<T.Generator.Element> {
    return ToObservable(source, scheduler: scheduler)
}

private final class ToObservable<TResult>: Producer<TResult> {
    let sequence: SequenceOf<TResult>
    let scheduler: IScheduler

    init<T: SequenceType where T.Generator.Element == TResult>(_ source: T, scheduler: IScheduler) {
        self.sequence = SequenceOf(source)
        self.scheduler = scheduler
    }
    
    override func run<TObserver : IObserver where TObserver.Input == Output>(observer: TObserver, cancel: IDisposable?, setSink: IDisposable? -> ()) -> IDisposable? {
        var sink = ToObservableSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

private final class ToObservableSink<TResult>: Sink<TResult> {
    let parent: ToObservable<TResult>
    
    init<TObserver : IObserver where TObserver.Input == TResult>(parent: ToObservable<TResult>, observer: TObserver, cancel: IDisposable?) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> IDisposable? {
        let generator = GeneratorOf(parent.sequence.generate())
        if let longRunning = parent.scheduler as? ISchedulerLongRunning {
            return longRunning.scheduleLongRunning(state: generator, action: loop)
        } else {
            let flag = BooleanDisposable()
            (parent.scheduler as! Scheduler).schedule(state: State(flag, generator), action: loopRec)
            return flag
        }
    }
    
    func loop(var generator: GeneratorOf<TResult>, cancel: ICancelable) {
        while !cancel.isDisposed,
            let next = generator.next() {
                super.observer?.onNext(next)
        }
        if !cancel.isDisposed {
            super.observer?.onCompleted()
        }
        super.dispose()
    }
    
    func loopRec(var state: State<TResult>, recurse: State<TResult> -> ()) {
        if state.flag.isDisposed {
            return
        }
        if let next = state.generator.next() {
            super.observer?.onNext(next)
            recurse(state)
        } else {
            super.observer?.onCompleted()
            super.dispose()
        }
    }

}

private final class State<TResult> {
    let flag: ICancelable
    var generator: GeneratorOf<TResult>
    init(_ flag: ICancelable, _ generator: GeneratorOf<TResult>) {
        self.flag = flag
        self.generator = generator
    }
}
