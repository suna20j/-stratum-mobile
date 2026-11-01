
import SwiftUI
import CryptoKit
import Foundation

@main
struct StratumMobileApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var isRunning = false
    @State private var hashesPerSecond = 0.0
    @State private var totalHashes = 0
    @State private var status = "Bereit"
    @State private var lastResult = "Noch kein Test"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 65))
                            .foregroundStyle(.orange)

                        Text("STRATUM MOBILE")
                            .font(.largeTitle.bold())

                        Text("Bitcoin Mining Research")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 25)

                    VStack(spacing: 12) {
                        Text("Hashrate")
                            .foregroundStyle(.secondary)

                        Text("\(hashesPerSecond, specifier: "%.2f")")
                            .font(.system(size: 38, weight: .bold))

                        Text("Hashes pro Sekunde")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    HStack {
                        Label("Status", systemImage: "circle.fill")
                        Spacer()
                        Text(status)
                            .foregroundStyle(isRunning ? .orange : .secondary)
                    }
                    .padding()

                    HStack {
                        Text("Berechnete Hashes")
                        Spacer()
                        Text("\(totalHashes)")
                            .monospacedDigit()
                    }
                    .padding()

                    Button {
                        runBenchmark()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text(isRunning ? "Test läuft ..." : "Benchmark starten")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRunning ? Color.gray : Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isRunning)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Letztes Ergebnis")
                            .font(.headline)

                        Text(lastResult)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Text("Wichtig: Dieser Benchmark testet nur lokale SHA-256d-Berechnungen. Er verbindet sich nicht mit einem Mining-Pool und erzeugt keine Bitcoins.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    private func runBenchmark() {
        isRunning = true
        status = "Benchmark läuft"

        Task.detached(priority: .userInitiated) {
            let iterations = 10_000
            let start = Date()

            var value = Data("Stratum Mobile".utf8)

            for _ in 0..<iterations {
                let firstHash = SHA256.hash(data: value)
                let secondHash = SHA256.hash(data: Data(firstHash))
                value = Data(secondHash)
            }

            let duration = Date().timeIntervalSince(start)
            let speed = Double(iterations) / max(duration, 0.001)

            await MainActor.run {
                hashesPerSecond = speed
                totalHashes += iterations
                lastResult = "\(iterations) Hashes in \(String(format: "%.2f", duration)) Sekunden"
                status = "Benchmark abgeschlossen"
                isRunning = false
            }
        }
    }
}
