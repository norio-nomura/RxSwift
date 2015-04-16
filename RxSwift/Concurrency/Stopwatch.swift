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
    Sleep until timeIntervals since creation of Stopwatch
    
    :param: timeInterval to sleep
    */
    func sleep(timeInterval: NSTimeInterval) {
        mach_wait_until(start + timeInterval.absoluteTime);
    }
    
    // MARK: private
    private let start = mach_absolute_time()
    private var elapsed: UInt64 {
        return mach_absolute_time() - start
    }
}
