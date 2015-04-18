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
            if !isDisposed {
                isDisposed = true
                currentDisposables = disposables
                disposables.removeAll(keepCapacity: false)
            }
        }
        if let currentDisposables = currentDisposables {
            for disposable in currentDisposables {
                disposable.dispose()
            }
        }
    }
    
    private(set) var isDisposed = false
    
    // MARK: internal
    init() {
        
    }
    
    init(_ d1: IDisposable, _ d2: IDisposable) {
        spinLock.wait {
            disposables.append(d1)
            disposables.append(d2)
        }
    }
    
    deinit {
        dispose()
    }
    
    func append(disposable: IDisposable) {
        var shouldDispose = false
        spinLock.wait {
            shouldDispose = isDisposed
            if !shouldDispose {
                disposables.append(disposable)
            }
        }
        if shouldDispose {
            disposable.dispose()
        }
    }
    
    func remove(disposable: IDisposable) -> Bool {
        var shouldDispose = false
        spinLock.wait {
            if !isDisposed {
                if let index = find_instance(disposables, disposable) {
                    shouldDispose = true
                    disposables.removeAtIndex(index)
                }
            }
        }
        if shouldDispose {
            disposable.dispose()
        }
        return shouldDispose
    }
    
    // MARK: private
    private var disposables = [IDisposable]()
    private var spinLock = SpinLock()
}
