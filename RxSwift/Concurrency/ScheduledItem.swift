//
//  ScheduledItem.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/20/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IScheduledItem: class {
    typealias AbsoluteTime
    var dueTime: AbsoluteTime {get}
    func invoke()
}

public class ScheduledItemBase<TAbsolute: Comparable>: IScheduledItem {
    // MARK: IScheduledItem
    typealias AbsoluteTime = TAbsolute
    
    public let dueTime: AbsoluteTime
    
    public func invoke() {
        if !_disposable.isDisposed {
            _disposable.disposable = invokeCore()
        }
    }
    
    // MARK: public
    public func cancel() {
        _disposable.dispose()
    }
    
    public var isCanceled: Bool {
        return _disposable.isDisposed
    }
    
    // MARK: internal
    init(dueTime: AbsoluteTime) {
        self.dueTime = dueTime
    }
    
    func invokeCore() -> IDisposable? {
        fatalError("Abstract method \(__FUNCTION__)")
    }
    
    // MARK: private
    let _disposable = SingleAssignmentDisposable()
}

public class ScheduledItem<TAbsolute: Comparable, TValue>: ScheduledItemBase<TAbsolute> {
    public init(scheduler: IScheduler, state: TValue, action: (IScheduler, TValue) -> IDisposable?, dueTime: TAbsolute) {
        self.scheduler = scheduler
        self.state = state
        self.action = action
        super.init(dueTime: dueTime)
    }
    
    // MARK: internal
    override func invokeCore() -> IDisposable? {
        return action(scheduler, state)
    }
    
    // MARK: private
    private let scheduler: IScheduler
    private let state: TValue
    private let action: (IScheduler, TValue) -> IDisposable?
}
