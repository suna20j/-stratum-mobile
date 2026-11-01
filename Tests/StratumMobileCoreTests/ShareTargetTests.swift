
import XCTest
@testable import StratumMobileCore

final class ShareTargetTests: XCTestCase {

    func testDifficultyOneProducesCorrectTarget() throws {
        let target = try ShareTarget.calculate(difficulty: 1.0)

        let expected =
            "00000000ffff0000000000000000000000000000000000000000000000000000"

        let hex = target.map {
            String(format: "%02x", $0)
        }.joined()

        XCTAssertEqual(hex, expected)
    }

    func testDifficultyTwoProducesHalfTarget() throws {
        let targetOne = try ShareTarget.calculate(difficulty: 1.0)
        let targetTwo = try ShareTarget.calculate(difficulty: 2.0)

        var expected = [UInt8](targetOne)
        var carry: UInt8 = 0

        for index in 0..<expected.count {
            let value = UInt16(carry) * 256 + UInt16(expected[index])
            expected[index] = UInt8(value / 2)
            carry = UInt8(value % 2)
        }

        XCTAssertEqual(targetTwo, Data(expected))
    }

    func testZeroDifficultyThrows() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(difficulty: 0)
        )
    }

    func testNegativeDifficultyThrows() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(difficulty: -1)
        )
    }

    func testInfiniteDifficultyThrows() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(difficulty: .infinity)
        )
    }

    func testNaNDifficultyThrows() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(difficulty: .nan)
        )
    }
}
