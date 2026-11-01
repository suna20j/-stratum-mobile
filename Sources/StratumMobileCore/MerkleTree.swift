
import Foundation

public enum MerkleTreeError: Error {
    case invalidHashLength
    case invalidHex
}

public enum MerkleTree {

    public static func calculateRoot(
        coinbaseHash: Data,
        branches: [Data]
    ) throws -> Data {

        guard coinbaseHash.count == 32 else {
            throw MerkleTreeError.invalidHashLength
        }

        // Stratum überträgt Hashes in umgekehrter Byte-Reihenfolge.
        var root = Data(coinbaseHash.reversed())

        for branch in branches {
            guard branch.count == 32 else {
                throw MerkleTreeError.invalidHashLength
            }

            let reversedBranch = Data(branch.reversed())

            var combined = Data()
            combined.append(root)
            combined.append(reversedBranch)

            root = BitcoinHash.sha256d(combined)
        }

        return Data(root.reversed())
    }

    public static func calculateRoot(
        coinbaseHashHex: String,
        branchHex: [String]
    ) throws -> Data {

        guard let coinbaseHash = decodeHex(coinbaseHashHex) else {
            throw MerkleTreeError.invalidHex
        }

        let branches = try branchHex.map { hex -> Data in
            guard let data = decodeHex(hex) else {
                throw MerkleTreeError.invalidHex
            }

            return data
        }

        return try calculateRoot(
            coinbaseHash: coinbaseHash,
            branches: branches
        )
    }

    private static func decodeHex(_ hex: String) -> Data? {
        let value = hex.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard value.count % 2 == 0 else {
            return nil
        }

        var result = Data()
        var index = value.startIndex

        while index < value.endIndex {
            let next = value.index(index, offsetBy: 2)

            guard let byte = UInt8(
                value[index..<next],
                radix: 16
            ) else {
                return nil
            }

            result.append(byte)
            index = next
        }

        return result
    }
}
