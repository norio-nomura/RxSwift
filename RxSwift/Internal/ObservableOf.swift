//
//  ObservableOf.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/16/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

//internal final class ObservableOf<T>: IObservable {
//    typealias Value = T
//    
////    init<TObserver: IObserver where TObserver.Value == Value>(_ subscribe: TObserver -> IDisposable?) {
////        _subscribe = subscribe as! AnyObject -> IDisposable?
////    }
//    
//    init<TObservable: IObservable where TObservable.Value == Value>(_ observable: TObservable) {
//        _subscribe = observable.subscribe
//    }
//    
//    func subscribe<TObserver : IObserver where TObserver.Value == Value>(observer: TObserver) -> IDisposable? {
//        return _subscribe(observer)
//    }
//    
//    // MARK: private
//    private let _subscribe: AnyObject -> IDisposable?
//}
