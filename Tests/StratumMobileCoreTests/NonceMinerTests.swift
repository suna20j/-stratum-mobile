
import XCTest
@testable import StratumMobileCore

final class NonceMinerTests: XCTestCase {

    func testHashBelowTargetIsAccepted() {
        let hash = Data(repeating: 0x00, count: 32)
        let target = Data(repeating: 0xFF, count: 32)

        XCTAssertTrue(
            NonceMiner.meetsTarget(hash: hash, target: target)
        )
    }

    func testHashAboveTargetIsRejected() {
        let hash = Data(repeating: 0xFF, count: 32)
        let target = Data(repeating: 0x00, count: 32)

        XCTAssertFalse(
            NonceMiner.meetsTarget(hash: hash, target: target)
        )
    }

    func testEqualHashAndTargetAreAccepted() {
        let value = Data(repeating: 0x42, count: 32)

        XCTAssertTrue(
            NonceMiner.meetsTarget(hash: value, target: value)
        )
    }

    func testInvalidHashLengthIsRejected() {
        let hash = Data(repeating: 0x00, count: 31)
        let target = Data(repeating: 0xFF, count: 32)

        XCTAssertFalse(
            NonceMiner.meetsTarget(hash: hash, target: target)
        )
    }

    func testInvalidTargetLengthIsRejected() {
        let hash = Data(repeating: 0x00, count: 32)
        let target = Data(repeating: 0xFF, count: 31)

        XCTAssertFalse(
            NonceMiner.meetsTarget(hash: hash, target: target)
        )
    }

    func testByteOrderComparison() {
        var hash = Data(repeating: 0x00, count: 32)
        var target = Data(repeating: 0x00, count: 32)

        hash[0] = 0x01
        target[31] = 0x02

        XCTAssertTrue(
            NonceMiner.meetsTarget(hash: hash, target: target)
        )
    }

    func testHashJustAboveTargetIsRejected() {
        var hash = Data(repeating: 0x00, count: 32)
        var target = Data(repeating: 0x00, count: 32)

        hash[0] = 0x02
        target[31] = 0x01

        XCTAssertFalse(
            NonceMiner.meetsTarget(hash: hash, target: target)
        )
    }

    func testScanFindsNonceWithEasyTarget() throws {
        let zeroHash = Data(repeating: 0x00, count: 32)

        let header = try BitcoinHeader(
            version: 1,
            previousBlockHash: zeroHash,
            merkleRoot: zeroHash,
            timestamp: 1,
            bits: 1,
            nonce: 0
        )

        let easyTarget = Data(repeating: 0xFF, count: 32)

        let result = NonceMiner.scan(
            header: header,
            startingNonce: 0,
            count: 10,
            target: easyTarget
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.nonce, 0)
        XCTAssertEqual(result?.hashesChecked, 1)
    }

    func testDifficultyOneTarget() throws {
        let target = try ShareTarget.calculate(difficulty: 1.0)

        let expectedHex =
            "00000000ffff0000000000000000000000000000000000000000000000000000"

        XCTAssertEqual(
            BitcoinHash.toHex(target),
            expectedHex
        )
    }

    func testDifficultyTwoTarget() throws {
        let target = try ShareTarget.calculate(difficulty: 2.0)

        let expectedHex =
            "000000007fff8000000000000000000000000000000000000000000000000000"

        XCTAssertEqual(
            BitcoinHash.toHex(target),
            expectedHex
        )
    }

    func testZeroDifficultyIsRejected() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(difficulty: 0)
        )
    }

    func testNegativeDifficultyIsRejected() {
        XCTAssertThrowsError(
            try ShareTarget.calculate(difficulty: -1)
        )
    }
}
