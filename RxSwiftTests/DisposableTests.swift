//
//  DisposableTests.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/23/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest

class DisposableTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAnonymousDisposable_Dispose() {
        var disposed = false
        let d = Disposable.create { disposed = true }
        XCTAssertFalse(disposed)
        d.dispose()
        XCTAssertTrue(disposed)
        
        let c = d as? ICancelable
        XCTAssertNotNil(c)
        XCTAssertTrue(c!.isDisposed)
    }

    func testBooleanDisposable() {
        let d = BooleanDisposable()
        XCTAssertFalse(d.isDisposed)
        d.dispose()
        XCTAssertTrue(d.isDisposed)
        d.dispose()
        XCTAssertTrue(d.isDisposed)
    }
    
    func testSingleAssignmentDisposable_SetNil() {
        let d = SingleAssignmentDisposable()
        d.disposable = nil
    }
    
    func testSingleAssignmentDisposable_DisposeAfterSet() {
        var disposed = false
        
        let d = SingleAssignmentDisposable()
        let dd = Disposable.create { disposed = true }
        d.disposable = dd
        
        // Protocol can not conform to Equatable by itself.
        XCTAssertTrue(dd === d.disposable!)
        XCTAssertFalse(disposed)
        d.dispose()
        XCTAssertTrue(disposed)
        d.dispose()
        XCTAssertTrue(disposed)
        XCTAssertTrue(d.isDisposed)
    }
    
    func testSingleAssignmentDisposable_DisposeBeforeSet() {
        var disposed = false
        
        let d = SingleAssignmentDisposable()
        let dd = Disposable.create { disposed = true }
        
        XCTAssertFalse(disposed)
        d.dispose()
        XCTAssertFalse(disposed)
        XCTAssertTrue(d.isDisposed)
        
        d.disposable = dd
        XCTAssertTrue(disposed)
        XCTAssertNil(d.disposable)
        d.disposable?.dispose()        // This should be a nop.
        
        d.dispose()
        XCTAssertTrue(disposed)
    }
    
    // fatalError() occurs on current implementation
//    func testSingleAssignmentDisposable_SetMultipleTimes() {
//        var d = SingleAssignmentDisposable()
//        d.disposable = Disposable.empty
//        
//        d.disposable = Disposable.empty
//
//    }

    func testCompositeDisposable_Contains() {
        let d1 = Disposable.create {}
        let d2 = Disposable.create {}
        
        let g = CompositeDisposable(d1, d2)
        XCTAssertEqual(2, g.count)
        XCTAssertTrue(g.contains(d1))
        XCTAssertTrue(g.contains(d2))
    }
    
    func testCompositeDisposable_GetEnumerator() {
        let d1 = Disposable.create {}
        let d2 = Disposable.create {}
        let g = CompositeDisposable(d1, d2)
        var lst = [IDisposable]()
        for x in g {
            lst.append(x)
        }
        XCTAssertEqual(count(lst), 2)
        // Protocol can not conform to Equatable by itself.
        XCTAssertTrue(g.contains(lst[0]))
        XCTAssertTrue(g.contains(lst[1]))
    }
    
    func testCompositeDisposable_Add() {
        let d1 = Disposable.create {}
        let d2 = Disposable.create {}
        let g = CompositeDisposable(d1)
        XCTAssertEqual(1, g.count)
        XCTAssertTrue(g.contains(d1))
        g.append(d2)
        XCTAssertEqual(2, g.count)
        XCTAssertTrue(g.contains(d2))
    }
    
    func testCompositeDisposable_AddAfterDispose()
    {
        var disp1 = false
        var disp2 = false
        
        let d1 = Disposable.create { disp1 = true }
        let d2 = Disposable.create { disp2 = true }
        let g = CompositeDisposable(d1)
        XCTAssertEqual(1, g.count)
        
        g.dispose()
        XCTAssertTrue(disp1)
        XCTAssertEqual(0, g.count) // CHECK
        
        g.append(d2)
        XCTAssertTrue(disp2)
        XCTAssertEqual(0, g.count) // CHECK
        
        XCTAssertTrue(g.isDisposed)
    }

    func testCompositeDisposable_Remove()
    {
        var disp1 = false
        var disp2 = false
        
        let d1 = Disposable.create { disp1 = true }
        let d2 = Disposable.create { disp2 = true }
        let g = CompositeDisposable(d1, d2)
        
        XCTAssertEqual(2, g.count)
        XCTAssertTrue(g.contains(d1))
        XCTAssertTrue(g.contains(d2))
        
        XCTAssertNotNil(g.remove(d1))
        XCTAssertEqual(1, g.count)
        XCTAssertFalse(g.contains(d1))
        XCTAssertTrue(g.contains(d2))
        XCTAssertTrue(disp1)
        
        XCTAssertNotNil(g.remove(d2))
        XCTAssertFalse(g.contains(d1))
        XCTAssertFalse(g.contains(d2))
        XCTAssertTrue(disp2)
        
        var disp3 = false
        let d3 = Disposable.create { disp3 = true }
        XCTAssertNil(g.remove(d3))
        XCTAssertFalse(disp3)
    }
    
    func testCompositeDisposable_Clear()
    {
        var disp1 = false
        var disp2 = false
        
        var d1 = Disposable.create { disp1 = true }
        var d2 = Disposable.create { disp2 = true }
        var g = CompositeDisposable(d1, d2)
        XCTAssertEqual(2, g.count)
        
        g.removeAll()
        XCTAssertTrue(disp1)
        XCTAssertTrue(disp2)
        XCTAssertEqual(0, g.count)
        
        var disp3 = false
        var d3 = Disposable.create { disp3 = true }
        g.append(d3)
        XCTAssertFalse(disp3)
        XCTAssertEqual(1, g.count)
    }
}
