/*:
 [< Previous](@previous)           [Home](Introduction)
 
 ## Transforming and unwrapping dictionary values with compactMapValues()
 
 [SE-0218](https://github.com/apple/swift-evolution/blob/master/proposals/0218-introduce-compact-map-values.md) 새로운 `compactMapValues()` 메소드가 딕셔너리에 추가되었습니다. 배열로부터 `compactMap()` 기능을 가져왔습니다. ("값을 변환하고, 결과를 언랩하고 나서 nil값이 있으면 버린다.") 딕셔너리로부터 `mapValues ​​()` 메소드와 함께 ("키를 그대로두고 값을 변화시킨다").
 
 예를 들어, 다음은 경주에 참여한 사람들의 사전과 함께 몇 초 안에 끝내기까지 걸린 시간입니다. 마무리를 못한 한 사람은 "DNF"로 표시했습니다.
 */
let times = [
    "Hudson": "38",
    "Clarke": "42",
    "Robinson": "35",
    "Hartis": "DNF"
]

/*:
 `compactMapValues()`를 사용하여 DNF 값을 가지는 하나의 사람(Harits)이 제거되고, 나머지 이름과 정수형의 시간을 갖는 새로운 딕셔너리를 생성할 수 있습니다:
 */
let finishers1 = times.compactMapValues { Int($0) }
print("finishers1 = \(finishers1)")
let IntResult = times.compactMap { Int($0.value) }
print("IntResult = \(IntResult)")

/*:
 다른 방법으로, `Int` 생성자를 `compactMapValues​​()`에 직접 넘길 수 있습니다:
 */
let finishers2 = times.compactMapValues(Int.init)
print("finishers2 = \(finishers2)")

/*:
 `compactMapValues​​()`를 사용하여 다음과 같이 옵셔널을 언랩하고, nil 값은 어떤 종류의 변환도 하지 않고 무시되고 버려집니다. 이는 `compactMap()`과 비슷한데 리턴되는 형식에 차이가 있습니다:
 */
let people = [
    "Paul": 38,
    "Sophie": 8,
    "Charlotte": 5,
    "William": nil
]

let knownAges = people.compactMapValues { $0 }
print("knownAges = \(knownAges)")
let knownAges2 = people.compactMap {  $0.value }
print("knownAges2 = \(knownAges2)")

/*:
 [< Previous](@previous)           [Home](Introduction)
 */
