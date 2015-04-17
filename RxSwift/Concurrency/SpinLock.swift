//
//  Lock.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/13/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal final class SpinLock {
    private var lock = OS_SPINLOCK_INIT
    
    func wait(@noescape action: () -> ()) {
        OSSpinLockLock(&lock)
        action()
        OSSpinLockUnlock(&lock)
    }

    func wait<T>(@noescape action: () -> T) -> T{
        OSSpinLockLock(&lock)
        let result = action()
        OSSpinLockUnlock(&lock)
        return result
    }
}
