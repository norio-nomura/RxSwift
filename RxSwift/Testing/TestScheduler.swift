//
//  TestScheduler.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/22/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public typealias TestScheduler = TestSchedulerBase<UInt64, UInt64, TestSchedulerTimeConverter>

public class TestSchedulerBase<TAbsolute: protocol<Comparable, UnsignedIntegerType>, TRelative: UnsignedIntegerType, Converter: VirtualTimeConverter where Converter.AbsoluteTime == TAbsolute, Converter.RelativeTime == TRelative>: VirtualTimeScheduler<TAbsolute, TRelative, Converter> {
    public init() {
        super.init(0)
    }
    
    public override func scheduleAbsolute<TState>(#state: TState, var dueTime: TAbsolute, action: IScheduler -> IDisposable?) -> IDisposable? {
        if dueTime < clock {
            dueTime = clock + 1
        }
        return super.scheduleAbsolute(state: state, dueTime: dueTime, action: action)
    }
}

public class TestSchedulerTimeConverter: VirtualTimeConverter {
    public typealias AbsoluteTime = UInt64
    public typealias RelativeTime = UInt64
    
    public static func add(absolute: AbsoluteTime, relative: RelativeTime) -> AbsoluteTime {
        return absolute + relative
    }
    
    public static func toDate(absolute: AbsoluteTime) -> NSDate {
        return NSDate(timeIntervalSinceReferenceDate: NSTimeInterval(absolute) / NSTimeInterval(NSEC_PER_SEC))
    }
    
    public static func toRelative(timeInterval: NSTimeInterval) -> RelativeTime {
        return RelativeTime(timeInterval * NSTimeInterval(NSEC_PER_SEC))
    }
}
