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
            if !isDisposed {
                isDisposed = true
                old = _disposable
                _disposable = nil
            }
        }
        old?.dispose()
    }
    
    private(set) var isDisposed = false
        
    // MARK: internal
    init() {}

    var disposable: IDisposable? {
        get {
            return _disposable
        }
        set {
            var shouldDispose = isDisposed
            var oldValue: IDisposable? = nil
            spinLock.wait {
                if !shouldDispose {
                    oldValue = _disposable
                    _disposable = newValue
                }
            }
            if oldValue != nil {
                fatalError("DISPOSABLE_ALREADY_ASSIGNED")
            }
            if shouldDispose {
                newValue?.dispose()
            }
        }
    }
    
    // MARK: private
    private var _disposable: IDisposable?
    private var spinLock = SpinLock()
}
