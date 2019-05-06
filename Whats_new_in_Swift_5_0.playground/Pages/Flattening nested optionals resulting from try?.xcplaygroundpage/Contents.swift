/*:
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 
 ## Flattening nested optionals resulting from try?
 
 [SE-0230](https://github.com/apple/swift-evolution/blob/master/proposals/0230-flatten-optional-try.md) `try?'는 중첩된 옵셔널이 평평하게 일반적인 옵셔널이 되도록 작동방식을 수정했습니다. 이는 이전의 Swift 버전에서 옵셔널 체이닝과 조건부 typecast 작업 두 가지 모두 평평한 옵셔널로 만듭니다.
 
 다음은 변경을 보여주는 실질적인 예입니다:
 */
struct User {
    var id: Int
    
    init?(id: Int) {
        if id < 1 {
            return nil
        }
        
        self.id = id
    }
    
    func getMessages() throws -> String {
        // complicated code here
        return "No messages"
    }
}

let user = User(id: 1)
let messages = try? user?.getMessages()
print(type(of: messages))
/*:
 `User` 구조체는 실패 가능성이 있는 생성자를 가지고 있습니다. 우리는 사람들이 유효한 ID를 가진 사용자를 만들 수 있기를 원하기 때문입니다. `getMessages()`메소드는 이론적으로 사용자를 위한 모든 메시지 목록을 얻기 위한 일종의 복잡한 코드를 포함할 것이므로 `throws`로 표시됩니다. 코드가 컴파일되도록 고정 문자열을 반환하도록 했습니다.
 
 여기서 핵심은 마지막 줄입니다: user가 옵셔널이기 때문에 옵션널 체인닝을 사용합니다. 그리고 `getMessages()`가 오류를 던질 수 있기 때문에 `try?`를 사용하여 던지는 메소드를 옵셔널로 변환하고, 중첩된 옵셔널로 끝납니다. Swift 4.2와 그 이전 버전에서는 `messages`가 `String??`(옵셔널 옵셔널 문자열)로 만들어졌지만, Swift 5.0에서 `try?`는 옵셔널로 값을 래핑하지 않습니다. 그래서` messages`은 마지막 출력에 나오듯이 그냥 `String?`(Optional<String>)이 됩니다.
 
 이 새로운 동작은 옵셔널 체이닝과 조건부 typecasting의 기존 동작과 일치합니다. 즉 원한다면 한 줄의 코드에서 12번 옵셔널 체이닝을 사용할 수 있지만 12개의 중첩된 옵셔널로 끝나지는 않을 것입니다. 그만큼 언래핑도 12번을 해야합니다. 옵셔널 지옥에 빠지기 원하지 않겠죠. 비슷하게, `as?`와 함께 옵셔널 체이닝을 사용했다면, 보통 옵셔널이 하나의 수준에서 끝나기를 원하기 떄문입니다.
 
 &nbsp;
 
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 */
