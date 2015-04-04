//
//  Disposable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IDisposable: class {
    func dispose()
}

// MARK: internal
internal class Disposable: IDisposable {
    // MARK: IDisposable
    func dispose() {
        if !isDisposed {
            _dispose()
            isDisposed = true
        }
    }
    
    // MARK internal
    init(_ dispose: () -> ()) {
        self._dispose = dispose
    }
    
    convenience init() {
        self.init({})
    }
    
    deinit {
        dispose()
    }
    
    // MARK: private
    private var isDisposed = false
    private let _dispose: () -> ()
}

internal class SingleAssignmentDisposable: IDisposable {
    // MARK: IDisposable
    func dispose() {
        var old: IDisposable? = nil
        if !isDisposed {
            isDisposed = true
            old = _disposable
            _disposable = nil
        }
        old?.dispose()
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
            var shouldDispose = isDisposed
            var oldValue: IDisposable? = nil
            if !shouldDispose {
                oldValue = _disposable
                _disposable = newValue
            }
            oldValue?.dispose()
            if shouldDispose {
                newValue?.dispose()
            }
        }
    }
    
    // MARK: private
    private var isDisposed = false
    private var _disposable: IDisposable?
}
