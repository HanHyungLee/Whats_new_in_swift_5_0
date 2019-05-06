/*:
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 
 ## Checking for integer multiples
 
 [SE-0225](https://github.com/apple/swift-evolution/blob/master/proposals/0225-binaryinteger-iseven-isodd-ismultiple.md) 정수에 `isMultiple(of:)` 메소드를 추가하여 나누기 나머지 연산자인 `%`를 사용하는 것보다 훨씬 명확한 방법으로 하나의 숫자가 다른 것의 배수인지 검사할 수 있습니다.
 
 예제:
 */
let rowNumber = 4

if rowNumber.isMultiple(of: 2) {
    print("Even")
} else {
    print("Odd")
}

/*:
 그렇습니다, 우리는 `if rowNumber % 2 == 0`을 사용하여 동일한 검사를 작성할 수 있습니다. 그러나 그 방법이 명확하지는 않습니다. 즉, `isMultiple(of:)`을 메소드로 사용하면 Xcode의 코드 완성 옵션에 나열될 수 있습니다. 발견 가능성을 돕습니다.
 
 &nbsp;
 
 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 */
