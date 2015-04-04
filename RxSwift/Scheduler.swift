//
//  Scheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IScheduler: class {
    func schedule(action: () -> ()) -> IDisposable?
}

public struct Scheduler {
    public static var immediate = ImmediateScheduler()
}

public class ImmediateScheduler: IScheduler {
    public func schedule(action: () -> ()) -> IDisposable? {
        action()
        return nil
    }
}
