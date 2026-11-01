
import Foundation

public enum CoinbaseBuilderError: Error {
    case invalidHex
    case invalidExtranonceSize
}

public enum CoinbaseBuilder {

    public static func build(
        coinbasePart1: String,
        extraNonce1: String,
        extraNonce2: String,
        coinbasePart2: String,
        extraNonce2Size: Int
    ) throws -> Data {

        guard extraNonce2Size >= 0,
              extraNonce2.count == extraNonce2Size * 2 else {
            throw CoinbaseBuilderError.invalidExtranonceSize
        }

        let completeHex =
            coinbasePart1 +
            extraNonce1 +
            extraNonce2 +
            coinbasePart2

        guard let transaction = decodeHex(completeHex) else {
            throw CoinbaseBuilderError.invalidHex
        }

        return transaction
    }

    public static func transactionHash(
        transaction: Data
    ) -> Data {
        BitcoinHash.sha256d(transaction)
    }

    private static func decodeHex(_ hex: String) -> Data? {
        guard hex.count % 2 == 0 else {
            return nil
        }

        var result = Data()
        var index = hex.startIndex

        while index < hex.endIndex {
            let next = hex.index(index, offsetBy: 2)

            guard let byte = UInt8(
                hex[index..<next],
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
