
import Foundation

public enum ShareTargetError: Error {
    case invalidDifficulty
    case invalidTarget
}

public enum ShareTarget {

    private static let difficultyOneTarget =
        "00000000ffff0000000000000000000000000000000000000000000000000000"

    public static func calculate(
        difficulty: Double
    ) throws -> Data {

        guard difficulty.isFinite,
              difficulty > 0 else {
            throw ShareTargetError.invalidDifficulty
        }

        guard let base = decodeHex(difficultyOneTarget) else {
            throw ShareTargetError.invalidTarget
        }

        // Convert difficulty to a fixed-point integer.
        let scale: UInt64 = 1_000_000_000

        guard difficulty <= Double(UInt64.max) / Double(scale) else {
            throw ShareTargetError.invalidDifficulty
        }

        let divisor = UInt64(difficulty * Double(scale))

        guard divisor > 0 else {
            throw ShareTargetError.invalidDifficulty
        }

        var remainder: UInt64 = 0
        var output = [UInt8](repeating: 0, count: 32)

        for index in 0..<32 {
            let numerator =
                UInt64(base[index]) * scale + remainder

            output[index] = UInt8(numerator / divisor)
            remainder = numerator % divisor
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
