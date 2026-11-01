import Foundation

public struct MiningBenchmarkResult {
    public let iterations: Int
    public let elapsedSeconds: Double
    public let hashesPerSecond: Double

    public init(
        iterations: Int,
        elapsedSeconds: Double,
        hashesPerSecond: Double
    ) {
        self.iterations = iterations
        self.elapsedSeconds = elapsedSeconds
        self.hashesPerSecond = hashesPerSecond
    }
}

public enum MiningBenchmark {

    public static func run(
        iterations: Int = 100_000
    ) -> MiningBenchmarkResult {

        let count = max(1, iterations)
        let start = Date()
        var checksum: UInt8 = 0

        for index in 0..<count {
            var number = UInt64(index).bigEndian

            let input = withUnsafeBytes(of: &number) {
                Data($0)
            }

            let hash = BitcoinHash.sha256d(input)
            checksum ^= hash.last ?? 0
        }

        let elapsed = max(
            Date().timeIntervalSince(start),
            0.000001
        )

        // Keep the computed result observable.
        _ = checksum

        return MiningBenchmarkResult(
            iterations: count,
            elapsedSeconds: elapsed,
            hashesPerSecond: Double(count) / elapsed
        )
    }
}
