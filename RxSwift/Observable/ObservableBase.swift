//
//  ObservableBase.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/2/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: internal
internal class ObservableBase<T: IObserver>: Observable<T> {
    init() {
        super.init({
            var ado = AutoDetachObserver($1)
            ado.disposable = ($0 as! ObservableBase).subscribeCore($1)
            return ado
        })
    }
    
    func subscribeCore(observer: T) -> IDisposable? {
        fatalError("subclass need override \(__FUNCTION__)")
    }
}
