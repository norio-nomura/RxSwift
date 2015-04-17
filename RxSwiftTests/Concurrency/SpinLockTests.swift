//
//  SpinLockTests.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/17/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest

class SpinLockTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testWait() {
        var ok = false
        SpinLock().wait { ok = true }
        XCTAssertTrue(ok)
    }
    
    func testWaitReturnsValue() {
        let ok = SpinLock().wait {true}
        XCTAssertTrue(ok)
    }
    
    func testMultithread() {
        let expect = expectationWithDescription(nil)
        
        let l = SpinLock()
        let s = Stopwatch()
        
        var b = false
        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        dispatch_async(queue) {
            l.wait {                // 1
                XCTAssertFalse(b)   // 2
                s.sleep(1)          // 3
                XCTAssertFalse(b)   // 6
                b = true            // 7
            }
        }
        dispatch_async(queue) {
            XCTAssertFalse(b)       // 4
            l.wait {                // 5
                XCTAssertTrue(b)    // 8
                b = false           // 9
            }
            expect.fulfill()        // 10
        }
        
        waitForExpectationsWithTimeout(2) {_ in
            XCTAssertFalse(b)       // 11
        }
    }
}
