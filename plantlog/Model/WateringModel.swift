import SwiftUI
import SwiftData

@Model
class WateringModel {
    
    var date: Date
    var amountMl: Int?

    init(date: Date, amountMl: Int? = nil) {
        self.date = date
        self.amountMl = amountMl
        
    }
}
