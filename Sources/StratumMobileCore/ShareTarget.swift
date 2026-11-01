
import Foundation

public enum ShareTargetError: Error {
    case invalidDifficulty
    case invalidTarget
}

public enum ShareTarget {

    private static let difficultyOneTarget =
        "00000000ffff0000000000000000000000000000000000000000000000000000"

    private static let scale: UInt64 = 1_000_000_000

    public static func calculate(difficulty: Double) throws -> Data {

        guard difficulty.isFinite, difficulty > 0 else {
            throw ShareTargetError.invalidDifficulty
        }

        let scaled = difficulty * Double(scale)

        guard scaled.isFinite,
              scaled >= 1,
              scaled < Double(UInt64.max) else {
            throw ShareTargetError.invalidDifficulty
        }

        let divisor = UInt64(scaled)

        guard divisor > 0 else {
            throw ShareTargetError.invalidDifficulty
        }

        guard var bytes = decodeHex(difficultyOneTarget),
              bytes.count == 32 else {
            throw ShareTargetError.invalidTarget
        }

        // Multipliziere den 256-Bit-Zielwert mit der Skalierung.
        var carry: UInt64 = 0

        for index in stride(from: 31, through: 0, by: -1) {
            let value = UInt64(bytes[index]) * scale + carry
            bytes[index] = UInt8(value & 0xFF)
            carry = value >> 8
        }

        guard carry == 0 else {
            throw ShareTargetError.invalidTarget
        }

        // Teile den 256-Bit-Wert durch die Schwierigkeit.
        var remainder: UInt64 = 0
        var output = [UInt8](repeating: 0, count: 32)

        for index in 0..<32 {
            let high = remainder >> 56
            let low = (remainder << 8) | UInt64(bytes[index])

            let result = divisor.dividingFullWidth(
                (high: high, low: low)
            )

            guard result.quotient <= 255 else {
                throw ShareTargetError.invalidTarget
            }

            output[index] = UInt8(result.quotient)
            remainder = result.remainder
        }

        return Data(output)
    }

    private static func decodeHex(_ hex: String) -> Data? {
        guard hex.count == 64 else {
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
