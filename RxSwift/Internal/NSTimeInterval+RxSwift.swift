//
//  NSTimeInterval+RxSwift.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/14/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal extension NSTimeInterval {
    var nanosec: Int64 {
        return Int64(self * NSTimeInterval(NSEC_PER_SEC))
    }
    
    var absoluteTime: UInt64 {
        return numericCast(nanosec) * numericCast(timebase_info.denom) / numericCast(timebase_info.numer)
    }
    
    func dispatchTimeFromNow() -> dispatch_time_t {
        return dispatchTimeFrom(DISPATCH_TIME_NOW)
    }
    
    func dispatchTimeFrom(when: dispatch_time_t) -> dispatch_time_t {
        return dispatch_time(when, nanosec)
    }
    
    init(absoluteTime: UInt64) {
        let nanosec = absoluteTime * numericCast(timebase_info.numer) / numericCast(timebase_info.denom)
        self = NSTimeInterval(nanosec) / NSTimeInterval(NSEC_PER_SEC)
    }
}

private var timebase_info = createTimebaseInfo()

private func createTimebaseInfo() -> mach_timebase_info {
    var timebase_info = mach_timebase_info()
    mach_timebase_info(&timebase_info)
    return timebase_info
}
