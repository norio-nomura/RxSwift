//
//  ObserverTests.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/19/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest

class ObserverTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateOnNext() {
        var next = false
        var res = Observer.create { (x: Int) in
            XCTAssertEqual(42, x)
            next = true
        }
        res.onNext(42)
        XCTAssertTrue(next)
        res.onCompleted()
    }
    
    // TODO: Create_OnNext_HasError(). Is alternate of exception needed?
    //    func testCreate_OnNext_HasError() {
    //    }
    
    func testCreate_OnNextOnCompleted() {
        var next = false
        var completed = false
        var res = Observer.create(
            { (x: Int) in
                XCTAssertEqual(42, x)
                next = true
            }, {
                completed = true
            }
        )
        res.onNext(42)
        XCTAssertTrue(next)
        XCTAssertFalse(completed)
        res.onCompleted()
        XCTAssertTrue(completed)
    }
    
    // TODO: Create_OnNextOnCompleted_HasError(). Is alternate of exception needed?
    //    func Create_OnNextOnCompleted_HasError() {
    //    }
    
    func testCreate_OnNextOnError() {
        var ex = NSError(domain: "\(self.dynamicType)", code: 1, userInfo: nil)
        var next = false
        var error = false
        var res = Observer.create(
            { (x: Int) in
                XCTAssertEqual(42, x)
                next = true
            }, { (e: NSError) in
                XCTAssertEqual(ex, e)
                error = true
            }
        )
        res.onNext(42)
        XCTAssertTrue(next)
        XCTAssertFalse(error)
        res.onError(ex)
        XCTAssertTrue(error)
    }
    
    func testCreate_OnNextOnError_HitCompleted() {
        var ex = NSError(domain: "\(self.dynamicType)", code: 1, userInfo: nil)
        var next = false
        var error = false
        var res = Observer.create(
            { (x: Int) in
                XCTAssertEqual(42, x)
                next = true
            }, { (e: NSError) in
                XCTAssertEqual(ex, e)
                error = true
            }
        )
        res.onNext(42)
        XCTAssertTrue(next)
        XCTAssertFalse(error)
        res.onCompleted()
        XCTAssertFalse(error)
    }
    
    func testCreate_OnNextOnErrorOnCompleted1() {
        var ex = NSError(domain: "\(self.dynamicType)", code: 1, userInfo: nil)
        var next = false
        var error = false
        var completed = false
        var res = Observer.create(
            { (x: Int) in
                XCTAssertEqual(42, x)
                next = true
            }, { (e: NSError) in
                XCTAssertEqual(ex, e)
                error = true
            }, {
                completed = true
            }
        )
        res.onNext(42)
        XCTAssertTrue(next)
        XCTAssertFalse(error)
        XCTAssertFalse(completed)
        res.onCompleted()
        XCTAssertTrue(completed)
        XCTAssertFalse(error)
    }

    func testCreate_OnNextOnErrorOnCompleted2() {
        var ex = NSError(domain: "\(self.dynamicType)", code: 1, userInfo: nil)
        var next = false
        var error = false
        var completed = false
        var res = Observer.create(
            { (x: Int) in
                XCTAssertEqual(42, x)
                next = true
            }, { (e: NSError) in
                XCTAssertEqual(ex, e)
                error = true
            }, {
                completed = true
            }
        )
        res.onNext(42)
        XCTAssertTrue(next)
        XCTAssertFalse(error)
        XCTAssertFalse(completed)
        res.onError(ex)
        XCTAssertFalse(completed)
        XCTAssertTrue(error)
    }
    
    func testAsObserver_Hides() {
        var obs = MyObserver<Bool>()
        var res = Observer.asObserver(obs)
        XCTAssertFalse(obs === res)
    }
    
    func testAsObserver_Forwards() {
        var obsn = MyObserver<Int>()
        Observer.asObserver(obsn).onNext(42)
        XCTAssertEqual(obsn.hasOnNext!, 42)
        
        var ex = NSError(domain: "\(self.dynamicType)", code: 1, userInfo: nil)
        var obse = MyObserver<Int>()
        Observer.asObserver(obse).onError(ex)
        XCTAssert(ex === obse.hasOnError)
        
        var obsc = MyObserver<Int>()
        Observer.asObserver(obsc).onCompleted()
        XCTAssertTrue(obsc.hasOnCompleted)
    }
}

private class MyObserver<T> : IObserver {
    typealias Input = T
    
    init() {
    }
    
    func onNext(value: Input)
    {
        hasOnNext = value
    }
    
    func onError(error: NSError)
    {
        hasOnError = error;
    }
    
    func onCompleted()
    {
        hasOnCompleted = true;
    }
    
    var hasOnNext: Input?
    var hasOnError: NSError?
    var hasOnCompleted: Bool = false
}
