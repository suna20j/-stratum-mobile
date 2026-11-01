import Foundation
import CryptoKit

public enum BitcoinHash {

    /// Bitcoin double SHA-256.
    public static func sha256d(_ data: Data) -> Data {
        let firstHash = SHA256.hash(data: data)
        let secondHash = SHA256.hash(data: Data(firstHash))
        return Data(secondHash)
    }

    /// Converts bytes to a hexadecimal string without hashing.
    public static func toHex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    /// Double SHA-256, returned as hexadecimal.
    public static func hashHex(_ data: Data) -> String {
        toHex(sha256d(data))
    }
}
