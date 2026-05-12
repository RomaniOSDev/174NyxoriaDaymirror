//
//  CalendarDay.swift
//  174NyxoriaDaymirror
//

import Foundation

enum CalendarDay {
    static func dayKey(for date: Date = Date()) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    static func isoWeekIdentifier(for date: Date = Date()) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        let y = calendar.component(.yearForWeekOfYear, from: date)
        let w = calendar.component(.weekOfYear, from: date)
        return "\(y)-W\(w)"
    }

    static func lastSevenDayKeys(ending date: Date = Date()) -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return (0 ..< 7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: date)) else {
                return nil
            }
            return Self.dayKey(for: day)
        }.reversed()
    }

    static func playDatesInCurrentWeek(from stored: Set<String>, now: Date = Date()) -> Set<String> {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return []
        }
        return stored.filter { key in
            let parts = key.split(separator: "-").compactMap { Int($0) }
            guard parts.count == 3 else { return false }
            var dc = DateComponents()
            dc.year = parts[0]
            dc.month = parts[1]
            dc.day = parts[2]
            guard let d = calendar.date(from: dc) else { return false }
            return interval.contains(d)
        }
    }

    static func date(fromDayKey key: String) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var dc = DateComponents()
        dc.year = parts[0]
        dc.month = parts[1]
        dc.day = parts[2]
        return calendar.date(from: dc)
    }
}
