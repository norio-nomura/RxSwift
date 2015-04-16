//
//  AsyncLock.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/13/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class AsyncLockTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        var asyncLock = AsyncLock()
        
        var isAcquired = false
        let block: () -> ()
        block = {
            println()
            var isOwner = false
            asyncLock.wait {
                isOwner = !isAcquired
                isAcquired = true
            }
            if !isOwner {
                return
            }
            block()
        }
        XCTAssert(!isAcquired)
        block()
        XCTAssert(isAcquired)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
