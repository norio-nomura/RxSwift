//
//  SchedulerDefaults.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/25/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal final class SchedulerDefaults {
    static let constantTimeOperations = ImmediateScheduler.instance
    static let tailRecursion = ImmediateScheduler.instance
    static let iteration = ImmediateScheduler.instance // TODO: CurrentThreadScheduler.instance
    static let timeBasedOperations = ImmediateScheduler.instance // TODO: DefaultScheduler.instance
    static let asyncConversions = ImmediateScheduler.instance // TODO: DefaultScheduler.instance
}