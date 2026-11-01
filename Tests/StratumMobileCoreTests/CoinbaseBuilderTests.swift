
import XCTest
@testable import StratumMobileCore

final class CoinbaseBuilderTests: XCTestCase {

    func testBuildCoinbaseTransaction() throws {
        let result = try CoinbaseBuilder.build(
            coinbasePart1: "0102",
            extraNonce1: "aabb",
            extraNonce2: "ccdd",
            coinbasePart2: "0304",
            extraNonce2Size: 2
        )

        XCTAssertEqual(
            result,
            Data([0x01, 0x02, 0xAA, 0xBB, 0xCC, 0xDD, 0x03, 0x04])
        )
    }

    func testInvalidExtraNonce2SizeThrows() {
        XCTAssertThrowsError(
            try CoinbaseBuilder.build(
                coinbasePart1: "0102",
                extraNonce1: "aabb",
                extraNonce2: "cc",
                coinbasePart2: "0304",
                extraNonce2Size: 2
            )
        )
    }

    func testInvalidHexThrows() {
        XCTAssertThrowsError(
            try CoinbaseBuilder.build(
                coinbasePart1: "xyz",
                extraNonce1: "aabb",
                extraNonce2: "ccdd",
                coinbasePart2: "0304",
                extraNonce2Size: 2
            )
        )
    }

    func testInvalidExtraNonce1Throws() {
        XCTAssertThrowsError(
            try CoinbaseBuilder.build(
                coinbasePart1: "0102",
                extraNonce1: "abc",
                extraNonce2: "ccdd",
                coinbasePart2: "0304",
                extraNonce2Size: 2
            )
        )
    }

    func testTransactionHashHas32Bytes() {
        let transaction = Data([0x01, 0x02, 0x03])
        let hash = CoinbaseBuilder.transactionHash(
            transaction: transaction
        )

        XCTAssertEqual(hash.count, 32)
    }
}
