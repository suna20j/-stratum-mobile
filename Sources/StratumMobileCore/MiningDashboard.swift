
import SwiftUI
import Foundation

public struct MiningDashboard: View {
    @State private var isRunning = false
    @State private var hashRate = 0.0
    @State private var elapsed = 0.0
    @State private var totalHashes = 0

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("STRATUM MOBILE")
                    .font(.largeTitle.bold())

                Text("Bitcoin SHA-256d Benchmark")
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    Text("HASHRATE")
                        .font(.headline)

                    Text(
                        hashRate.formatted(
                            .number.precision(.fractionLength(0))
                        ) + " H/s"
                    )
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.green)

                    Text("Lokale Rechenleistung")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.gray.opacity(0.12))
                .cornerRadius(18)

                HStack(spacing: 12) {
                    statCard(
                        title: "Laufzeit",
                        value: String(format: "%.2f s", elapsed)
                    )

                    statCard(
                        title: "Hashes",
                        value: "\(totalHashes)"
                    )
                }

                Button {
                    startBenchmark()
                } label: {
                    Text(isRunning ? "Läuft..." : "Benchmark starten")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRunning)

                Button("Stopp") {
                    isRunning = false
                }
                .disabled(!isRunning)

                Text("Nur lokaler Benchmark. Kein Pool-Mining und keine BTC-Einnahmen.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }

    private func statCard(
        title: String,
        value: String
    ) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)

            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.gray.opacity(0.12))
        .cornerRadius(14)
    }

    private func startBenchmark() {
        guard !isRunning else { return }

        isRunning = true
        hashRate = 0
        elapsed = 0
        totalHashes = 0

        DispatchQueue.global(qos: .userInitiated).async {
            let result = MiningBenchmark.run(
                iterations: 100_000
            )

            DispatchQueue.main.async {
                guard isRunning else { return }

                hashRate = result.hashesPerSecond
                elapsed = result.elapsedSeconds
                totalHashes = result.iterations
                isRunning = false
            }
        }
    }
}
