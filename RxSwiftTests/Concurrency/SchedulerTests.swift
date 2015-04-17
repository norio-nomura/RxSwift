//
//  SchedulerTests.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/17/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class SchedulerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testScheduleNonRecursive() {
        let ms = MyScheduler()
        var res = false
        schedule(ms) {() in res = true}
        XCTAssertTrue(res)
    }
    
    func testSchedulerRecursive() {
        let ms = MyScheduler()
        var i = 0;
        schedule(ms) {(action: () -> ()) -> () in
            if ++i < 10 {
                action()
            }
        }
        XCTAssertEqual(10, i)
    }
    
    class MyScheduler: IScheduler {
        var now: NSDate
        
        init(now: NSDate = NSDate()) {
            self.now = now
        }
        
        func schedule<TState>(state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
            return action(self, state)
        }
        
        var check: (Any, NSTimeInterval, Any -> ()) -> () = {_,_,_ in}
        var waitCycles: NSTimeInterval = 0
        
        func schedule<TState>(state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
            check(state, dueTime) { action(self, $0 as! TState) }
            waitCycles += dueTime
            return action(self, state)
        }

    }

}
