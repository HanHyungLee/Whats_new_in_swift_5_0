/*:
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 
 ## Customizing string interpolation
 
 [SE-0228](https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md) 드라마틱하게 개조된 Swift의 문자열 삽입 시스템은 그래서 더 효율적이고 유연 해졌으며, 이전에는 불가능했던 완전히 새로운 기능들을 만들어 냈습니다.
 
 가장 기본적인 형식의 새로운 문자열 삽입 시스템을 사용하면, 객체가 문자열에 나타나는 방식을 제어 할 수 있습니다. Swift는 구조체 이름 뒤에 모든 속성을 출력하기 때문에 디버깅에 유용한 구조체의 기본 동작을 갖습니다. 그러나 클래스(이 동작이 없는 클래스)로 작업하거나 사용자가 직접 출력 할 수 있도록 출력을 포맷하려는 경우 새 문자열 삽입 시스템을 사용할 수 있습니다.
 
   예를 들어, 우리가 다음과 같은 구조체를 가지고 있다면 :
 */
struct User {
    var name: String
    var age: Int
}

/*:
 User를 깔끔하게 출력을 위한 특수 문자열 삽입을 추가하기를 원한다면, 새로운 `appendInterpolation()` 메소드로 `String.StringInterpolation` 확장을 추가할 것입니다. Swift는 이미 이들 중 몇 가지를 내장하고 있으며, 사용자는 삽입 *type* - 이 경우에는 `User`를 사용하여 호출할 메소드를 찾습니다.
 
 이 경우, User의 이름과 나이를 단일 문자열에 넣은 구현을 추가한 다음, 내장 `appendInterpolation()` 메소드 중 하나를 호출하여 이를 문자열에 추가합니다.
 */
extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: User) {
        appendInterpolation("My name is \(value.name) and I'm \(value.age)")
    }
}

/*:
 이제 사용자를 생성하고 데이터를 출력할 수 있습니다.
 */
let user = User(name: "Guybrush Threepwood", age: 33)
print("User details: \(user)")

/*:
 원래 user의 출력 결과는 **User details: User(name: "Guybrush Threepwood", age: 33)** 이지만, 사용자 정의 문자열 삽입을 사용하면 **User details: My name is Guybrush Threepwood and I'm 33**로 출력이 됩니다. 물론, 그 기능은 단지 'CustomStringConvertible` 프로토콜을 구현하는 것과 다르지 않습니다. 그래서 보다 고급 사용법으로 넘어갑시다.
 
 사용자 정의 삽입 메소드는 레이블이 지정되거나 레이블이 지정되지 않은 필요한 만큼의 많은 매개 변수를 취할 수 있습니다. 예를 들어, 다음과 같이 다양한 스타일을 사용하여 숫자를 출력하는 삽입을 추가할 수 있습니다:
 */
import Foundation

extension String.StringInterpolation {
    mutating func appendInterpolation(_ number: Int, style: NumberFormatter.Style) {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        
        if let result = formatter.string(from: number as NSNumber) {
            appendLiteral(result)
        }
    }
}
/*:
 `NumberFormatter` 클래스는 통화 ($72.83), 순서 숫자 (1st, 12th), 철자 출력 (five, forty-three)을 포함한 많은 스타일을 가지고 있습니다. 그래서 우리는 난수를 생성하고 다음과 같은 문자열로 철자를 지정할 수 있습니다:
 */
let number = Int.random(in: 0...100)
let lucky = "The lucky number this week is \(number, style: .spellOut)."
print(lucky)
/*:
 `appendLiteral()`을 필요할 때마다 여러 번 호출할 수도 있고, 필요하다면 전혀 호출하지 않을 수도 있습니다. 예를 들어, 다음과 같이 문자열을 여러 번 반복하기 위해 문자열 삽입을 추가할 수 있습니다.
 */
extension String.StringInterpolation {
    mutating func appendInterpolation(repeat str: String, _ count: Int) {
        for _ in 0 ..< count {
            appendLiteral(str)
        }
    }
}

print("Baby shark \(repeat: "doo ", 5)")

/*:
 그리고 이러한 것들은 단지 일반적인 메소드이기에, 스위프트의 모든 기능 범위에 사용할 수 있습니다. 예를 들어, 문자열 배열을 결합하는 삽입 방법을 추가할 수 있습니다. 그러나 배열이 비어있는 경우 문자열을 대신 반환하는 클로저를 실행하십시오.
 */
extension String.StringInterpolation {
    mutating func appendInterpolation(_ values: [String], empty defaultValue: @autoclosure () -> String) {
        if values.count == 0 {
            appendLiteral(defaultValue())
        } else {
            appendLiteral(values.joined(separator: ", "))
        }
    }
}

let names = ["Harry", "Ron", "Hermione"]
print("List of students: \(names, empty: "No one").")

/*:
 `@autoclosure'를 사용한다는 것은 단순한 값을 사용하거나 기본값을 위해 복잡한 함수를 호출할 수 있다는 것을 의미하지만, `values.count`가 0일 때만 실행이 됩니다.
 
 `ExpressibleByStringLiteral`과`ExpressibleByStringInterpolation` 프로토콜의 조합으로 문자열 삽입을 사용하여 전체 타입을 생성할 수 있게 되었습니다. 그리고`CustomStringConvertible`을 추가하면 문자열로 출력할 수도 있습니다.
 
 이 작업을 수행하려면 몇 가지 구체적인 기준을 충족해야 합니다.
 
 - 우리가 만드는 모든 유형은`ExpressibleByStringLiteral`,`ExpressibleByStringInterpolation`과 `CustomStringConvertible`을 준수해야 합니다. 후자는 유형 출력 방법을 사용자 정의하려는 경우에만 필요합니다.
 - *내부* 당신의 타입은`StringInterpolationProtocol`을 따르는`StringInterpolation`이라는 중첩된 구조체일 필요가 있습니다.
   - 중첩된 구조체에는 예상할 수 있는 데이터의 양을 대략 알려주는 두 개의 정수를 허용하는 생성자가 있어야 합니다.
   - 또한 `appendInterpolation()` 메소드와 하나 이상의 `appendLiteral()` 메소드를 구현해야 합니다.
   - 기본 유형에는 문자열 리터럴과 문자열 삽입에서 만들 수 있는 두 개의 초기화 프로그램이 필요합니다.
 
 우리는 이 모든 것들을 다양한 공통 요소들로부터 HTML을 구성할 수 있는 예제 유형으로 통합할 수 있습니다. 중첩된 `StringInterpolation` 구조체 안에 있는 “scratchpad”는 문자열일 것입니다: 새로운 리터럴이나 삽입이 추가될 때마다 문자열에 추가할 것입니다. 무슨 일이 벌어지고 있는지 정확히 알 수 있도록 다양한 추가 메소드 안에 `print()` 호출을 추가했습니다.
 
   여기에 코드가 있습니다.
 */
struct HTMLComponent: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, CustomStringConvertible {
    struct StringInterpolation: StringInterpolationProtocol {
        // start with an empty string
        var output = ""
        
        // allocate enough space to hold twice the amount of literal text
        init(literalCapacity: Int, interpolationCount: Int) {
            output.reserveCapacity(literalCapacity * 2)
        }
        
        // a hard-coded piece of text – just add it
        mutating func appendLiteral(_ literal: String) {
            print("Appending \(literal)")
            output.append(literal)
        }
        
        // a Twitter username – add it as a link
        mutating func appendInterpolation(twitter: String) {
            print("Appending \(twitter)")
            output.append("<a href=\"https://twitter/\(twitter)\">@\(twitter)</a>")
        }
        
        // an email address – add it using mailto
        mutating func appendInterpolation(email: String) {
            print("Appending \(email)")
            output.append("<a href=\"mailto:\(email)\">\(email)</a>")
        }
    }
    
    // the finished text for this whole component
    let description: String
    
    // create an instance from a literal string
    init(stringLiteral value: String) {
        description = value
    }
    
    // create an instance from an interpolated string
    init(stringInterpolation: StringInterpolation) {
        description = stringInterpolation.output
    }
}
/*:
 우리는 이제 다음과 같이 문자열 십입을 사용하여`HTMLComponent`의 인스턴스를 생성하고 사용할 수 있습니다:
 */
let text: HTMLComponent = "You should follow me on Twitter \(twitter: "twostraws"), or you can email me at \(email: "paul@hackingwithswift.com")."
print(text)

/*:
 내부에 흩어져있는 `print()`호출 덕분에 문자열 삽입 기능이 어떻게 작동하는지 정확히 알 수 있습니다: “Appending You should follow me on Twitter”, "Appending twostraws", "Appending , or you can email me at ","Appending paul@hackingwithswift.com", 마침내 "Appending ."- 각 부분은 메소드 호출을 트리거하고 우리 문자열에 추가됩니다.
 
 &nbsp;
 
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 */
