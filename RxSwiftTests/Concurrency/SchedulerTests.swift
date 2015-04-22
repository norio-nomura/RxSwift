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
        
        
        // MARK: scheduleCore
        override func scheduleCore(#state: Any, action: IScheduler -> IDisposable?) -> IDisposable? {
            return action(self)
        }
        
        override func scheduleCore(#state: Any, dueTime: NSTimeInterval, action: IScheduler -> IDisposable?) -> IDisposable? {
            check(state, dueTime) { action(self) }
            waitCycles += dueTime
            return action(self)
        }

        var check: (Any, NSTimeInterval, () -> ()) -> () = {_,_,_ in}
        var waitCycles: NSTimeInterval = 0
    }
}
