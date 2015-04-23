//
//  Range.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/23/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

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
        return parent.scheduler.schedule(action: invoke)
    }

}
