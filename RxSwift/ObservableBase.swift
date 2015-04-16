//
//  ObservableBase.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/2/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: internal
internal class ObservableBase<T>: Observable<T> {
    override func subscribe<TObserver: IObserver where TObserver.Input == Output>(observer: TObserver) -> IDisposable? {
        var ado = AutoDetachObserver(observer)
        Scheduler.immediate.schedule(ado, action: scheduledSubscribe)
        return ado
    }
    
    func subscribeCore<TObserver: IObserver where TObserver.Input == Output>(observer: TObserver) -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    // MARK: private
    private func scheduledSubscribe(scheduler: IScheduler, autoDetachObserver: AutoDetachObserver<Output>) -> IDisposable? {
        autoDetachObserver.disposable = subscribeCore(autoDetachObserver)
        return nil
    }
}
