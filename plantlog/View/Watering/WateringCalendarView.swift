import SwiftUI
import SwiftData
import AVFoundation

struct WateringCalendarView: View {
    let plant: PlantModel
    @Binding var selectedDay: DateComponents?

    @Environment(\.calendar) private var calendar
    @Environment(\.timeZone) private var timeZone

    private var selectedDate: Date? {
        guard let selectedDay else { return nil }
        var c = selectedDay
        c.calendar = calendar
        c.timeZone = timeZone
        return calendar.date(from: c)
    }

    private var eventsForSelectedDay: [WateringModel] {
        guard let selectedDate else { return [] }
        return plant.wateringHistory
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(spacing: 12) {
            WateringCalendarUIViewRepresentable(events: plant.wateringHistory, selectedDay: $selectedDay)
                .frame(maxWidth: .infinity)
                .frame(height: 500)
                .padding(.horizontal)
                .accessibilityLabel("Watering calendar")
                .accessibilityHint("Select a day to see watering details")

            if let selectedDate {
                List {
                    Section(selectedDate.formatted(date: .complete, time: .omitted)) {
                        if eventsForSelectedDay.isEmpty {
                            Text("No watering logged.")
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("No watering logged for this day")
                        } else {
                            ForEach(eventsForSelectedDay, id: \.persistentModelID) { event in
                                HStack {
                                    Text(event.date.formatted(date: .omitted, time: .shortened))
                                        .accessibilityLabel("Time")
                                    Spacer()
                                    Text(event.amountMl.map { "\($0) ml" } ?? "—")
                                        .foregroundStyle(.secondary)
                                        .accessibilityLabel("Amount")
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Watered on \(event.date.formatted(date: .long, time: .shortened))")
                                .accessibilityValue(event.amountMl.map { "\($0) milliliters" } ?? "Amount not specified")
                            }
                        }
                    }
                    .accessibilityAddTraits(.isHeader)
                }
                .accessibilityElement(children: .contain)
            } else {
                Text("Tap a day to see details.")
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
                    .accessibilityLabel("Tap a day on the calendar to see watering details")
            }
        }
    }
}
