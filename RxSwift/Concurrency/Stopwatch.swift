//
//  Stopwatch.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/13/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal struct Stopwatch {
    /**
    Sleep until timeInterval since creation of Stopwatch
    
    :param: timeInterval to sleep
    */
    func sleep(timeInterval: NSTimeInterval) {
        mach_wait_until(start + timeInterval.absoluteTime);
    }
    
    /**
    timeInterval since creation of Stopwatch
    */
    var elapsedSinceCreation: NSTimeInterval {
        return NSTimeInterval(absoluteTime: elapsedAbsoluteTime)
    }
    
    // MARK: private
    private var start = mach_absolute_time()
    private var elapsedAbsoluteTime: UInt64 {
        return mach_absolute_time() - start
    }
}
