//
//  AnonymousObserver.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: internal
public final class AnonymousObserver<T>: ObserverBase<T> {
    public override init(_ next: Value -> (), _ error: NSError -> (), _ completed: () -> ()) {
        super.init(next, error, completed)
    }
    
    public convenience init(_ next: Value -> ()) {
        self.init(next, {_ in}, {})
    }
    
    public convenience init(_ next: Value -> (), _ error: NSError -> ()) {
        self.init(next, error, {})
    }
    
    public convenience init(_ next: Value -> (), _ completed: () -> ()) {
        self.init(next, {_ in}, completed)
    }
}
