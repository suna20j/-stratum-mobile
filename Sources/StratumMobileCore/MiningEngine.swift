
import Foundation

public final class MiningEngine {

    private let poolSession: StratumPoolSession

    public private(set) var isConnected = false
    public private(set) var receivedJobs = 0

    public var onStatus: ((String) -> Void)?
    public var onJobReceived: ((StratumJob) -> Void)?

    public init(
        workerName: String,
        password: String = "x"
    ) {
        poolSession = StratumPoolSession(
            workerName: workerName,
            password: password
        )

        poolSession.onStatus = { [weak self] status in
            self?.isConnected = status.contains("Verbunden")
                || status.contains("erfolgreich")

            self?.onStatus?(status)
        }

        poolSession.onJob = { [weak self] job in
            guard let self else { return }

            self.receivedJobs += 1
            self.onStatus?(
                "Mining-Auftrag empfangen: \(job.jobID)"
            )
            self.onJobReceived?(job)
        }
    }

    public func start() {
        onStatus?("Starte Verbindung zu Braiins Pool...")
        poolSession.connect()
    }

    public func stop() {
        poolSession.disconnect()
        isConnected = false
        onStatus?("Mining-Verbindung beendet")
    }
}
