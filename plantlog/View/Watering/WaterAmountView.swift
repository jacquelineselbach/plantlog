import SwiftUI
import SwiftData
import AVFoundation

struct WaterAmountView: View {
    @Binding var amountMl: Int?

    let onCancel: () -> Void
    let onSave: () -> Void

    @State private var sliderValue: Double = 250
    @State private var includeAmount: Bool = true

    private let range: ClosedRange<Double> = 0...2000
    private let step: Double = 50

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Save amount", isOn: $includeAmount)
                        .accessibilityLabel("Save watering amount")
                        .accessibilityHint(includeAmount ? "Watering amount will be saved" : "Watering amount will not be saved")

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Watering amount")
                            Spacer()
                            Text("\(Int(sliderValue)) ml")
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("Current watering amount")
                                .accessibilityValue("\(Int(sliderValue)) milliliters")
                        }

                        Slider(value: $sliderValue, in: range, step: step)
                            .disabled(!includeAmount)
                            .accessibilityLabel("Watering amount slider")
                            .accessibilityValue("\(Int(sliderValue)) milliliters")
                            .accessibilityAdjustableAction { direction in
                                switch direction {
                                case .increment:
                                    sliderValue = min(sliderValue + step, range.upperBound)
                                case .decrement:
                                    sliderValue = max(sliderValue - step, range.lowerBound)
                                default:
                                    break
                                }
                            }

                        HStack {
                            Text("\(Int(range.lowerBound)) ml")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                            Spacer()
                            Text("\(Int(range.upperBound)) ml")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityElement(children: .contain)
                } header: {
                    Text("Amount")
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .navigationTitle("Watering")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                        .accessibilityLabel("Cancel watering amount input")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        amountMl = includeAmount ? Int(sliderValue) : nil
                        onSave()
                    }
                    .accessibilityLabel("Save watering amount")
                    .disabled(!includeAmount && amountMl == nil)
                }
            }
            .onAppear {
                if let ml = amountMl {
                    includeAmount = true
                    sliderValue = Double(ml)
                } else {
                    includeAmount = false
                    sliderValue = 250
                }
            }
        }
    }
}
