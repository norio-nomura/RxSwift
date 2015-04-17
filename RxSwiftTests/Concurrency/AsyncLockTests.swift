//
//  AsyncLockTests.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/13/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest

class AsyncLockTests: XCTestCase {
    
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
        AsyncLock().wait { ok = true }
        XCTAssertTrue(ok)
    }
    
    func testQueuesWork() {
        var l = AsyncLock()
        
        var l1 = false
        var l2 = false
        
        l.wait {
            l.wait {
                XCTAssertTrue(l1)
                
                l2 = true
            }
            
            l1 = true
        }
        XCTAssertTrue(l2)
    }
    
    func testDispose() {
        var l = AsyncLock()
        
        var l1 = false
        var l2 = false
        var l3 = false
        var l4 = false
        
        l.wait {
            l.wait {
                l.wait {
                    l3 = true
                }
                
                l2 = true
                
                l.dispose()
                
                l.wait {
                    l4 = true
                }
            }
            
            l1 = true
        }
        
        XCTAssertTrue(l1)
        XCTAssertTrue(l2)
        XCTAssertFalse(l3)
        XCTAssertFalse(l4)
    }
}
