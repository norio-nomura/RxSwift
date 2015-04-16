//
//  Utils.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/14/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

internal func find_instance<C : CollectionType where C.Generator.Element: AnyObject>(domain: C, instance: C.Generator.Element) -> C.Index? {
    for idx in indices(domain) {
        if domain[idx] === instance {
            return idx
        }
    }
    return nil
}
