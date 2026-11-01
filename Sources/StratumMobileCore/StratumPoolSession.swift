
import Foundation

public final class StratumPoolSession {

    private let client: StratumClient
    private let workerName: String
    private let password: String

    private var nextID = 1
    private var buffer = ""

    public var onStatus: ((String) -> Void)?
    public var onMessage: ((String) -> Void)?

    public init(
        workerName: String,
        password: String = "anything123"
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
        send([
            "id": nextID,
            "method": "mining.subscribe",
            "params": ["StratumMobile/1.0"]
        ])

        nextID += 1

        send([
            "id": nextID,
            "method": "mining.authorize",
            "params": [workerName, password]
        ])

        nextID += 1
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

            if let data = line.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(
                   with: data
               ) as? [String: Any] {

                if let method = json["method"] as? String {
                    onStatus?("Pool-Nachricht: \(method)")
                }

                if let result = json["result"] as? Bool,
                   result == true {
                    onStatus?("Anmeldung erfolgreich")
                }

                if let error = json["error"],
                   !(error is NSNull) {
                    onStatus?("Pool hat eine Anfrage abgelehnt")
                }
            }
        }
    }

    public func disconnect() {
        client.disconnect()
        onStatus?("Getrennt")
    }
}
