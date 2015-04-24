//
//  DefaultDisposable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/23/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public final class DefaultDisposable: IDisposable {
    public static let instance = DefaultDisposable()
    public func dispose() {
    }
    private init() {}
}
