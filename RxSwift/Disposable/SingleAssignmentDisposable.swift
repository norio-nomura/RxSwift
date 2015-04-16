//
//  SingleAssignmentDisposable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/14/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal final class SingleAssignmentDisposable: ICancelable {
    // MARK: ICancelable
    func dispose() {
        var old: IDisposable? = nil
        spinLock.wait {
            if !_isDisposed {
                _isDisposed = true
                old = _disposable
                _disposable = nil
            }
        }
        old?.dispose()
    }
    
    var isDisposed: Bool {
        return _isDisposed
    }
    
    // MARK: internal
    init() {}
    
    deinit {
        dispose()
    }
    
    var disposable: IDisposable? {
        get {
            return _disposable
        }
        set {
            var shouldDispose = _isDisposed
            var oldValue: IDisposable? = nil
            spinLock.wait {
                if !shouldDispose {
                    oldValue = _disposable
                    _disposable = newValue
                }
            }
            oldValue?.dispose()
            if shouldDispose {
                newValue?.dispose()
            }
        }
    }
    
    // MARK: private
    private var _isDisposed = false
    private var _disposable: IDisposable?
    private var spinLock = SpinLock()
}
