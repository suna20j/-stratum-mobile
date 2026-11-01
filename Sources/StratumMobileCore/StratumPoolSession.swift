
import Foundation

public final class StratumPoolSession {

    private let client: StratumClient
    private let workerName: String
    private let password: String

    private let subscribeID = 1
    private let authorizeID = 2

    private var buffer = ""
    private var subscriptionSent = false
    private var authorized = false

    public private(set) var extraNonce1: String?
    public private(set) var extraNonce2Size: Int?
    public private(set) var difficulty: Double = 0

    public var onStatus: ((String) -> Void)?
    public var onMessage: ((String) -> Void)?
    public var onJob: ((StratumJob) -> Void)?
    public var onDifficulty: ((Double) -> Void)?

    public init(
        workerName: String,
        password: String = "x"
    ) {
        self.workerName = workerName
        self.password = password

        self.client = StratumClient(
            host: "stratum.braiins.com",
            port: 3333
        )

        self.client.onStateChange = { [weak self] status in
            self?.onStatus?(status)

            if status == "Verbunden" {
                self?.subscribe()
            }
        }

        self.client.onMessage = { [weak self] message in
            self?.process(message)
        }
    }

    public func connect() {
        onStatus?("Verbinde mit Braiins Pool...")
        client.connect()
    }

    private func subscribe() {
        guard !subscriptionSent else { return }
        subscriptionSent = true

        send([
            "id": subscribeID,
            "method": "mining.subscribe",
            "params": ["StratumMobile/1.0"]
        ])
    }

    private func authorize() {
        send([
            "id": authorizeID,
            "method": "mining.authorize",
            "params": [workerName, password]
        ])
    }

    private func send(_ message: [String: Any]) {
        guard
            let data = try? JSONSerialization.data(
                withJSONObject: message,
                options: [.sortedKeys]
            ),
            let json = String(data: data, encoding: .utf8)
        else {
            onStatus?("JSON-Fehler")
            return
        }

        client.send(json)
    }

    private func process(_ message: String) {
        buffer += message

        while let newline = buffer.firstIndex(of: "\n") {
            let line = String(buffer[..<newline])
            buffer.removeSubrange(...newline)

            guard !line.isEmpty else { continue }

            onMessage?(line)
            processLine(line)
        }
    }

    private func processLine(_ line: String) {
        guard
            let data = line.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        else {
            return
        }

        if let method = json["method"] as? String {
            processNotification(method, json: json, line: line)
        }

        if let id = json["id"] as? Int {
            processResponse(id, json: json)
        }
    }

    private func processResponse(
        _ id: Int,
        json: [String: Any]
    ) {
        if let error = json["error"],
           !(error is NSNull) {
            onStatus?("Pool-Fehler: \(error)")
            return
        }

        if id == subscribeID {
            guard
                let result = json["result"] as? [Any],
                result.count >= 3,
                let nonce1 = result[1] as? String,
                let nonce2Size = result[2] as? Int,
                nonce2Size > 0
            else {
                onStatus?("Ungültige Subscribe-Antwort")
                return
            }

            extraNonce1 = nonce1
            extraNonce2Size = nonce2Size

            onStatus?("Pool-Verbindung vorbereitet")

            authorize()
        }

        if id == authorizeID {
            let success = json["result"] as? Bool ?? false

            authorized = success

            onStatus?(
                success
                ? "Pool-Anmeldung erfolgreich"
                : "Pool-Anmeldung abgelehnt"
            )
        }
    }

    private func processNotification(
        _ method: String,
        json: [String: Any],
        line: String
    ) {
        guard let params = json["params"] as? [Any] else {
            return
        }

        switch method {
        case "mining.set_difficulty":
            guard
                let value = params.first as? NSNumber,
                value.doubleValue > 0
            else {
                return
            }

            difficulty = value.doubleValue
            onDifficulty?(difficulty)
            onStatus?("Pool-Difficulty: \(difficulty)")

        case "mining.notify":
            guard authorized else {
                onStatus?("Mining-Auftrag vor Anmeldung empfangen")
                return
            }

            if let job = StratumJob(jsonLine: line) {
                onJob?(job)
                onStatus?("Mining-Auftrag: \(job.jobID)")
            }

        default:
            onStatus?("Pool-Nachricht: \(method)")
        }
    }

    public func disconnect() {
        client.disconnect()

        buffer = ""
        authorized = false
        subscriptionSent = false

        extraNonce1 = nil
        extraNonce2Size = nil
        difficulty = 0

        onStatus?("Getrennt")
    }
}
