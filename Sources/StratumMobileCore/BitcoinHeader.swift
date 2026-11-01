
import Foundation

public enum BitcoinHeaderError: Error {
    case invalidHex
    case invalidFieldLength
}

public struct BitcoinHeader {

    public let version: UInt32
    public let previousBlockHash: Data
    public let merkleRoot: Data
    public let timestamp: UInt32
    public let bits: UInt32
    public var nonce: UInt32

    public init(
        version: UInt32,
        previousBlockHash: Data,
        merkleRoot: Data,
        timestamp: UInt32,
        bits: UInt32,
        nonce: UInt32 = 0
    ) throws {

        guard previousBlockHash.count == 32,
              merkleRoot.count == 32 else {
            throw BitcoinHeaderError.invalidFieldLength
        }

        self.version = version
        self.previousBlockHash = previousBlockHash
        self.merkleRoot = merkleRoot
        self.timestamp = timestamp
        self.bits = bits
        self.nonce = nonce
    }

    /// Builds a header from the hexadecimal fields received
    /// in a Stratum mining.notify message.
    public init(
        stratumVersion: String,
        stratumPreviousHash: String,
        merkleRoot: Data,
        stratumTimestamp: String,
        stratumBits: String,
        nonce: UInt32 = 0
    ) throws {

        guard
            let version = UInt32(stratumVersion, radix: 16),
            let timestamp = UInt32(stratumTimestamp, radix: 16),
            let bits = UInt32(stratumBits, radix: 16)
        else {
            throw BitcoinHeaderError.invalidHex
        }

        let previousHash = try Self.decodeHex(stratumPreviousHash)

        guard previousHash.count == 32 else {
            throw BitcoinHeaderError.invalidFieldLength
        }

        try self.init(
            version: version,
            previousBlockHash: Self.reverseBytes(previousHash),
            merkleRoot: merkleRoot,
            timestamp: timestamp,
            bits: bits,
            nonce: nonce
        )
    }

    public func serialize() -> Data {
        var data = Data()

        appendLittleEndian(version, to: &data)
        data.append(previousBlockHash)
        data.append(merkleRoot)
        appendLittleEndian(timestamp, to: &data)
        appendLittleEndian(bits, to: &data)
        appendLittleEndian(nonce, to: &data)

        return data
    }

    public func hash() -> Data {
        BitcoinHash.sha256d(serialize())
    }

    private func appendLittleEndian(
        _ value: UInt32,
        to data: inout Data
    ) {
        var littleEndianValue = value.littleEndian

        withUnsafeBytes(of: &littleEndianValue) {
            data.append(contentsOf: $0)
        }
    }

    public static func reverseBytes(_ data: Data) -> Data {
        Data(data.reversed())
    }

    public static func decodeHex(_ hex: String) throws -> Data {
        let cleanHex = hex.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard cleanHex.count % 2 == 0 else {
            throw BitcoinHeaderError.invalidHex
        }

        var result = Data()
        var index = cleanHex.startIndex

        while index < cleanHex.endIndex {
            let nextIndex = cleanHex.index(
                index,
                offsetBy: 2
            )

            guard let byte = UInt8(
                cleanHex[index..<nextIndex],
                radix: 16
            ) else {
                throw BitcoinHeaderError.invalidHex
            }

            result.append(byte)
            index = nextIndex
        }

        return result
    }
}
