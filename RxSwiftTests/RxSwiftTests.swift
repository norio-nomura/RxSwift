//
//  RxSwiftTests.swift
//  RxSwiftTests
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class RxSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let a = Observable<String>.just("test")
        let b = map(a) {
            $0 + "1"
        }
        let c = map(b) {[$0]}
        let d = c.subscribe {
            println($0)
        }
    }
    
    func testMap() {
        func WriteSequenceToConsole(sequence: Observable<String>) {
            sequence.subscribe({println($0)})
        }
        
        var subject = Subject<String>()
        WriteSequenceToConsole(subject)
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
        
    }
}
