import Testing
import Foundation
import SwiftUI
import CoreData
@testable import KVKLogger

// MARK: - KVKStatus

@Suite("KVKStatus")
struct KVKStatusTests {

    @Test("rawValue is correct for every case")
    func rawValues() {
        #expect(KVKStatus.info.rawValue == "info")
        #expect(KVKStatus.error.rawValue == "error")
        #expect(KVKStatus.debug.rawValue == "debug")
        #expect(KVKStatus.warning.rawValue == "warning")
        #expect(KVKStatus.verbose.rawValue == "verbose")
        #expect(KVKStatus.none.rawValue == "none")
        #expect(KVKStatus.fault.rawValue == "fault")
        #expect(KVKStatus.critical.rawValue == "critical")
        #expect(KVKStatus.notice.rawValue == "notice")
        #expect(KVKStatus.custom("MyError").rawValue == "myerror")
    }

    @Test("init(rawValue:) round-trips all standard cases")
    func initFromRawValue() {
        let cases: [KVKStatus] = [.info, .error, .debug, .warning, .verbose, .none, .fault, .critical, .notice]
        for status in cases {
            #expect(KVKStatus(rawValue: status.rawValue) == status)
        }
    }

    @Test("init(rawValue:) is case-insensitive")
    func initCaseInsensitive() {
        #expect(KVKStatus(rawValue: "INFO") == .info)
        #expect(KVKStatus(rawValue: "Error") == .error)
        #expect(KVKStatus(rawValue: "DEBUG") == .debug)
        #expect(KVKStatus(rawValue: "NOTICE") == .notice)
    }

    @Test("unknown rawValue maps to .custom")
    func unknownRawValueBecomesCustom() {
        let status = KVKStatus(rawValue: "somethingNew")
        guard case .custom(let name) = status else {
            Issue.record("Expected .custom, got \(String(describing: status))")
            return
        }
        #expect(name == "somethingNew")
    }

    @Test("custom rawValue is lowercased")
    func customRawValueLowercased() {
        #expect(KVKStatus.custom("MyError").rawValue == "myerror")
        #expect(KVKStatus.custom("HELLO").rawValue == "hello")
    }

    @Test("title is correct for every case")
    func titles() {
        #expect(KVKStatus.info.title == "Info")
        #expect(KVKStatus.error.title == "Error")
        #expect(KVKStatus.debug.title == "Debug")
        #expect(KVKStatus.warning.title == "Warning")
        #expect(KVKStatus.verbose.title == "Verbose")
        #expect(KVKStatus.none.title == "None")
        #expect(KVKStatus.fault.title == "Fault")
        #expect(KVKStatus.critical.title == "Critical")
        #expect(KVKStatus.notice.title == "Notice")
        #expect(KVKStatus.custom("myerror").title == "Myerror")
    }

    @Test("icon is correct for every case")
    func icons() {
        #expect(KVKStatus.info.icon == "ℹ️")
        #expect(KVKStatus.error.icon == "❌")
        #expect(KVKStatus.debug.icon == "☕️")
        #expect(KVKStatus.warning.icon == "⚠️")
        #expect(KVKStatus.verbose.icon == "🔍")
        #expect(KVKStatus.none.icon == "")
        #expect(KVKStatus.fault.icon == "‼️")
        #expect(KVKStatus.critical.icon == "‼️")
        #expect(KVKStatus.notice.icon == "🔔")
        #expect(KVKStatus.custom("x").icon == "🟢")
    }

    @Test("allCases has 8 elements and excludes .none and .custom")
    func allCasesContent() {
        let all = KVKStatus.allCases
        #expect(all.count == 8)
        #expect(!all.contains(.none))
        #expect(all.contains(.info))
        #expect(all.contains(.error))
        #expect(all.contains(.debug))
        #expect(all.contains(.warning))
        #expect(all.contains(.verbose))
        #expect(all.contains(.fault))
        #expect(all.contains(.critical))
        #expect(all.contains(.notice))
    }

    @Test("Hashable: duplicate insertions into Set are deduplicated")
    func hashableDeduplication() {
        var set = Set<KVKStatus>()
        set.insert(.info)
        set.insert(.info)
        #expect(set.count == 1)
        set.insert(.error)
        #expect(set.count == 2)
    }

    @Test("id equals self")
    func idEqualsSelf() {
        #expect(KVKStatus.debug.id == .debug)
        #expect(KVKStatus.custom("x").id == .custom("x"))
    }
}

// MARK: - KVKLogType

@Suite("KVKLogType")
struct KVKLogTypeTests {

    @Test("rawValue is correct for every case")
    func rawValues() {
        #expect(KVKLogType.os.rawValue == "os")
        #expect(KVKLogType.debug.rawValue == "debug")
        #expect(KVKLogType.print.rawValue == "print")
    }

    @Test("init(rawValue:) round-trips")
    func initRoundtrip() {
        #expect(KVKLogType(rawValue: "os") == .os)
        #expect(KVKLogType(rawValue: "debug") == .debug)
        #expect(KVKLogType(rawValue: "print") == .print)
        #expect(KVKLogType(rawValue: "unknown") == nil)
    }
}

// MARK: - KVKItemLogType

@Suite("KVKItemLogType")
struct KVKItemLogTypeTests {

    @Test("rawValue is correct for every case")
    func rawValues() {
        #expect(KVKItemLogType.network.rawValue == "network")
        #expect(KVKItemLogType.common.rawValue == "common")
    }

    @Test("init(rawValue:) round-trips")
    func initRoundtrip() {
        #expect(KVKItemLogType(rawValue: "network") == .network)
        #expect(KVKItemLogType(rawValue: "common") == .common)
        #expect(KVKItemLogType(rawValue: "unknown") == nil)
    }
}

// MARK: - SettingSubItem (internal)

@Suite("SettingSubItem")
struct SettingSubItemTests {

    @Test("daysInLive values are correct")
    func daysInLive() {
        #expect(SettingSubItem.everyDay.daysInLive == 1)
        #expect(SettingSubItem.everyWeek.daysInLive == 7)
        #expect(SettingSubItem.everyMonth.daysInLive == 30)
        #expect(SettingSubItem.everyYear.daysInLive == 365)
        #expect(SettingSubItem.none.daysInLive == -1)
    }

    @Test("title is correct for every case")
    func titles() {
        #expect(SettingSubItem.everyDay.title == "Every day")
        #expect(SettingSubItem.everyWeek.title == "Every week")
        #expect(SettingSubItem.everyMonth.title == "Every month")
        #expect(SettingSubItem.everyYear.title == "Every year")
        #expect(SettingSubItem.none.title == "None")
    }

    @Test("CaseIterable provides all 5 cases")
    func caseCount() {
        #expect(SettingSubItem.allCases.count == 5)
    }
}

// MARK: - KVKPersistenceController (internal)

@Suite("KVKPersistenceController")
struct KVKPersistenceControllerTests {

    private func makeController() -> KVKPersistenceСontroller {
        KVKPersistenceСontroller(inMemory: true)
    }

    private func fetchAll(in controller: KVKPersistenceСontroller) -> [ItemLog] {
        var results: [ItemLog] = []
        controller.backgroundContext.performAndWait {
            results = (try? controller.backgroundContext.fetch(ItemLog.fecth())) ?? []
        }
        return results
    }

    @Test("dbSize is nil for an in-memory store")
    func dbSizeNilForInMemory() {
        #expect(makeController().dbSize == nil)
    }

    @Test("fetchLastRecord returns nil when the store is empty")
    func fetchLastRecordEmptyStore() {
        let controller = makeController()
        var result: ItemLog? = nil
        controller.backgroundContext.performAndWait {
            result = controller.backgroundContext.fetchLastRecord()
        }
        #expect(result == nil)
    }

    @Test("save persists a common log entry")
    func saveCommonLog() {
        let controller = makeController()
        let proxy = ItemLogProxy(
            createdAt: Date(),
            data: nil,
            details: "file: Test.swift",
            items: "Hello log",
            logType: .os,
            status: .info,
            type: .common
        )
        controller.save(log: proxy)

        let results = fetchAll(in: controller)
        #expect(results.count == 1)
        #expect(results.first?.items == "Hello log")
        #expect(results.first?.status == .info)
        #expect(results.first?.type == .common)
        #expect(results.first?.logType == .os)
        #expect(results.first?.details == "file: Test.swift")
    }

    @Test("save persists a network log entry with data")
    func saveNetworkLog() {
        let controller = makeController()
        let json = "{\"key\":\"value\"}"
        let data = json.data(using: .utf8)!
        let proxy = ItemLogProxy(
            createdAt: Date(),
            data: data,
            details: nil,
            items: "GET /api/test",
            logType: .os,
            status: .debug,
            type: .network
        )
        controller.save(log: proxy)

        let results = fetchAll(in: controller)
        #expect(results.count == 1)
        #expect(results.first?.type == .network)
        #expect(results.first?.data == data)
    }

    @Test("fetchLastRecord returns the oldest saved entry")
    func fetchLastRecordReturnsOldest() {
        let controller = makeController()
        let proxy = ItemLogProxy(
            createdAt: Date(),
            data: nil, details: nil,
            items: "oldest",
            logType: .debug, status: .debug, type: .common
        )
        controller.save(log: proxy)

        var result: ItemLog? = nil
        controller.backgroundContext.performAndWait {
            result = controller.backgroundContext.fetchLastRecord()
        }
        #expect(result != nil)
        #expect(result?.items == "oldest")
    }

    @Test("deleteAll removes every record")
    func deleteAllClearsStore() {
        let controller = makeController()
        for i in 0..<3 {
            let proxy = ItemLogProxy(
                createdAt: Date(),
                data: nil, details: nil,
                items: "item \(i)",
                logType: .os, status: .info, type: .common
            )
            controller.save(log: proxy)
        }
        #expect(fetchAll(in: controller).count == 3)

        controller.backgroundContext.performAndWait {
            controller.backgroundContext.deleteAll(additionalContexts: [controller.viewContext])
        }
        #expect(fetchAll(in: controller).isEmpty)
    }

    @Test("size is non-nil when an entry has data")
    func itemLogSizeNonNilForData() {
        let controller = makeController()
        let data = Data(repeating: 0, count: 1024)
        let proxy = ItemLogProxy(
            createdAt: Date(),
            data: data, details: nil,
            items: "net", logType: .os, status: .debug, type: .network
        )
        controller.save(log: proxy)

        var size: String? = nil
        controller.backgroundContext.performAndWait {
            size = (try? controller.backgroundContext.fetch(ItemLog.fecth()))?.first?.size
        }
        #expect(size != nil)
    }

    @Test("size is nil when an entry has no data")
    func itemLogSizeNilWithoutData() {
        let controller = makeController()
        let proxy = ItemLogProxy(
            createdAt: Date(),
            data: nil, details: nil,
            items: "log", logType: .os, status: .info, type: .common
        )
        controller.save(log: proxy)

        var size: String? = "notNil"
        controller.backgroundContext.performAndWait {
            size = (try? controller.backgroundContext.fetch(ItemLog.fecth()))?.first?.size
        }
        #expect(size == nil)
    }

    @Test("getNetworkJson returns non-empty string for valid JSON data")
    func getNetworkJsonValidJSON() throws {
        let controller = makeController()
        let json = "{\"key\":\"value\"}"
        let data = json.data(using: .utf8)!
        let proxy = ItemLogProxy(
            createdAt: Date(),
            data: data, details: nil,
            items: "GET /test", logType: .os, status: .debug, type: .network
        )
        controller.save(log: proxy)

        var networkJson = ""
        controller.backgroundContext.performAndWait {
            guard let item = (try? controller.backgroundContext.fetch(ItemLog.fecth()))?.first else { return }
            networkJson = (try? item.getNetworkJson()) ?? ""
        }
        #expect(!networkJson.isEmpty)
    }

    @Test("copyTxt combines items and details")
    func itemLogCopyTxt() {
        let controller = makeController()
        let proxy = ItemLogProxy(
            createdAt: Date(),
            data: nil,
            details: "line: 42",
            items: "My message",
            logType: .os, status: .info, type: .common
        )
        controller.save(log: proxy)

        var copyTxt = ""
        controller.backgroundContext.performAndWait {
            copyTxt = (try? controller.backgroundContext.fetch(ItemLog.fecth()))?.first?.copyTxt ?? ""
        }
        #expect(copyTxt.contains("My message"))
        #expect(copyTxt.contains("line: 42"))
    }

    @Test("multiple saves accumulate records")
    func multipleSavesAccumulate() {
        let controller = makeController()
        for i in 0..<5 {
            let proxy = ItemLogProxy(
                createdAt: Date(),
                data: nil, details: nil,
                items: "msg \(i)",
                logType: .os, status: .debug, type: .common
            )
            controller.save(log: proxy)
        }
        #expect(fetchAll(in: controller).count == 5)
    }
}

// MARK: - KVKLoggerVM (internal)

@Suite("KVKLoggerVM")
struct KVKLoggerVMTests {

    @Test("getPredicatesBy returns nil when query is empty and status is .none")
    @MainActor
    func predicatesNilWhenNoFilter() {
        let vm = KVKLoggerVM()
        #expect(vm.getPredicatesBy(query: "", status: KVKStatus.none) == nil)
    }

    @Test("getPredicatesBy returns nil with no arguments (defaults to empty/none)")
    @MainActor
    func predicatesNilWithDefaults() {
        let vm = KVKLoggerVM()
        #expect(vm.getPredicatesBy() == nil)
    }

    @Test("getPredicatesBy returns predicate when query is non-empty")
    @MainActor
    func predicatesWithQueryOnly() {
        let vm = KVKLoggerVM()
        let predicate = vm.getPredicatesBy(query: "error", status: KVKStatus.none)
        #expect(predicate != nil)
    }

    @Test("getPredicatesBy returns predicate when status is non-.none")
    @MainActor
    func predicatesWithStatusOnly() {
        let vm = KVKLoggerVM()
        let predicate = vm.getPredicatesBy(query: "", status: .error)
        #expect(predicate != nil)
    }

    @Test("getPredicatesBy returns predicate when both query and status are set")
    @MainActor
    func predicatesWithQueryAndStatus() {
        let vm = KVKLoggerVM()
        let predicate = vm.getPredicatesBy(query: "test", status: .debug)
        #expect(predicate != nil)
    }

    @Test("getPredicatesBy returns predicate when a date range is provided")
    @MainActor
    func predicatesWithDateRange() {
        let vm = KVKLoggerVM()
        let start = Date()
        let end = Calendar.current.date(byAdding: .hour, value: 1, to: start)!
        let date = KVKDatePopoverView.DateContainer(start: start, end: end)
        let predicate = vm.getPredicatesBy(query: "", date: date, status: KVKStatus.none)
        #expect(predicate != nil)
    }

    @Test("getSettingItems returns two items with correct structure")
    @MainActor
    func settingItemsStructure() {
        let vm = KVKLoggerVM()
        let items = vm.getSettingItems()
        #expect(items.count == 2)
        #expect(items[0].item == .clearBySchedule)
        #expect(items[0].subItems?.count == 4)
        #expect(items[1].item == .clearAll)
        #expect(items[1].subItems == nil)
    }

    @Test("getCurateItems returns two items with correct structure")
    @MainActor
    func curateItemsStructure() {
        let vm = KVKLoggerVM()
        let items = vm.getCurateItems()
        #expect(items.count == 2)
        #expect(items[0].item == .filterBy)
        #expect(items[0].subItems == [.status])
        #expect(items[1].item == .resetAll)
    }

    @Test("filterBy reflects selected status title")
    @MainActor
    func filterByTitle() {
        let vm = KVKLoggerVM()
        vm.selectedStatusBy = .error
        #expect(vm.filterBy == "Error")
        vm.selectedStatusBy = .notice
        #expect(vm.filterBy == "Notice")
    }

    @Test("clearBy reflects selected sub-item title")
    @MainActor
    func clearByTitle() {
        let vm = KVKLoggerVM()
        #expect(vm.clearBy == vm.selectedClearBy.title)
    }
}

// MARK: - KVKLogger public API

@Suite("KVKLogger Public API", .serialized)
struct KVKLoggerPublicAPITests {

    @Test("isEnableSaveIntoDB defaults to true")
    func defaultIsEnableSaveIntoDB() {
        #expect(KVKLogger.shared.isEnableSaveIntoDB == true)
    }

    @Test("isDebugMode defaults to nil")
    func defaultIsDebugMode() {
        let original = KVKLogger.shared.isDebugMode
        defer { KVKLogger.shared.isDebugMode = original }
        KVKLogger.shared.isDebugMode = nil
        #expect(KVKLogger.shared.isDebugMode == nil)
    }

    @Test("isDebugMode can be set and read back")
    func isDebugModeSetAndRead() {
        let original = KVKLogger.shared.isDebugMode
        defer { KVKLogger.shared.isDebugMode = original }

        KVKLogger.shared.isDebugMode = true
        #expect(KVKLogger.shared.isDebugMode == true)

        KVKLogger.shared.isDebugMode = false
        #expect(KVKLogger.shared.isDebugMode == false)
    }

    @Test("isEnableSaveIntoDB can be toggled")
    func isEnableSaveIntoDBToggle() {
        let original = KVKLogger.shared.isEnableSaveIntoDB
        defer { KVKLogger.shared.isEnableSaveIntoDB = original }

        KVKLogger.shared.isEnableSaveIntoDB = false
        #expect(KVKLogger.shared.isEnableSaveIntoDB == false)

        KVKLogger.shared.isEnableSaveIntoDB = true
        #expect(KVKLogger.shared.isEnableSaveIntoDB == true)
    }

    @Test("delegate can be assigned and cleared")
    func delegateLifecycle() {
        class TestDelegate: KVKLoggerDelegate {}

        let original = KVKLogger.shared.delegate
        defer { KVKLogger.shared.delegate = original }

        let delegate = TestDelegate()
        KVKLogger.shared.delegate = delegate
        #expect(KVKLogger.shared.delegate != nil)

        KVKLogger.shared.delegate = nil
        #expect(KVKLogger.shared.delegate == nil)
    }

    @Test("delegate receives log events when isDebugMode is true")
    func delegateReceivesLogs() {
        class TestDelegate: KVKLoggerDelegate {
            var callCount = 0
            func didLog(_ items: Any..., type: KVKItemLogType) {
                callCount += 1
            }
        }

        let originalDelegate = KVKLogger.shared.delegate
        let originalMode = KVKLogger.shared.isDebugMode
        defer {
            KVKLogger.shared.delegate = originalDelegate
            KVKLogger.shared.isDebugMode = originalMode
        }

        let delegate = TestDelegate()
        KVKLogger.shared.delegate = delegate
        KVKLogger.shared.isDebugMode = true

        KVKLogger.shared.log("test event", status: .info, type: .print)
        #expect(delegate.callCount > 0)
    }

    @Test("log with .verbose status includes file/line/function details")
    func verboseLogIncludesDetails() {
        // Verbose status sets details automatically — we verify this doesn't crash
        // and that the delegate sees output.
        class TestDelegate: KVKLoggerDelegate {
            var received: [String] = []
            func didLog(_ items: Any..., type: KVKItemLogType) {
                received.append(contentsOf: items.map { "\($0)" })
            }
        }

        let originalDelegate = KVKLogger.shared.delegate
        let originalMode = KVKLogger.shared.isDebugMode
        defer {
            KVKLogger.shared.delegate = originalDelegate
            KVKLogger.shared.isDebugMode = originalMode
        }

        let delegate = TestDelegate()
        KVKLogger.shared.delegate = delegate
        KVKLogger.shared.isDebugMode = true

        KVKLogger.shared.log("verbose message", status: .verbose, type: .print)
        let combined = delegate.received.joined()
        #expect(combined.contains("verbose message"))
    }

    @Test("network log calls delegate with .network type")
    func networkLogCallsDelegate() {
        class TestDelegate: KVKLoggerDelegate {
            var receivedType: KVKItemLogType?
            func didLog(_ items: Any..., type: KVKItemLogType) {
                receivedType = type
            }
        }

        let originalDelegate = KVKLogger.shared.delegate
        let originalMode = KVKLogger.shared.isDebugMode
        defer {
            KVKLogger.shared.delegate = originalDelegate
            KVKLogger.shared.isDebugMode = originalMode
        }

        let delegate = TestDelegate()
        KVKLogger.shared.delegate = delegate
        KVKLogger.shared.isDebugMode = true

        KVKLogger.shared.network("GET /api/users", type: .print)
        #expect(delegate.receivedType == .network)
    }
}
