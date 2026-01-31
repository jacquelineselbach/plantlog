import SwiftUI
import SwiftData

@Model
class PlantModel {
    
    var id: UUID = UUID()
    var name: String
    var species: String
    var scheduleTypeRaw: String
    var wateringIntervalDays: Int
    var startDate: Date
    var weekday: Int?
    var imageData: Data?
    var wateringTime: Date

    @Relationship(deleteRule: .cascade)
    var wateringHistory: [WateringModel] = []

    var scheduleType: WateringScheduleType {
        get { WateringScheduleType(rawValue: scheduleTypeRaw) ?? .interval }
        set { scheduleTypeRaw = newValue.rawValue }
    }

    var uiImage: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }

    init(
        name: String = "",
        species: String = "",
        scheduleType: WateringScheduleType = .interval,
        wateringIntervalDays: Int = 7,
        startDate: Date = .now,
        weekday: Int? = nil,
        imageData: Data? = nil,
        wateringTime: Date = Calendar.current.date(
            bySettingHour: 9, minute: 0, second: 0, of: .now
        ) ?? .now
    ) {
        self.name = name
        self.species = species
        self.scheduleTypeRaw = scheduleType.rawValue
        self.wateringIntervalDays = wateringIntervalDays
        self.startDate = startDate
        self.weekday = weekday
        self.imageData = imageData
        self.wateringTime = wateringTime
    }
}

extension PlantModel {
    func nextWateringDate(from reference: Date = .now) -> Date {
        let cal = Calendar.current
        let timeComponents = cal.dateComponents([.hour, .minute], from: wateringTime)

        switch scheduleType {
        case .interval:
            var date = cal.date(
                bySettingHour: timeComponents.hour ?? 9,
                minute: timeComponents.minute ?? 0,
                second: 0,
                of: startDate
            ) ?? startDate

            while date <= reference {
                date = cal.date(byAdding: .day, value: wateringIntervalDays, to: date) ?? date
            }
            return date

        case .weekday:
            guard let weekday else { return reference }
            var components = DateComponents()
            components.weekday = weekday
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute

            let next = cal.nextDate(
                after: reference,
                matching: components,
                matchingPolicy: .nextTime
            ) ?? reference

            return next
        }
    }
}

enum WateringScheduleType: String, CaseIterable, Identifiable, Codable {
    case interval = "interval"
    case weekday  = "weekday"
    var id: String { rawValue }
}
