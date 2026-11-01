
import XCTest
@testable import StratumMobileCore

final class BitcoinHeaderTests: XCTestCase {

    func testHeaderHasExactly80Bytes() throws {
        let header = try BitcoinHeader(
            version: 1,
            previousBlockHash: Data(repeating: 0x11, count: 32),
            merkleRoot: Data(repeating: 0x22, count: 32),
            timestamp: 1,
            bits: 1,
            nonce: 0
        )

        XCTAssertEqual(header.serialize().count, 80)
    }

    func testHeaderUsesLittleEndian() throws {
        let header = try BitcoinHeader(
            version: 0x01020304,
            previousBlockHash: Data(repeating: 0x11, count: 32),
            merkleRoot: Data(repeating: 0x22, count: 32),
            timestamp: 0x05060708,
            bits: 0x0A0B0C0D,
            nonce: 0x0E0F1011
        )

        let data = header.serialize()

        XCTAssertEqual(
            Array(data.prefix(4)),
            [0x04, 0x03, 0x02, 0x01]
        )

        XCTAssertEqual(
            Array(data.suffix(12)),
            [
                0x08, 0x07, 0x06, 0x05,
                0x0D, 0x0C, 0x0B, 0x0A,
                0x11, 0x10, 0x0F, 0x0E
            ]
        )
    }

    func testInvalidPreviousHashLength() {
        XCTAssertThrowsError(
            try BitcoinHeader(
                version: 1,
                previousBlockHash: Data(repeating: 0, count: 31),
                merkleRoot: Data(repeating: 0, count: 32),
                timestamp: 1,
                bits: 1
            )
        )
    }

    func testInvalidMerkleRootLength() {
        XCTAssertThrowsError(
            try BitcoinHeader(
                version: 1,
                previousBlockHash: Data(repeating: 0, count: 32),
                merkleRoot: Data(repeating: 0, count: 31),
                timestamp: 1,
                bits: 1
            )
        )
    }

    func testDecodeHex() throws {
        let result = try BitcoinHeader.decodeHex("a1b2c3")

        XCTAssertEqual(
            result,
            Data([0xA1, 0xB2, 0xC3])
        )
    }

    func testInvalidHexIsRejected() {
        XCTAssertThrowsError(
            try BitcoinHeader.decodeHex("xyz123")
        )

        XCTAssertThrowsError(
            try BitcoinHeader.decodeHex("abc")
        )
    }
}
