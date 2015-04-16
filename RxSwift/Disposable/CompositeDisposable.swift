//
//  CompositeDisposable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/14/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal final class CompositeDisposable: ICancelable {
    // MARK: ICancelable
    func dispose() {
        var currentDisposables: [IDisposable]? = nil
        spinLock.wait {
            if !_isDisposed {
                _isDisposed = true
                currentDisposables = _disposables
                _disposables.removeAll(keepCapacity: false)
            }
        }
        if let currentDisposables = currentDisposables {
            for disposable in currentDisposables {
                disposable.dispose()
            }
        }
    }
    
    var isDisposed: Bool {
        return _isDisposed
    }
    
    // MARK: internal
    init(_ d1: IDisposable, _ d2: IDisposable) {
        spinLock.wait {
            _disposables.append(d1)
            _disposables.append(d2)
        }
    }
    
    deinit {
        dispose()
    }
    
    func append(disposable: IDisposable) {
        var shouldDispose = false
        spinLock.wait {
            shouldDispose = _isDisposed
            if !shouldDispose {
                _disposables.append(disposable)
            }
        }
        if shouldDispose {
            disposable.dispose()
        }
    }
    
    func remove(disposable: IDisposable) -> Bool {
        var shouldDispose = false
        spinLock.wait {
            if !_isDisposed {
                if let index = find_instance(_disposables, disposable) {
                    shouldDispose = true
                    _disposables.removeAtIndex(index)
                }
            }
        }
        if shouldDispose {
            disposable.dispose()
        }
        return shouldDispose
    }
    
    // MARK: private
    private var _isDisposed = false
    private var _disposables = [IDisposable]()
    private var spinLock = SpinLock()
}
