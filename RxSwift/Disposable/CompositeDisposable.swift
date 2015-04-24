//
//  CompositeDisposable.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/14/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

public final class CompositeDisposable: ICancelable {
    // MARK: ICancelable
    public func dispose() {
        var currentDisposables: Set<DisposableOf>? = nil
        spinLock.wait {
            if !isDisposed {
                isDisposed = true
                currentDisposables = disposables
                disposables.removeAll(keepCapacity: false)
            }
        }
        if let currentDisposables = currentDisposables {
            for disposable in currentDisposables {
                disposable.dispose()
            }
        }
    }
    
    public private(set) var isDisposed = false
    
    // MARK: internal
    public init() {
    }
    
    public init(_ disposables: IDisposable...) {
        // spinlock is not needed in init() because another referrer does not exist
        self.disposables.unionInPlace(map(disposables) {DisposableOf($0)} )
    }
    
    // MARK: Subset of ExtensibleCollectionType
    
    /// Append `x` to `self`.
    ///
    /// Applying `successor()` to the index of the new element yields
    /// `self.endIndex`.
    ///
    /// Complexity: amortized O(1).
    public func append(x: IDisposable) {
        var shouldDispose = false
        spinLock.wait {
            shouldDispose = isDisposed
            if !shouldDispose {
                disposables.insert(DisposableOf(x))
            }
        }
        if shouldDispose {
            x.dispose()
        }
    }
    
    /// Append the elements of `newElements` to `self`.
    ///
    /// Complexity: O(*length of result*)
    ///
    /// A possible implementation::
    ///
    ///   reserveCapacity(count(self) + underestimateCount(newElements))
    ///   for x in newElements {
    ///     self.append(x)
    ///   }
    public func extend<S : SequenceType where S.Generator.Element == IDisposable>(newElements: S) {
        var shouldDispose = false
        spinLock.wait {
            shouldDispose = isDisposed
            if !shouldDispose {
                disposables.unionInPlace(map(newElements) {DisposableOf($0)})
            }
        }
        if shouldDispose {
            for x in newElements {
                x.dispose()
            }
        }
    }

    // MARK: Subset of Set
    
    /// Returns `true` if the set contains a member.
    public func contains(disposable: IDisposable) -> Bool {
        return spinLock.wait {
            return disposables.contains(DisposableOf(disposable))
        }
    }
    
    /// Remove the member from the set and return it if it was present.
    public func remove(disposable: IDisposable) -> IDisposable? {
        var shouldDispose = false
        spinLock.wait {
            if !isDisposed {
                if let removed = disposables.remove(DisposableOf(disposable)) {
                    shouldDispose = true
                }
            }
        }
        if shouldDispose {
            disposable.dispose()
        }
        return shouldDispose ? disposable : nil
    }
    
    /// Erase all the elements.  If `keepCapacity` is `true`, `capacity`
    /// will not decrease.
    public func removeAll(keepCapacity: Bool = false) {
        var removed: Set<DisposableOf>? = nil
        spinLock.wait {
            if !isDisposed {
                removed = disposables
                disposables.removeAll(keepCapacity: keepCapacity)
            }
        }
        if let removed = removed {
            for x in removed {
                x.dispose()
            }
        }
    }
    
    /// The number of members in the set.
    ///
    /// Complexity: O(1)
    var count: Int {
        return spinLock.wait {
            return disposables.count
        }
    }

    // MARK: private
    private var disposables = Set<DisposableOf>()
    private var spinLock = SpinLock()
}

extension CompositeDisposable: CollectionType {
    // MARK: CollectionType
    public subscript (position: Index) -> Generator.Element {
        return disposables[position]
    }
    
    public typealias Index = Set<DisposableOf>.Index
    
    /// The position of the first element in a non-empty set.
    ///
    /// This is identical to `endIndex` in an empty set.
    ///
    /// Complexity: amortized O(1) if `self` does not wrap a bridged
    /// `NSSet`, O(N) otherwise.
    public var startIndex: Index {
        return disposables.startIndex
    }
    
    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    ///
    /// Complexity: amortized O(1) if `self` does not wrap a bridged
    /// `NSSet`, O(N) otherwise.
    public var endIndex: Index {
        return disposables.endIndex
    }
    
    // MARK: SequenceType
    public typealias Generator = Set<DisposableOf>.Generator
    
    /// Return a *generator* over the members.
    ///
    /// Complexity: O(1)
    public func generate() -> Generator {
        return disposables.generate()
    }
}

// MARK: private
public final class DisposableOf: IDisposable, Hashable {
    let disposable: IDisposable
    init(_ disposable: IDisposable) {
        if let disposableOf = disposable as? DisposableOf {
            self.disposable = disposableOf.disposable
        } else {
            self.disposable = disposable
        }
    }
    
    // MARK: IDisposable
    public func dispose() {
        disposable.dispose()
    }
    
    // MARK: Hashable
    public var hashValue: Int {
        return ObjectIdentifier(disposable).hashValue
    }
}

public func == (lhs: DisposableOf, rhs: DisposableOf) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public func == (var lhs: IDisposable, var rhs: IDisposable) -> Bool {
    return DisposableOf(lhs) == DisposableOf(rhs)
}

public func === (var lhs: IDisposable, var rhs: IDisposable) -> Bool {
    return DisposableOf(lhs) == DisposableOf(rhs)
}
