import Foundation

@MainActor
final class NotificationRouter: ObservableObject {
    
    static let shared = NotificationRouter()

    @Published var lastPlantID: UUID?
    
}
