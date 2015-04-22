//
//  VirtualTimeSchedulerTests.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/20/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest

class VirtualTimeSchedulerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private typealias VirtualSchedulerTestScheduler = VirtualTimeScheduler<String, UnicodeScalar, VirtualTimeTestConverter>
    
    private class VirtualTimeTestConverter: VirtualTimeConverter {
        typealias AbsoluteTime = String
        typealias RelativeTime = UnicodeScalar
        
        static func add(absolute: AbsoluteTime, relative: RelativeTime) -> AbsoluteTime {
            var result = absolute
            result.append(relative)
            return result
        }
        
        static func toDate(absolute: AbsoluteTime) -> NSDate {
            if absolute.isEmpty {
                return NSDate()
            } else {
                return NSDate(timeIntervalSinceReferenceDate: NSTimeInterval(count(absolute)))
            }
        }
        
        static func toRelative(timeInterval: NSTimeInterval) -> RelativeTime {
            return RelativeTime(UInt32(timeInterval) % numericCast(CHAR_MAX))
        }
    }

    func testVirtual_Now() {
        let res = VirtualSchedulerTestScheduler("").now.timeIntervalSinceNow
        XCTAssert(res < 0.1)
    }
    
    func testVirtual_ScheduleAction() {
        var ran = false
        var scheduler = VirtualSchedulerTestScheduler("")
        scheduler.schedule {
            ran = true
        }
        scheduler.start()
        XCTAssertTrue(ran)

    }
    
    func testVirtual_InitialAndComparer_Now() {
        var s = VirtualSchedulerTestScheduler("Bar").now.timeIntervalSinceReferenceDate
        XCTAssertEqual(3, s);

    }
    
}

