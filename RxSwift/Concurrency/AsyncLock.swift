//
//  AsyncLock.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/13/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

final internal class AsyncLock {
    typealias Action = () -> ()
    
    private var isAcquired = false
    private lazy var queue = [Action]()
    private lazy var spinLock = SpinLock()
    
    /**
    perform action
    If wait() is recursively called, adds action to queue for performing later and returns
    
    :param: action block
    */
    func wait(action: () -> ()) {
        var isOwner = false
        spinLock.wait {
            queue.append(action)
            isOwner = !isAcquired
            isAcquired = true
        }
        if !isOwner {
            return
        }
        
        var works = GeneratorOf<Action> {
            return self.spinLock.wait {
                if self.queue.isEmpty {
                    self.isAcquired = false
                    return nil
                } else {
                    return removeAtIndex(&self.queue, 0)
                }
            }
        }
        
        for work in works {
            work()
        }
    }
}
