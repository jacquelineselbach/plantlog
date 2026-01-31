import SwiftUI
import SwiftData
import AVFoundation

struct WateringCalendarUIViewRepresentable: UIViewRepresentable {
    let events: [WateringModel]
    @Binding var selectedDay: DateComponents?

    @Environment(\.calendar) private var calendar
    @Environment(\.timeZone) private var timeZone

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = calendar
        view.locale = .current
        view.timeZone = timeZone
        view.delegate = context.coordinator

        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = selection
        view.isAccessibilityElement = true
        view.accessibilityLabel = "Watering calendar"
        view.accessibilityHint = "Shows days with watering events. Swipe to select a date."

        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.parent = self
        uiView.reloadDecorations(forDateComponents: context.coordinator.eventDays, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: WateringCalendarUIViewRepresentable

        init(parent: WateringCalendarUIViewRepresentable) {
            self.parent = parent
        }

        var eventDays: [DateComponents] {
            let cal = parent.calendar
            let tz = parent.timeZone
            let comps = parent.events.map { e -> DateComponents in
                var dc = cal.dateComponents(in: tz, from: e.date)
                dc.hour = nil; dc.minute = nil; dc.second = nil; dc.nanosecond = nil
                dc.calendar = cal
                dc.timeZone = tz
                return dc
            }
            return Array(Set(comps.map { Key($0) })).map { $0.components }
        }

        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            if containsEventDay(dateComponents) {
                return .default()
            }
            return nil
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           didSelectDate dateComponents: DateComponents?) {
            parent.selectedDay = dateComponents

            if let dc = dateComponents,
               let date = parent.calendar.date(from: dc) {
                let formatter = DateFormatter()
                formatter.dateStyle = .full
                let announcement = "Selected date: \(formatter.string(from: date))"
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }
        }

        private func containsEventDay(_ dc: DateComponents) -> Bool {
            let cal = parent.calendar
            let tz = parent.timeZone
            var needle = dc
            needle.calendar = cal
            needle.timeZone = tz
            needle.hour = nil; needle.minute = nil; needle.second = nil; needle.nanosecond = nil
            return eventDays.contains { sameDay($0, needle) }
        }

        private func sameDay(_ a: DateComponents, _ b: DateComponents) -> Bool {
            a.era == b.era && a.year == b.year && a.month == b.month && a.day == b.day
        }

        struct Key: Hashable {
            let era: Int?
            let year: Int?
            let month: Int?
            let day: Int?
            let components: DateComponents

            init(_ dc: DateComponents) {
                self.era = dc.era
                self.year = dc.year
                self.month = dc.month
                self.day = dc.day
                var c = dc
                c.hour = nil; c.minute = nil; c.second = nil; c.nanosecond = nil
                self.components = c
            }
        }
    }
}
