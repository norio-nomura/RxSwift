//
//  SchedulerTests.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/17/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest

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
        ms.schedule {res = true}
        XCTAssertTrue(res)
    }
    
    func testSchedulerRecursive() {
        let ms = MyScheduler()
        var i = 0;
        ms.schedule {(action: () -> ()) -> () in
            if ++i < 10 {
                action()
            }
        }
        XCTAssertEqual(10, i)
    }
    
    private class MyScheduler: Scheduler {
        var _now: NSDate
        
        init(now: NSDate = NSDate()) {
            _now = now
        }
        
        // MARK: IScheduler
        
        override var now: NSDate {
            return _now
        }
        
        override func schedule<TState>(#state: TState, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
            return action(self, state)
        }
        
        override func schedule<TState>(#state: TState, dueTime: NSTimeInterval, action: (IScheduler, TState) -> IDisposable?) -> IDisposable? {
            check(state, dueTime) { action(self, $0 as! TState) }
            waitCycles += dueTime
            return action(self, state)
        }

        var check: (Any, NSTimeInterval, Any -> ()) -> () = {_,_,_ in}
        var waitCycles: NSTimeInterval = 0
    }
}
