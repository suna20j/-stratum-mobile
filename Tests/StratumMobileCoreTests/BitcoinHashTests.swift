import XCTest
@testable import StratumMobileCore

final class BitcoinHashTests: XCTestCase {

    func testDoubleSHA256EmptyData() {
        let result = BitcoinHash.sha256d(Data())

        let hex = result
            .map { String(format: "%02x", $0) }
            .joined()

        XCTAssertEqual(
            hex,
            "5df6e0e2761359d30a8275058e299fcc0381534545f55cf43e41983f5d4c9456"
        )
    }

    func testDoubleSHA256Is32Bytes() {
        let result = BitcoinHash.sha256d(Data("Bitcoin".utf8))
        XCTAssertEqual(result.count, 32)
    }
}
