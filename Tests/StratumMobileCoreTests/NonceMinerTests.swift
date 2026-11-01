
import Foundation

public struct NonceMiningResult {
    public let nonce: UInt32
    public let hash: Data
    public let hashesChecked: UInt64
}

public enum NonceMiner {

    public static func scan(
        header: BitcoinHeader,
        startingNonce: UInt32 = 0,
        count: UInt64 = 100_000,
        target: Data
    ) -> NonceMiningResult? {

        guard target.count == 32, count > 0 else {
            return nil
        }

        var workingHeader = header
        var checked: UInt64 = 0
        var nonce = startingNonce

        while checked < count {
            workingHeader.nonce = nonce

            let hash = workingHeader.hash()
            checked += 1

            if meetsTarget(hash: hash, target: target) {
                return NonceMiningResult(
                    nonce: nonce,
                    hash: hash,
                    hashesChecked: checked
                )
            }

            if nonce == UInt32.max {
                break
            }

            nonce += 1
        }

        return nil
    }

    public static func meetsTarget(
        hash: Data,
        target: Data
    ) -> Bool {

        guard hash.count == 32,
              target.count == 32 else {
            return false
        }

        for index in 0..<32 {
            let hashByte = hash[31 - index]
            let targetByte = target[index]

            if hashByte < targetByte {
                return true
            }

            if hashByte > targetByte {
                return false
            }
        }

        return true
    }
}
