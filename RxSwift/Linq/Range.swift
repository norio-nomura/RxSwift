//
//  Range.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/23/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: public

public extension Observable {
    /**
    Generates an observable sequence of integral numbers within a specified range, using the specified scheduler to send out observer messages.
    
    :param: start The value of the first integer in the sequence.
    :param: count The number of sequential integers to generate.
    
    :returns: An observable sequence that contains a range of sequential integral numbers.
    */
    public static func range<T: IntegerType>(start: T, _ count: T) -> Observable<T> {
        return _range(start, count)
    }
    
    /**
    Generates an observable sequence of integral numbers within a specified range, using the specified scheduler to send out observer messages.
    
    :param: start     The value of the first integer in the sequence.
    :param: count     The number of sequential integers to generate.
    :param: scheduler Scheduler to run the generator loop on. If not specified, defaults to Scheduler.currentThread.
    
    :returns: An observable sequence that contains a range of sequential integral numbers.
    */
    public static func range<T: IntegerType>(start: T, _ count: T, scheduler: IScheduler) -> Observable<T> {
        return _range(start, count, scheduler: scheduler)
    }
}

// MARK: private

private func _range<T: IntegerType>(start: T, count: T, scheduler: IScheduler = SchedulerDefaults.iteration) -> Observable<T> {
    return Range(start, count, scheduler: scheduler)
}

private final class Range<TResult: IntegerType>: Producer<TResult> {
    var start: TResult
    var count: TResult
    let scheduler: IScheduler
    
    init(_ start: TResult, _ count: TResult, scheduler: IScheduler) {
        self.start = start
        self.count = count
        self.scheduler = scheduler
    }
    
    override func run<TObserver : IObserver where TObserver.Input == Output>(observer: TObserver, cancel: IDisposable?, setSink: IDisposable? -> ()) -> IDisposable? {
        var sink = RangeSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

private final class RangeSink<TResult: IntegerType>: Sink<TResult> {
    let parent: Range<TResult>
    
    init<TObserver : IObserver where TObserver.Input == TResult>(parent: Range<TResult>, observer: TObserver, cancel: IDisposable?) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> IDisposable? {
        if let longRunning = parent.scheduler as? ISchedulerLongRunning {
            return longRunning.scheduleLongRunning(state: 0, action: loop)
        } else {
            return (parent.scheduler as! Scheduler).schedule(state: 0, action: loopRec)
        }
    }
    
    func loop(var i: TResult, cancel: ICancelable) {
        while !cancel.isDisposed && i < parent.count {
            super.observer?.onNext(parent.start + i)
            i = i.successor()
        }
        if !cancel.isDisposed {
            super.observer?.onCompleted()
        }
        super.dispose()
    }
    
    func loopRec(i: TResult, recurse: TResult -> ()) {
        if i < parent.count {
            super.observer?.onNext(parent.start + i)
            recurse(i + 1)
        } else {
            super.observer?.onCompleted()
            super.dispose()
        }
    }

}
