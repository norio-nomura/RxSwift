// Playground - noun: a place where people can play

import RxSwift

let test = {
    return just("test")
        .map {$0 + "1"}
}

let c = test()
let d = map(c) {"\($0)"}
var e = d.subscribe {println("1:" + $0)}
var f = d.subscribe {println("2:" + $0)}

e?.dispose()
e = nil
f = nil


func WriteSequenceToConsole(sequence: Observable<String>)
{
    sequence.subscribe({println($0)})
}

var subject = Subject<String>()
WriteSequenceToConsole(subject)
subject.onNext("1")
subject.onNext("2")
subject.onNext("3")
