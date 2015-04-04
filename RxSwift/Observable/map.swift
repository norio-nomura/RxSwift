//
//  map.swift
//  RxSwift
//
//  Created by 野村 憲男 on 4/1/15.
//  Copyright (c) 2015 Norio Nomura. All rights reserved.
//

import Foundation

// MARK: public

/**
Projects each element of an observable sequence into a new form.

:param: observable IObservable
:param: selector   selector A transform function to apply to each source element

:returns: observable An observable sequence whose elements are the result of invoking the transform function on each element of source.
*/
public func map<TSource: IObservable, TResult>(observable: TSource, selector: (TSource.ObserverType.Value) -> TResult) -> Observable<Observer<TResult>> {
    return _map(observable, selector)
}

/**
Projects each element of an observable sequence into a new form by incorporating the element's index.

:param: observable IObservable
:param: selector   selector A transform function to apply to each source element; the second parameter of the function represents the index of the source element.

:returns: observable An observable sequence whose elements are the result of invoking the transform function on each element of source.
*/
public func select<TSource: IObservable, TResult>(observable: TSource, selector: (TSource.ObserverType.Value, Int) -> TResult) -> Observable<Observer<TResult>> {
    return _select(observable, selector)
}


// MARK: internal

internal func _map<TSource: IObservable, TResult>(observable: TSource, selector: (TSource.ObserverType.Value) -> TResult) -> Observable<Observer<TResult>> {
    if let mo = observable as? MapObservable<TSource,TSource.ObserverType> {
        return mo.internalMap(selector)
    } else {
        return MapObservable(observable, selector)
    }
}

internal func _select<TSource: IObservable, TResult>(observable: TSource, selector: (TSource.ObserverType.Value, Int) -> TResult) -> Observable<Observer<TResult>> {
    if let mo = observable as? MapObservable<TSource,TSource.ObserverType> {
        return mo.internalMap(selector)
    } else {
        return MapObservable(observable, selector)
    }
}

// MARK: private
private class MapObservable<TSource: IObservable, TResult: IObserver>: ObservableBase<TResult> {
    typealias SourceValue = TSource.ObserverType.Value
    
    typealias Selector = SourceValue -> Value
    typealias SelectorI = (SourceValue, Int) -> Value
    
    let observable: TSource
    let selector: Selector?
    let selectorI: SelectorI?
    
    init(_ observable: TSource, _ selector: SourceValue -> Value) {
        self.observable = observable
        self.selector = selector
        self.selectorI = nil
        super.init()
    }
    
    init(_ observable: TSource, _ selectorI: (SourceValue, Int) -> Value) {
        self.observable = observable
        self.selector = nil
        self.selectorI = selectorI
        super.init()
    }
    
    override func subscribeCore(observer: TResult) -> IDisposable? {
        if let selector = selector {
            return observable.subscribe(MapObserver(observer, selector) as! TSource.ObserverType)
        } else if let selectorI = selectorI {
            return observable.subscribe(MapObserverI(observer, selectorI) as! TSource.ObserverType)
        } else {
            fatalError("Fatal error \(__FUNCTION__)")
        }
    }
    
    func internalMap<T: IObserver>(selector: Value -> T.Value) -> Observable<T> {
        if let mySelector = self.selector {
            return MapObservable<TSource,T>(self.observable) {
                return selector(mySelector($0))
            }
        } else {
            fatalError("Fatal error \(__FUNCTION__)")
        }
    }
    
    func internalMap<T: IObserver>(selector: (Value, Int) -> T.Value) -> Observable<T> {
        if let mySelector = self.selectorI {
            return MapObservable<TSource,T>(self.observable) {
                return selector(mySelector($0, $1), $1)
            }
        } else {
            fatalError("Fatal error \(__FUNCTION__)")
        }
    }
}

private class MapObserver<TSource, TResult: IObserver>: Observer<TSource> {
    let observer: TResult
    let selector: TSource -> TResult.Value
    
    init(_ observer: TResult, _ selector: TSource -> TResult.Value) {
        self.observer = observer
        self.selector = selector
    }
    
    override func next(value: TSource) {
        observer.onNext(selector(value))
    }
    
    override func error(error: NSError) {
        observer.onError(error)
    }
    
    override func completed() {
        observer.onCompleted()
    }
}

private class MapObserverI<TSource, TResult: IObserver>: Observer<TSource> {
    let observer: TResult
    let selector: (TSource, Int) -> TResult.Value
    var index: Int = 0
    
    init(_ observer: TResult, _ selector: (TSource, Int) -> TResult.Value) {
        self.observer = observer
        self.selector = selector
    }
    
    override func next(value: TSource) {
        observer.onNext(selector(value, index++))
    }
    
    override func error(error: NSError) {
        observer.onError(error)
    }
    
    override func completed() {
        observer.onCompleted()
    }
}
