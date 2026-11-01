
import SwiftUI
import CryptoKit
import Foundation

public struct MiningDashboard: View {
    @State private var isRunning = false
    @State private var hashRate = 0.0
    @State private var elapsed = 0.0
    @State private var totalHashes = 0
    @State private var status = "Bereit"

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(.orange)

                    Text("STRATUM MOBILE")
                        .font(.largeTitle.bold())

                    Text("Bitcoin SHA-256d Benchmark")
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        Text("HASHRATE")
                            .font(.headline)

                        Text(String(format: "%.2f H/s", hashRate))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    HStack {
                        statistic("Hashes", "\(totalHashes)")
                        statistic("Zeit", String(format: "%.1f s", elapsed))
                    }

                    Text(status)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        startBenchmark()
                    } label: {
                        Label(
                            isRunning ? "Läuft..." : "Benchmark starten",
                            systemImage: "play.fill"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(isRunning)

                    Text("Hinweis: Dies ist ein lokaler SHA-256d-Test. Keine Pool-Verbindung und keine echten Bitcoin-Erträge.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Mining Dashboard")
        }
    }

    private func statistic(_ title: String, _ value: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func startBenchmark() {
        guard !isRunning else { return }

        isRunning = true
        status = "Benchmark läuft..."
        hashRate = 0
        elapsed = 0
        totalHashes = 0

        Task {
            let result = await Task.detached(priority: .userInitiated) {
                let start = Date()
                let iterations = 10_000

                for i in 0..<iterations {
                    let input = Data("StratumMobile-\(i)".utf8)
                    let first = SHA256.hash(data: input)
                    _ = SHA256.hash(data: Data(first))
                }

                let duration = max(Date().timeIntervalSince(start), 0.001)
                return (iterations, duration)
            }.value

            hashRate = Double(result.0) / result.1
            elapsed = result.1
            totalHashes = result.0
            status = "Benchmark abgeschlossen"
            isRunning = false
        }
    }
}
