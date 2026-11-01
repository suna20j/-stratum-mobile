import XCTest
@testable import StratumMobileCore

final class MiningBenchmarkTests: XCTestCase {

    func testBenchmarkRuns() {
        let result = MiningBenchmark.run(iterations: 100)

        XCTAssertEqual(result.iterations, 100)
        XCTAssertGreaterThan(result.elapsedSeconds, 0)
        XCTAssertGreaterThan(result.hashesPerSecond, 0)
    }

    func testBenchmarkCalculatesHashrate() {
        let result = MiningBenchmark.run(iterations: 200)

        let expected = Double(result.iterations)
            / result.elapsedSeconds

        XCTAssertEqual(
            result.hashesPerSecond,
            expected,
            accuracy: 0.001
        )
    }
}
