import Foundation
import CryptoKit

public enum BitcoinHash {

    /// Performs Bitcoin's double SHA-256 operation.
    public static func sha256d(_ data: Data) -> Data {
        let firstHash = SHA256.hash(data: data)
        let secondHash = SHA256.hash(data: Data(firstHash))
        return Data(secondHash)
    }

    /// Returns the hash as a hexadecimal string.
    public static func hex(_ data: Data) -> String {
        sha256d(data)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
