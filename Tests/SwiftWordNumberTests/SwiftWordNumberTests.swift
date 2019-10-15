import XCTest
import SwiftCheck
@testable import SwiftWordNumber

final class SwiftWordNumberTests: XCTestCase {
    
    func testValidNumbers(){
        
        let gen = UInt64.arbitrary.suchThat({ i in
            return i > 0
        })
        property("Valid Numbers") <- forAll(gen) { (n : UInt64) in
            let word = try SwiftWordNumber.numberToWords(number: n).get()
            let number = try SwiftWordNumber.wordsToNumber(word: word).get()
            return n == number
        }
    }
    var stop: UInt64 = 1000
        var start: UInt64 = 1
        override func setUp() {
            super.setUp()
            
        }
        
        func testInvalidWords(){
            let invalidWords: [String] = [
                "one two hundred",
                "forty two hundred",
                "thousand one",
                "forty eleven",
                "four eleven",
                "one thirteen",
            ]
            
            for word in invalidWords{
                let word = SwiftWordNumber.wordsToNumber(word: word)
                
                switch word {
                case .failure:
                    XCTAssert(true)
                case .success(let number):
                    XCTFail("Invalid figure word \(word) return number \(number)")
                }
            }
        }
        

    static var allTests = [
        ("testInvalidWords", testInvalidWords),
        ("testValidNumbers", testValidNumbers),
        
    ]
}
