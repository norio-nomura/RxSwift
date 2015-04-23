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
        
        let d = SingleAssignmentDisposable();
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
    
    func testSingleAssignmentDisposable_SetMultipleTimes() {
        var d = SingleAssignmentDisposable()
        d.disposable = Disposable.empty
        
        d.disposable = Disposable.empty

    }

}
