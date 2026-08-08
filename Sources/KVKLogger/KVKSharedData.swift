//
//  KVKSharedData.swift
//
//
//  Created by Sergei Kviatkovskii on 2/2/23.
//

import Foundation

final class KVKSharedData: @unchecked Sendable {

    static let shared = KVKSharedData()

    private let defaults = UserDefaults.standard
    private let clearByKey = "clearBy"
    private let lastClearByDateKey = "clearByDate"
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        return f
    }()

    var isPreviewMode: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var clearBy: SettingSubItem {
        get {
            guard let item = defaults.string(forKey: clearByKey) else { return .everyWeek }
            return SettingSubItem(rawValue: item) ?? .everyWeek
        }
        set {
            // only update (and reset timer) when the value actually changes
            guard newValue.rawValue != defaults.string(forKey: clearByKey) else { return }
            defaults.set(newValue.rawValue, forKey: clearByKey)
            lastClearByDate = Date()
        }
    }

    var lastClearByDate: Date {
        get {
            guard let dt = defaults.string(forKey: lastClearByDateKey) else { return Date() }
            return dateFormatter.date(from: dt) ?? Date()
        }
        set {
            defaults.set(dateFormatter.string(from: newValue), forKey: lastClearByDateKey)
        }
    }

    /// Returns true when enough days have elapsed since the last clear to trigger auto-deletion.
    func needToDeleteOldRecords() -> Bool {
        let from = Calendar.current.startOfDay(for: lastClearByDate)
        let to = Calendar.current.startOfDay(for: Date())
        let days = Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
        switch clearBy {
        case .everyDay, .everyWeek, .everyMonth, .everyYear:
            return days >= clearBy.daysInLive
        case .none:
            return false
        }
    }

    private init() {
        if defaults.string(forKey: clearByKey) == nil {
            clearBy = .everyWeek
        }
    }

}
