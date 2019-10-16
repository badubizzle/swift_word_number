import Foundation

public class SwiftWordNumber {
    fileprivate static let WORD_SEPARATORS = [" and ", ",", "-", " "]
    fileprivate static let wordsNumber: [String: UInt64] = [
        "one": 1,
        "two": 2,
        "three": 3,
        "four": 4,
        "five": 5,
        "six": 6,
        "seven": 7,
        "eight": 8,
        "nine": 9,
        "ten": 10,
        "eleven": 11,
        "twelve": 12,
        "thirteen": 13,
        "fourteen": 14,
        "fifteen": 15,
        "sixteen": 16,
        "seventeen": 17,
        "eighteen": 18,
        "nineteen": 19,
        "twenty": 20,
        "thirty": 30,
        "forty": 40,
        "fifty": 50,
        "sixty": 60,
        "seventy": 70,
        "eighty": 80,
        "ninety": 90,
        "hundred": 100,
        "thousand": 1000,
        "million": 1_000_000,
        "billion": 1_000_000_000,
        "trillion": 1_000_000_000_000,
    ]

    static var numbersWord: [UInt64: String] = {
        var r = [UInt64: String]()
        for (word, number) in wordsNumber {
            r[number] = word
        }
        return r
    }()

    public enum NumberWordsError: Error {
        case MustBePositive(message: String)
        case InvalidFigure(message: String)
    }

    private static func splitString(string: String, separators: [String]) -> [String] {
        guard separators.count > 0 else {
            return []
        }

        var result = string.components(separatedBy: separators[0])
        guard separators.count > 1 else {
            return result
        }
        for i in 1 ..< separators.count {
            result = result.map { s in
                s.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).components(separatedBy: separators[i])
            }.flatMap { s in
                s
            }
        }
        return result
    }

    private static func appendNumber(number: UInt64, results: inout [UInt64]) {
        if results.count > 0, results.last! < 1000 {
            let last = results.popLast()
            results.append(last! + number)
        } else {
            results.append(number)
        }
    }

    public static func wordsToNumber(word: String) -> Result<UInt64, Error> {
        let parts: [String] = splitString(string: word, separators: WORD_SEPARATORS)

        var results = [UInt64]()

        for i in 0 ..< parts.count {
            let w = parts[i]
            if let number = wordsNumber[w] {
                switch number {
                case 1 ... 9:
                    // validation
                    // ones must be followed by hundred, thousand, million, etc
                    if i < parts.count - 1 {
                        let nextW = parts[i + 1]
                        if let n = wordsNumber[nextW], n < 100 {
                            return Result.failure(NumberWordsError.InvalidFigure(message: "Invalid figure: \(word) at '\(w) \(nextW)'"))
                        }
                    }
                    appendNumber(number: number, results: &results)
                case 10 ... 19:

                    // validation
                    // ten...19 must be followed by hundred, thousand, million, etc
                    if i < parts.count - 1 {
                        let nextW = parts[i + 1]
                        if let n = wordsNumber[nextW], n < 1000 {
                            return Result.failure(NumberWordsError.InvalidFigure(message: "Invalid figure: \(word) at '\(w) \(nextW)'"))
                        }
                    }
                    appendNumber(number: number, results: &results)
                case 20 ... 99:
                    // validation
                    // 20..99 must be followed by ones or thousand, million, etc
                    if i < parts.count - 1 {
                        let nextW = parts[i + 1]
                        if let n = wordsNumber[nextW], n >= 10, n < 1000 {
                            return Result.failure(NumberWordsError.InvalidFigure(message: "Invalid figure: \(word) at '\(w) \(nextW)'"))
                        }
                    }
                    appendNumber(number: number, results: &results)
                case let x where x >= 100:
                    // validation
                    // hundred ones
                    // thousand, million, etc must be preceeded by either ones,

                    if results.count < 1 {
                        return Result.failure(NumberWordsError.InvalidFigure(message: "Invalid figure: \(word) at '\(w)'"))
                    }

                    if results.count > 0, results.last! < 1000 {
                        // hundred must be preceeded by ones only
                        if number == 100, results.last! > 9 {
                            return Result.failure(NumberWordsError.InvalidFigure(message: "Invalid figure: \(word) at '\(parts[i - 1]) \(w)'"))
                        }

                        let last = results.popLast()
                        results.append(number * last!)
                    } else {}
                default:
                    break
                }
            }
        }

        var total: UInt64 = 0
        for n in results {
            total = total + n
        }
        return Result.success(total)
    }

    public static func numberToWords(number: UInt64) -> Result<String, Error> {
        guard number > 0 else {
            return Result.failure(NumberWordsError.MustBePositive(message: "Number must be positive"))
        }
        var remainder = number
        let numbers = numbersWord.keys.sorted().reversed()

        var bigNumbers = [String]()
        var smallNumber = [String]()

        for n in numbers {
            if remainder < 1 {
                break
            }

            if let word = numbersWord[n] {
                if remainder >= n, n >= 100 {
                    let count = numberToWords(number: remainder / n)
                    switch count {
                    case let .success(s):
                        bigNumbers.append("\(s) \(word)")
                    default:
                        break
                    }
                } else if remainder >= n {
                    smallNumber.append(word)
                }
            }
            remainder = remainder % n
        }

        if bigNumbers.count > 0, number >= 100, smallNumber.count > 0 {
            bigNumbers.append(smallNumber.joined(separator: " "))
            return Result.success(formatWords(words: bigNumbers))
        }

        bigNumbers.append(contentsOf: smallNumber)

        return Result.success(bigNumbers.joined(separator: " "))
    }

    private static func formatWords(words: [String]) -> String {
        if words.count > 1 {
            if let last = words.last {
                let rest = words.prefix(words.count - 1)
                return "\(rest.joined(separator: ", ")) and \(last)"
            }
        }
        return words[0]
    }

    public static func formatNumber(number: UInt64) -> Result<String, Error> {
        guard number < 0 else {
            return Result.failure(NumberWordsError.MustBePositive(message: "Number must be positive integer"))
        }
        
        var numberString: String = "\(number)"
        let chunk = 3

        var end = numberString.count

        var result = [String]()
        while end > 0 {
            
            result.append(String(numberString.suffix(chunk)))
            
            
            end = end - chunk
            if end < 0 {
                break
            }
            numberString = String(numberString.prefix(end))
        }

        return Result.success(result.reversed().joined(separator: ","))
    }
}
