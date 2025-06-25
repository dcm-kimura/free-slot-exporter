import Foundation

struct CalendarEvent: Identifiable {
    let id: String
    let summary: String
    let startTime: Date?
    let endTime: Date?
    let location: String?
    let description: String?
    let isAllDay: Bool
    
    var formattedTime: String {
        guard let start = startTime else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        if isAllDay {
            return "All day"
        } else if let end = endTime {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        } else {
            return formatter.string(from: start)
        }
    }
    
    var formattedDate: String {
        guard let start = startTime else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: start)
    }
}