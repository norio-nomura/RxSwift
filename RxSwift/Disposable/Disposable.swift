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

public protocol ICancelable: IDisposable {
    var isDisposed: Bool {get}
}

public struct Disposable {
    public static func create(action: () -> ()) -> IDisposable {
        return AnonymousDisposable(action)
    }
}