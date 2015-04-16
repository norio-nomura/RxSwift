//
//  IObservable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/16/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IObservable: class {
    typealias Output
    func subscribe<TObserver: IObserver where TObserver.Input == Output>(observer: TObserver) -> IDisposable?
}
