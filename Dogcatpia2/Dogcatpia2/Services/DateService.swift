//
//  DateService.swift
//  Dogcatpia2
//
//  Centralized date formatting & date-math using SwiftDate.
//

import Foundation
import SwiftDate

enum DateService {
    /// Default region for the app.
    /// Uses the user's current calendar/locale/timezone.
    static var region: Region {
        Region(calendar: Foundation.Calendar.current,
               zone: Foundation.TimeZone.current,
               locale: Foundation.Locale.current)
    }

    // MARK: - System-like formatting (locale + 12/24h aware)

    /// Builds a locale-aware date format pattern from a template, similar to how
    /// system `.formatted(date:time:)` behaves.
    ///
    /// Example template: "yMdjm" (numeric date + short time, 12/24h depends on user settings).
    private static func systemLikeFormat(template: String) -> String {
        DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: region.locale)
            ?? "yyyy/MM/dd HH:mm"
    }

    /// Similar to: `date.formatted(date: .numeric, time: .shortened)`
    static func diaryListDisplay(_ date: Date) -> String {
        let pattern = systemLikeFormat(template: "yMdjm")
        return date.in(region: region).toFormat(pattern, locale: region.locale)
    }

    /// Similar to: `date.formatted(date: .abbreviated, time: .shortened)`
    /// (Abbreviated month/day + short time, localized.)
    static func reminderDisplay(_ date: Date) -> String {
        let pattern = systemLikeFormat(template: "MMMdjm")
        return date.in(region: region).toFormat(pattern, locale: region.locale)
    }

    /// Start of today in the user's region.
    static func startOfToday() -> Date {
        dateInRegionNow().dateAtStartOf(.day).date
    }

    static func dateInRegionNow() -> DateInRegion {
        DateInRegion(Date(), region: region)
    }
}
