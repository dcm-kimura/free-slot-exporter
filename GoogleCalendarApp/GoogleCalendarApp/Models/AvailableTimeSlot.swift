import Foundation

struct AvailableTimeSlot: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    var exportText: String {
        return "\(formattedDate) \(formattedTime) (\(formattedDuration))"
    }
    
    var exportTextJapanese: String {
        // 日付フォーマッター（月日のみ）
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "M月d日"
        
        // 曜日フォーマッター
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "ja_JP")
        weekdayFormatter.dateFormat = "E"
        
        // 時間フォーマッター
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ja_JP")
        timeFormatter.dateFormat = "HH:mm"
        
        let dateText = dateFormatter.string(from: startTime)
        let weekdayText = weekdayFormatter.string(from: startTime)
        let startTimeText = timeFormatter.string(from: startTime)
        let endTimeText = timeFormatter.string(from: endTime)
        
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        var durationText = ""
        if hours > 0 && minutes > 0 {
            durationText = "\(hours)時間\(minutes)分"
        } else if hours > 0 {
            durationText = "\(hours)時間"
        } else {
            durationText = "\(minutes)分"
        }
        
        return "\(dateText)（\(weekdayText)） \(startTimeText)〜\(endTimeText)（\(durationText)）"
    }
}