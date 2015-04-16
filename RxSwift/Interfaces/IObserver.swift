//
//  IObserver.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/16/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public protocol IObserver: class {
    typealias Input
    func onNext(value: Input)
    func onError(error: NSError)
    func onCompleted()
}
