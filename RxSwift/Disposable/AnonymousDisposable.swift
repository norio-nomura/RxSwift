//
//  AnonymousDisposable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/14/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal final class AnonymousDisposable: ICancelable {
    // MARK: ICancelable
    func dispose() {
        var old: (() -> ())? = nil
        spinLock.wait {
            if !_isDisposed {
                _isDisposed = true
                old = _dispose
                _dispose = nil
            }
        }
        old?()
    }
    
    var isDisposed: Bool {
        return _isDisposed
    }
    
    // MARK internal
    init(_ dispose: () -> ()) {
        self._dispose = dispose
    }
    
    deinit {
        dispose()
    }
    
    // MARK: private
    private var _isDisposed = false
    private var _dispose: (() -> ())?
    private var spinLock = SpinLock()
}
