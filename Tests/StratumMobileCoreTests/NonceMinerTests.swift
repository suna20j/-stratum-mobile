
import XCTest
@testable import StratumMobileCore

final class NonceMinerTests: XCTestCase {

    func testHashBelowTargetIsAccepted() {
        let hash = Data(repeating: 0x00, count: 32)
        let target = Data(repeating: 0xff, count: 32)

        XCTAssertTrue(
            NonceMiner.meetsTarget(
                hash: hash,
                target: target
            )
        )
    }

    func testHashAboveTargetIsRejected() {
        let hash = Data(repeating: 0xff, count: 32)
        let target = Data(repeating: 0x00, count: 32)

        XCTAssertFalse(
            NonceMiner.meetsTarget(
                hash: hash,
                target: target
            )
        )
    }

    func testEqualHashAndTargetAreAccepted() {
        let value = Data(repeating: 0x42, count: 32)

        XCTAssertTrue(
            NonceMiner.meetsTarget(
                hash: value,
                target: value
            )
        )
    }

    func testInvalidHashLengthIsRejected() {
        let hash = Data(repeating: 0x00, count: 31)
        let target = Data(repeating: 0xff, count: 32)

        XCTAssertFalse(
            NonceMiner.meetsTarget(
                hash: hash,
                target: target
            )
        )
    }

    func testInvalidTargetLengthIsRejected() {
        let hash = Data(repeating: 0x00, count: 32)
        let target = Data(repeating: 0xff, count: 31)

        XCTAssertFalse(
            NonceMiner.meetsTarget(
                hash: hash,
                target: target
            )
        )
    }
}
