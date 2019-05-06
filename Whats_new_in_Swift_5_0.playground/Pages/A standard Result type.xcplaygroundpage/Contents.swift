/*:
 [Previous](@previous)
 [Home](Introduction)
 
 ## A standard Result type
 
 [SE-0235](https://github.com/apple/swift-evolution/blob/master/proposals/0235-add-result.md) 사용자 정의 형식으로 만들어야 했던 `Result` 형식이 표준 라이브러리에 함께 하게 되었습니다. 비동기 API 같은 복잡한 에러 처리를 간단하고 명확하게 처리할 수 있도록 해줍니다.
 
 스위프트의 `Result`는 `success`와 `failure`의 두 가지 경우를 갖는 열거형으로 구현됩니다. 둘 다 제네릭을 사용하여 구현되므로 사용자가 선택한 관련 값을 가질 수 있지만, 'failure'는 Swift의 'Error' 형식과 일치해야 합니다.

 'Result'를 보여주기 위해 우리는 얼마나 많은 읽지 않은 메시지가 사용자를 기다리고 있는지 파악하기 위해 서버에 연결하는 함수를 작성할 수 있습니다. 이 예제 코드에서는 요청된 URL 문자열이 유효한 URL이 아니라는 오류를 하나만 가집니다.
 */
enum NetworkError: Error {
    case badURL
}

/*:
 페칭 함수는 URL 문자열을 첫 번째 매개 변수로 사용하고, 완료 핸들러는 두 번째 매개 변수입니다. 완료 핸들러는 'Result' 형식으로 받아들이고, 성공 결과는 정수로 저장하고, 실패 결과는 일종의 `NetworkError`가 됩니다. 여기에 실제로 서버에 연결하지는 않지만, 완료 처리를 사용하면 적어도 비동기 코드를 시뮬레이션할 수 있습니다.
 
   코드는 다음과 같습니다:
 */
import Foundation

func fetchUnreadCount1(from urlString: String, completionHandler: @escaping (Result<Int, NetworkError>) -> Void)  {
    guard let url = URL(string: urlString) else {
        completionHandler(.failure(.badURL))
        return
    }
    
    // complicated networking code here
    print("Fetching \(url.absoluteString)...")
    completionHandler(.success(5))
}

/*:
 이 코드를 사용하려면 `Result` 내부의 값을 확인하여 다음과 같이 호출이 성공했는지 또는 실패했는지를 확인해야 합니다:
 */
fetchUnreadCount1(from: "https://www.hackingwithswift.com") { result in
    switch result {
    case .success(let count):
        print("\(count) unread messages.")
    case .failure(let error):
        print(error.localizedDescription)
    }
}

/*:
 자신의 코드에서 `Result`를 사용하기 전에 알아야 할 세 가지가 더 있습니다.
 
   첫째,`Result`는 `get()` 메소드를 가지고 있습니다. 이 메소드는 성공한 값이 있으면 그 값을 반환하거나, 그렇지 않은 경우는 에러를 던집니다. 이렇게 하면 `Result`를 다음과 같이 일반적인 던지기 호출로 변환할 수 있습니다:
 */
fetchUnreadCount1(from: "https://www.hackingwithswift.com") { result in
    if let count = try? result.get() {
        print("\(count) unread messages.")
    }
}

/*:
 둘째, `Result`에는 throwing closure를 받아들이는 생성자가 있습니다. 클로저가 성공적으로 값을 반환하면 `success`인 경우 값을 얻을 수 있고, 그렇지 않으면 `failure' 경우에 던져진 에러가 위치합니다.
 
   예제를 보시죠:
 */
let result = Result { try String(contentsOfFile: "someFile") }

/*:
 셋째, 생성한 특정 에러 열거형을 사용하는 대신 일반 'Error' 프로토콜을 사용할 수도 있습니다. 실제로 Swift Evolution의 제안에 따르면 "Result 대부분의 사용은 `Error` 형식의 인수로 `Swift.Error`를 사용할 것으로 예상됩니다." 라고 합니다.
 
 그래서, `Result<Int, NetworkError>`를 사용하기보다는 `Result<Int, Error>`를 사용할 수 있습니다. 이것은 지정된 형식 throws의 안전성을 잃는다는 것을 의미하긴 하지만, 당신은 다양한 오류 열거 형을 던질 수 있는 능력을 얻습니다. 당신이 선호하는 코딩 스타일에 맞는 거로 선택하면 됩니다.
 
 ## 변환 결과 (Transforming Result)
 
 `Result`에는 유용한 `map()`, `flatMap()`, `mapError()`, `flatMapError()`의 4가지 메소드가 있습니다. 각각의 함수는 성공 또는 에러를 어떻게든 변환할 수 있는 능력을 제공하며, 처음 두 함수는 'Optional'에 같은 이름의 메소드와 비슷하게 작동합니다.
 
 `map()` 메소드는 `Result`를 보고, 당신이 지정한 클로저를 사용하여 성공 값을 다른 값으로 변환합니다. 그러나 대신 실패가 발견되면, 그 값을 직접 사용하고 변환을 무시합니다.
 
 이를 증명하기 위해, 0에서 최대 사이의 난수를 생성하는 코드를 작성한 다음 그 수의 요소를 계산합니다. 사용자가 0 이하의 임의의 숫자를 요청하거나, 숫자가 소수인 경우(즉, 자신과 1을 제외한 다른 요소가 없는 경우), 그다음에 실패로 간주합니다.
 
 가능한 두 가지 실패 사례를 모델로 코드를 작성하는 것으로 시작할 수 있습니다. 첫 번째 사례는 사용자가 0 미만의 임의의 숫자를 생성하려고 시도했고, 두 번째는 생성된 숫자가 소수인 경우입니다:
 */
enum FactorError: Error {
    case belowMinimum
    case isPrime
}

/*:
 다음으로, 최대 수를 허용하고 임의의 수 또는 오류를 반환하는 함수를 작성합니다:
 */
func generateRandomNumber(maximum: Int) -> Result<Int, FactorError> {
    if maximum < 0 {
        // creating a range below 0 will crash, so refuse
        return .failure(.belowMinimum)
    } else {
        let number = Int.random(in: 0...maximum)
        return .success(number)
    }
}

/*:
 그것이 호출될 때, 우리가 얻은 결과는 정수이거나 에러가 될 것이므로 `map()`을 사용하여 변환할 수 있습니다:
 */
let result1 = generateRandomNumber(maximum: 11)
let stringNumber = result1.map { "The random number is: \($0)." }

/*:
 우리가 유효한 최대 숫자를 전달했으므로, `result`는 성공적으로 난수를 출력할 것입니다. 따라서 `map()`을 사용하면 해당 난수를 가져와서 문자열 삽입과 함께 사용하고, 다음으로 `Result<String, FactorError>` 형식의 다른 `Result` 형식을 반환합니다.
 
 그러나 `generateRandomNumber(maximum : -11)`을 사용했다면 `result`는 `FactorError.belowMinimum`으로 실패 case로 설정될 것입니다. 그래서 `map()`을 사용하면 여전히 `Result<String, FactorError>`를 리턴할 것이나 같은 실패의 경우와 동일한 'FactorError.belowMinimum` 오류가 발생합니다.
 
 이제 `map()'을 사용하여 성공 형식을 다른 형식으로 변환하는 방법을 보았습니다. 계속 진행하겠습니다. 우리는 난수를 가지고 있으므로 다음 단계는 factors를 계산하는 것입니다. 이를 위해 숫자를 허용하고, factors를 계산하는 또 다른 함수를 작성합니다. 숫자가 소수라는 것을 알게 되면 `isPrime` 오류로 실패한 `Result`를 되돌려 보내고, 그렇지 않으면 factors의 수를 되돌려 보냅니다.
 
   여기에 그 코드가 있습니다:
 */
func calculateFactors(for number: Int) -> Result<Int, FactorError> {
    let factors = (1...number).filter { number % $0 == 0 }
    
    if factors.count == 2 {
        return .failure(.isPrime)
    } else {
        return .success(factors.count)
    }
}

/*:
 우리가 `map()`을 `calculateFactors()`를 사용한 `generateRandomNumber()`의 출력으로 변환하고 싶다면 다음과 같이 됩니다:
 */
let result2 = generateRandomNumber(maximum: 10)
let mapResult = result2.map { calculateFactors(for: $0) }
/*:
 그러나, `mapResult`는 꽤 좋아 보이지 않는 형식입니다: 형식은 `Result<Result<Int, FactorError>, FactorError>` 입니다.  'Result' 안에 다른 'Result'가 있는 중첩의 형태입니다. 복잡하죠?
 
   Result에는 optional처럼, `flatMap()` 메소드가 들어있습니다. 변환 클로저가 ` Result`를 반환하면, `flatMap()`은 새로운 `Result`를 다른 `Result`로 래핑하는 것이 아니라 직접 반환합니다:
 */
let flatMapResult = result2.flatMap { calculateFactors(for: $0) }

/*:
 그래서, `mapResult`가 `Result<Result<Int, FactorError>, FactorError>`일 때, `flatMapResult`는 `Result<Int, FactorError>` 형식으로 단조롭게(*flat*) 만들어 줍니다. - 첫 번째 원래 성공 값(난수)이 새로운 성공 값(factors의 수)으로 변환되었습니다. `map()`과 마찬가지로 `Result`가 실패한 경우 `flatMapResult`도 실패합니다.
 
 `mapError()`와`flatMapError()`에 대해서는 *success* 값보다는 *error* 값을 변환한다는 점을 제외하고는 비슷한 일을 합니다.
 
 &nbsp;
 
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 */

