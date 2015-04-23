//
//  BooleanDisposable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/23/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public final class BooleanDisposable: ICancelable {
    // MARK: ICancelable
    public func dispose() {
        OSAtomicCompareAndSwap32Barrier(0, 1, &_isDisposed)
    }
    
    public var isDisposed: Bool {
        return OSAtomicCompareAndSwap32Barrier(1, 1, &_isDisposed)
    }
    
    // MARK: internal
    public init() {}
    
    public init(isDisposed: Bool) {
        _isDisposed = isDisposed ? 1 : 0
    }
    
    // MARK: private
    private var _isDisposed: Int32 = 0
}
