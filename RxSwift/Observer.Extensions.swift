//
//  Observer.Extensions.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/19/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public struct Observer {
    public static func create<T>(next: T -> ()) -> ObserverBase<T> {
        return AnonymousObserver(next)
    }

    public static func create<T>(next: T -> (), _ error: NSError -> ()) -> ObserverBase<T> {
        return AnonymousObserver(next, error)
    }
    
    public static func create<T>(next: T -> (), _ completed: () -> ()) -> ObserverBase<T> {
        return AnonymousObserver(next, completed)
    }
    
    public static func create<T>(next: T -> (), _ error: NSError -> (), _ completed: () -> ()) -> ObserverBase<T> {
        return AnonymousObserver(next, error, completed)
    }
    
    public static func asObserver<T: IObserver>(observer: T) -> ObserverBase<T.Input> {
        return AnonymousObserver(observer)
    }
}
