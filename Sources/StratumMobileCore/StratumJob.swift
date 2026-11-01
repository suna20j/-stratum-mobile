
import Foundation

public struct StratumJob {
    public let jobID: String
    public let previousHash: String
    public let coinbasePart1: String
    public let coinbasePart2: String
    public let merkleBranches: [String]
    public let version: String
    public let bits: String
    public let timestamp: String
    public let cleanJobs: Bool

    public init?(jsonLine: String) {
        guard
            let data = jsonLine.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any],
            json["method"] as? String == "mining.notify",
            let params = json["params"] as? [Any],
            params.count >= 9,
            let jobID = params[0] as? String,
            let previousHash = params[1] as? String,
            let coinbasePart1 = params[2] as? String,
            let coinbasePart2 = params[3] as? String,
            let branches = params[4] as? [String],
            let version = params[5] as? String,
            let bits = params[6] as? String,
            let timestamp = params[7] as? String,
            let cleanJobs = params[8] as? Bool
        else {
            return nil
        }

        self.jobID = jobID
        self.previousHash = previousHash
        self.coinbasePart1 = coinbasePart1
        self.coinbasePart2 = coinbasePart2
        self.merkleBranches = branches
        self.version = version
        self.bits = bits
        self.timestamp = timestamp
        self.cleanJobs = cleanJobs
    }
}
