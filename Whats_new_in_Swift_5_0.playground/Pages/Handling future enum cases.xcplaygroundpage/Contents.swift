/*:
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 
 ## Handling future enum cases
 
 [SE-0192](https://github.com/apple/swift-evolution/blob/master/proposals/0192-non-exhaustive-enums.md) 고정된 열거형과 미래에 변경될 수 있는 열거형을 구분할 수 있는 기능이 추가되었습니다.
 
 Swift의 보안 기능 중 하나는 모든 스위치 설명이 철저해야 하며, 모든 경우를 다루어야 한다는 것입니다. 이 기능은 안전성 측면에서 효과적이지만 나중에 새로운 사례가 추가될 때 호환성 문제가 발생합니다. 시스템 프레임 워크는 제공하지 않은 다른 내용을 보내거나 의존하는 코드가 새 사례를 추가하게 된다면 스위치가 더 이상 철저하지 않기 때문에 컴파일이 중단됩니다.
 
 `@unknown` 속성으로 우리는 두 가지 미묘하게 다른 시나리오를 구분할 수 있습니다: "이 기본 케이스는 개별적으로 처리하고 싶지 않기 때문에 다른 모든 케이스에 대해 실행해야 합니다"와 "모든 케이스를 개별적으로 처리하고 싶습니다. 미래에 어떤 것이 나오면 오류를 일으키기보다는 이것을 사용하십시오."
 
 여기 열거형의 예제가 있습니다:
 */
enum PasswordError: Error {
    case short
    case obvious
    case simple
}

/*:
 `switch` 블록을 사용하여 각각의 경우를 다루는 코드를 작성할 수 있습니다:
 */
func showOld(error: PasswordError) {
    switch error {
    case .short:
        print("Your password was too short.")
    case .obvious:
        print("Your password was too obvious.")
    default:
        print("Your password was too simple.")
    }
}

/*:
 이는 short, obvious 암호의 두 가지 명시적인 경우를 사용하지만, 세 번째 사례를 default 블록으로 묶습니다.
 
 이제 이전에 사용된 암호에 대해 'old'라는 열거 형에 새 사례를 추가하면 메시지가 실제로 이해가되지 않더라도 'default' 사례가 자동으로 호출됩니다 - 암호는 너무 단순하지 않아야 합니다.
 
 스위프트는 기술적으로 정확하기 때문에 이 코드에 대해 경고할 수 없습니다. 그래서 이 실수는 쉽게 놓칠 수 있습니다. 다행스럽게도 새로운 `@unknown` 속성은 완벽하게 수정합니다 - 이것은 `default` 케이스에서만 사용될 수 있으며, 새로운 케이스가 앞으로 올 때 실행되도록 설계되었습니다.
 
 아래 예제를 보시죠:
 */
func showNew(error: PasswordError) {
    switch error {
    case .short:
        print("Your password was too short.")
    case .obvious:
        print("Your password was too obvious.")
    @unknown default:
        print("Your password wasn't suitable.")
    }
}

/*:
 그 코드는 이제 `switch` 블록이 더 이상 완전하지 않기 때문에 경고를 발행할 것입니다 - Swift는 우리가 각 경우를 명확하게 처리하기를 원합니다. 유익하게도 이것은 이 속성을 매우 유용하게 만드는 단 하나의 경고일 뿐입니다: 프레임워크가 나중에 새로운 케이스를 추가하면 경고를 받게 되지만 소스 코드를 손상시키지 않습니다.
 
 &nbsp;
 
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 */
