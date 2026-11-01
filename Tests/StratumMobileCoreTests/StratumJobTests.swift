
import XCTest
@testable import StratumMobileCore

final class StratumJobTests: XCTestCase {

    func testValidMiningNotify() {
        let json = """
        {
          "id": null,
          "method": "mining.notify",
          "params": [
            "job123",
            "0000000000000000000000000000000000000000000000000000000000000000",
            "01020304",
            "05060708",
            [],
            "20000000",
            "1d00ffff",
            "65a00000",
            true
          ]
        }
        """

        let job = StratumJob(jsonLine: json)

        XCTAssertNotNil(job)
        XCTAssertEqual(job?.jobID, "job123")
        XCTAssertEqual(job?.version, "20000000")
        XCTAssertTrue(job?.cleanJobs ?? false)
    }

    func testInvalidMethodIsRejected() {
        let json = """
        {
          "id": null,
          "method": "mining.ping",
          "params": []
        }
        """

        XCTAssertNil(StratumJob(jsonLine: json))
    }

    func testInvalidJobIsRejected() {
        let json = """
        {
          "method": "mining.notify",
          "params": ["job123"]
        }
        """

        XCTAssertNil(StratumJob(jsonLine: json))
    }
}
