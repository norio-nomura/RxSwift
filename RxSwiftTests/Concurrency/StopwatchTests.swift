//
//  StopwatchTests.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/17/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest

class StopwatchTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSleep() {
        let stopwatch = Stopwatch()
        stopwatch.sleep(1)
        let elapsed = stopwatch.elapsedSinceCreation
        let diff = abs(elapsed - 1)
        
        XCTAssertLessThan(diff, 0.006, "5msec is a condition that can be passed on my Mac.")
    }

}
