
import XCTest
@testable import StratumMobileCore

final class ShareTargetTests: XCTestCase {

    func testDifficultyOneTarget() throws {
        let target = try ShareTarget.calculate(difficulty: 1.0)

        let hex = target
            .map { String(format: "%02x", $0) }
            .joined()

        XCTAssertEqual(
            hex,
            "00000000ffff0000000000000000000000000000000000000000000000000000"
        )
    }

    func testInvalidDifficultyZero() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(difficulty: 0.0)
        )
    }

    func testInvalidNegativeDifficulty() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(difficulty: -1.0)
        )
    }

    func testInvalidInfiniteDifficulty() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(
                difficulty: Double.infinity
            )
        )
    }

    func testInvalidNaNDifficulty() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(
                difficulty: Double.nan
            )
        )
    }
}
