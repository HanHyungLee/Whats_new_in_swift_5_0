/*:
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 
 ## Dynamically callable types
 
 [SE-0216](https://github.com/apple/swift-evolution/blob/master/proposals/0216-dynamic-callable.md) Swift에 새로운 @dynamicCallable 속성을 추가합니다. 이 속성을 사용하면 형식을 직접 호출할 수 있는 것으로 표시할 수 있습니다. 그것은 임의의 종류의 컴파일러 마법이 아니라 문법적 설탕(*[syntactic sugar](https://en.wikipedia.org/wiki/Syntactic_sugar)*)입니다. `random.dynamicallyCall(withKeywordArguments: ["numberOfZeroes": 3])`에 `random(numberOfZeroes: 3)`을 효과적으로 사용합니다.
 
 `@dynamicCallable`은 Swift 4.2의 `@dynamicMemberLookup`의 자연스러운 확장이고, 같은 목적을 가지고 있습니다: Swift 코드가 파이썬이나 자바스크립트 같은 동적 언어와 함께 쉽게 작업할 수 있게 해줍니다.
 
 자신의 타입에 이 기능을 추가하기 위해서는, `@dynamicCallable` 속성에 `funcdynamicCall(withArguments args: [Int]) -> Double` 그리고/또는 `func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Double` 추가합니다.
 
 첫 번째 매개 변수는 매개 변수 레이블 (예: `a(b, c)`)없이 형식을 호출할 때 사용되고, 두 번째 매개 변수는 레이블을 제공할 때 사용됩니다. (예: `a(b: cat, c: dog)`).
 
 `@dynamicCallable`은 Swift의 형식 안전성을 최대한 활용하면서 고급 메소드를 위한 여유 공간을 유지하면서 메소드가 받아들일 수 있는 데이터 형식에 대해 매우 유연합니다. 따라서 첫 번째 메소드(매개 변수 레이블 없음)에서는 배열, 배열 조각과 셋(set)과 같은 'ExpressibleByArrayLiteral`을 따르는 모든 것을 사용할 수 있으며, 두 번째 메소드(매개 변수 레이블 사용)에는 딕셔너리와 키, 값 쌍이 같은 'ExpressibleByDictionaryLiteral'을 준수하는 모든 것을 사용할 수 있습니다.
 
 다양한 입력을 허용하는 것은 물론, 다양한 출력에 대해 여러 오버로드를 제공할 수도 있습니다 - 한 개 문자열 하나, 한 개 정수 등등을 반환할 수 있습니다. 스위프트가 어떤 것을 사용하는지 해결할 수 있는 한, 원하는 모든 것을 조화롭게 결합할 수 있습니다.
 
 예제를 보겠습니다. 다음은 전달된 입력에 따라 0과 최대 사이의 숫자를 생성하는 구조체입니다.
 */
import Foundation

@dynamicCallable
struct RandomNumberGenerator1 {
    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Double {
        let numberOfZeroes = Double(args.first?.value ?? 0)
        let maximum = pow(10, numberOfZeroes)
        return Double.random(in: 0...maximum)
    }
}
/*:
 이 메소드는 여러 개의 매개 변수 또는 0으로 호출 할 수 있으므로 첫 번째 값을 주의 깊게 읽고, nil coalescing을 사용하여 적절한 기본값이 있는지 확인합니다.
 
 이제 우리는 `RandomNumberGenerator1`의 인스턴스를 생성하고 그것을 함수처럼 호출할 수 있습니다:
 */
let random1 = RandomNumberGenerator1()
let result1 = random1(numberOfZeroes: 0)
/*:
 대신에 `dynamicallyCall(withArguments:)`을 사용했다면 - 또는 동시에 하나의 타입을 가질 수 있기 때문에 - 다음과 같이 작성할 수 있습니다:
 */
@dynamicCallable
struct RandomNumberGenerator2 {
    func dynamicallyCall(withArguments args: [Int]) -> Double {
        let numberOfZeroes = Double(args[0])
        let maximum = pow(10, numberOfZeroes)
        return Double.random(in: 0...maximum)
    }
}

let random2 = RandomNumberGenerator2()
let result2 = random2(0)

/*:
 `@dynamicCallable`을 사용할 때 주의해야 할 몇 가지 중요한 규칙이 있습니다:
 
 - 구조체, 열거형, 클래스와 프로토콜에 적용할 수 있습니다.
   - `withKeywordArguments:`를 구현하고 `withArguments:`를 구현하지 않으면, 매개 변수 레이블 없이 형식을 호출할 수 있습니다 - 단지 키의 빈 문자열만 얻습니다.
   - `withKeywordArguments:`또는 `withArguments:`의 구현이 throwing으로 표시되면, 그 형식을 던져서 호출될 것입니다.
   -`@dynamicCallable`을 익스텐션에 추가할 수 없고, 타입의 기본 정의만 추가할 수 있습니다.
   - 여전히 ​​당신의 형식에 다른 메소드들과 프로퍼티들을 추가할 수 있고 그것들을 평소와 같이 사용할 수 있습니다.
 
 아마도 더 중요한 것은 메서드 확인을 지원하지 않는다는 것입니다. 즉, 메서드에서 특정 메서드를 호출하는 대신 (예: `random.generate(numberOfZeroes: 5)`) 직접 형식을 호출해야합니다 (예: `random(numberOfZeroes: 5)`). `func dynamicallyCallMethod(named: String, withKeywordArguments: KeyValuePairs<String, Int>)`와 같은 메소드 시그너처를 사용하여 후자를 추가하는 것에 대한 논의가 이미있다.
 
 그것이 미래 Swift 버전에서 가능해지면 테스트 모형 제작을 위한 매우 흥미로운 가능성을 열어 줄 것입니다. 그 동안`@dynamicCallable`은 널리 사용되지는 않지만 파이썬, 자바 스크립트와 다른 언어와의 상호 작용을 원하는 소수의 사람들에게는 엄청나게 중요합니다.
 
 &nbsp;
 
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 */
