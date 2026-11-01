
import Foundation
import Network

public final class StratumClient {

    private let host: NWEndpoint.Host
    private let port: NWEndpoint.Port
    private var connection: NWConnection?

    private let queue = DispatchQueue(
        label: "StratumMobile.StratumClient"
    )

    public var onMessage: ((String) -> Void)?
    public var onStateChange: ((String) -> Void)?

    public init(host: String, port: UInt16 = 3333) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!
    }

    public func connect() {
        disconnect()

        let newConnection = NWConnection(
            host: host,
            port: port,
            using: .tcp
        )

        connection = newConnection

        newConnection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.onStateChange?("Verbunden")
                self?.receive(from: newConnection)

            case .failed(let error):
                self?.onStateChange?(
                    "Verbindungsfehler: \(error.localizedDescription)"
                )

            case .cancelled:
                self?.onStateChange?("Getrennt")

            default:
                break
            }
        }

        newConnection.start(queue: queue)
    }

    public func send(_ message: String) {
        guard let connection else {
            onStateChange?("Sendefehler: Keine Verbindung")
            return
        }

        let data = Data((message + "\n").utf8)

        connection.send(
            content: data,
            completion: .contentProcessed { [weak self] error in
                if let error {
                    self?.onStateChange?(
                        "Sendefehler: \(error.localizedDescription)"
                    )
                }
            }
        )
    }

    private func receive(from connection: NWConnection) {
        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: 4096
        ) { [weak self] data, _, isComplete, error in

            guard let self else { return }

            if let data,
               !data.isEmpty,
               let text = String(data: data, encoding: .utf8) {
                self.onMessage?(text)
            }

            if let error {
                self.onStateChange?(
                    "Empfangsfehler: \(error.localizedDescription)"
                )
            } else if isComplete {
                self.onStateChange?("Verbindung geschlossen")
            } else {
                self.receive(from: connection)
            }
        }
    }

    public func disconnect() {
        connection?.stateUpdateHandler = nil
        connection?.cancel()
        connection = nil
    }
}
