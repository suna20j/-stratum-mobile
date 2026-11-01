
import XCTest
@testable import StratumMobileCore

final class MerkleTreeTests: XCTestCase {

    func testEmptyBranchesReturnCoinbaseHash() throws {
        let coinbaseHash = Data(
            (0..<32).map { UInt8($0) }
        )

        let root = try MerkleTree.calculateRoot(
            coinbaseHash: coinbaseHash,
            branches: []
        )

        XCTAssertEqual(
            root,
            Data(coinbaseHash.reversed())
        )
    }

    func testInvalidCoinbaseHashLengthThrows() {
        XCTAssertThrowsError(
            try MerkleTree.calculateRoot(
                coinbaseHash: Data(repeating: 0, count: 31),
                branches: []
            )
        )
    }

    func testInvalidBranchLengthThrows() {
        XCTAssertThrowsError(
            try MerkleTree.calculateRoot(
                coinbaseHash: Data(repeating: 0, count: 32),
                branches: [
                    Data(repeating: 0, count: 31)
                ]
            )
        )
    }

    func testInvalidHexThrows() {
        XCTAssertThrowsError(
            try MerkleTree.calculateRoot(
                coinbaseHashHex: "xyz",
                branchHex: []
            )
        )
    }

    func testEmptyBranchHexReturnsCoinbaseHash() throws {
        let hash = String(repeating: "11", count: 32)

        let root = try MerkleTree.calculateRoot(
            coinbaseHashHex: hash,
            branchHex: []
        )

        XCTAssertEqual(
            root,
            Data(repeating: 0x11, count: 32)
        )
    }
}
