//
//  Producer.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/15/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IProducer: IObservable {
    func subscribeRaw<TObserver : IObserver where TObserver.Value == Value>(observer: TObserver) -> IDisposable?
}

public class Producer<T>: Observable<T>, IProducer {
    // MARK: IObservable
    typealias Value = T
    
    public override func subscribe<TObserver: IObserver where TObserver.Value == Value>(observer: TObserver) -> IDisposable? {
        return subscribeRaw(observer)
    }
    
    public func subscribeRaw<TObserver: IObserver where TObserver.Value == Value>(observer: TObserver) -> IDisposable? {
        var state = State(observer)
        
        var d = CompositeDisposable(state.sink, state.subscription)
        
        var sink = SingleAssignmentDisposable()
        var subscription = SingleAssignmentDisposable()
        
        //        Scheduler.immediate.schedule(self) {
        //            (_, me) -> IDisposable? in
        //            subscription.disposable = me.run(observer, cancel: subscription, setSink: {sink.disposable = $0})
        //            return nil
        //        }
        //
        Scheduler.immediate.schedule(state, action: run)
        
        return CompositeDisposable(sink, subscription)
    }
    
    // MARK: internal
    internal func run<TObserver: IObserver where TObserver.Value == Value>(scheduler: IScheduler, x: State<TObserver>) -> IDisposable? {
        x.subscription.disposable = run(x.observer, cancel: x.subscription, setSink: x.assign())
        return nil
    }
    
    internal func run<TObserver: IObserver where TObserver.Value == Value>(observer: TObserver, cancel: IDisposable?, setSink: IDisposable? -> ()) -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
}

internal struct State<TObserver: IObserver> {
    let observer: TObserver
    let sink = SingleAssignmentDisposable()
    let subscription = SingleAssignmentDisposable()
    init(_ observer: TObserver) {
        self.observer = observer
    }
    func assign() -> IDisposable? ->  () {
        return {
            self.sink.disposable = $0
        }
    }
}

