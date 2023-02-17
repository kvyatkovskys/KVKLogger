//
//  KVKLoggerView.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

public struct KVKLoggerView: View {
    private let persistenceContainer = KVKPersistenceСontroller.shared
    @Environment (\.scenePhase) private var scenePhase
    
    public init() {}
    
    public var body: some View {
        KVKLoggerProxyView()
            .environment(\.managedObjectContext, persistenceContainer.viewContext)
            .onChange(of: scenePhase) { (_) in
                persistenceContainer.viewContext.saveContext()
            }
    }
}

struct KVKLoggerProxyView: View {
    
    @Environment (\.managedObjectContext) private var viewContext
#if os(iOS)
    @Environment (\.dismiss) private var dismiss
#else
    @Environment (\.presentationMode) private var presentationMode
#endif
    @FetchRequest(fetchRequest: ItemLog.fecth(), animation: .default)
    //@SectionedFetchRequest(sectionIdentifier: \.status.rawValue, sortDescriptors: [SortDescriptor(\.createdAt, order: .reverse)])
    //private var sections: SectionedFetchResults<String, ItemLog>
    private var logs: FetchedResults<ItemLog>
    private var selectedLog: ItemLog?
    @ObservedObject private var vm = KVKLoggerVM()
    @State private var selectedClearBy = KVKSharedData.shared.clearBy
    
    var body: some View {
        navigationView
    }
    
    private var navigationView: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            return NavigationStack {
                bodyView
                    .navigationDestination(for: ItemLog.self) { (log) in
                        KVKLogNetworkDetailView(log: log)
                    }
            }
        } else {
#if os(macOS)
            return NavigationView {
                bodyView
            }
#else
            return NavigationView {
                bodyView
            }
            .navigationViewStyle(StackNavigationViewStyle())
#endif
        }
    }
    
    private var bodyView: some View {
        List {
            ForEach(logs) { (log) in
                if log.type == .network {
                    if #available(iOS 16.0, macOS 13.0, *) {
                        NavigationLink(value: log) {
                            getLogView(log)
                        }
                        .tint(.black)
                    } else {
                        NavigationLink {
                            KVKLogNetworkDetailView(log: log)
                        } label: {
                            getLogView(log)
                        }
                    }
                } else {
                    getLogView(log)
                }
            }
        }
        .listStyle(PlainListStyle())
#if os(iOS)
        .searchable(text: $vm.query,
                    placement: .navigationBarDrawer(displayMode: .always))
#endif
        .onChange(of: vm.query, perform: { (newValue) in
            if #available(iOS 15.0, macOS 12.0, *) {
                logs.nsPredicate = vm.getPredicatesByQuery(newValue)
            }
        })
        .navigationTitle("Console")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
#if os(iOS)
                    dismiss()
#else
                    presentationMode.dismiss()
#endif
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if #available(iOS 16.0, macOS 13.0, *) {
                    settingsMenu
                        .menuOrder(.fixed)
                } else {
                    settingsMenu
                }
                // in progress
//                Menu {
//                    ForEach(vm.getCurateItems()) { (item) in
//                        switch item.item {
//                        case .groupBy:
//                            Picker("\(item.item.title) \(vm.selectedGroupBy.title)",
//                                   selection: $vm.selectedGroupBy) {
//                                ForEach(item.subItems) { (subItem) in
//                                    Text(subItem.title)
//                                }
//                            }.pickerStyle(.menu)
//                        case .filterBy:
//                            Picker("\(item.item.title) \(vm.selectedFilterBy.title)",
//                                   selection: $vm.selectedFilterBy) {
//                                ForEach(item.subItems) { (subItem) in
//                                    Text(subItem.title)
//                                }
//                            }.pickerStyle(.menu)
//                        }
//                    }
//                    if vm.selectedFilterBy != .none || vm.selectedGroupBy != .none {
//                        Button("Reset", role: .destructive) {
//                            vm.selectedFilterBy = .none
//                        }
//                    }
//                } label: {
//                    Image(systemName: "line.3.horizontal.decrease.circle")
//                }
            }
#endif
        }
    }
    
    private var settingsMenu: some View {
        Menu {
            ForEach(vm.getSettingItems()) { (item) in
                switch item.item {
                case .clearBySchedule:
                    Menu {
                        Picker("", selection: $selectedClearBy) {
                            ForEach(item.subItems ?? []) { (subItem) in
                                Text(subItem.title)
                            }
                        }
                    } label: {
                        Text(item.item.title)
                    }
                case .clearAll:
                    if #available(iOS 15.0, macOS 12.0, *) {
                        Button(role: .destructive) {
                            KVKPersistenceСontroller.shared.deleteAll()
                        } label: {
                            Text(item.item.title)
                        }
                    } else {
                        Button {
                            KVKPersistenceСontroller.shared.deleteAll()
                        } label: {
                            Text(item.item.title)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "gear")
        }
    }
    
    @ViewBuilder
    private func getLogView(_ log: ItemLog) -> some View {
        HStack {
            if log.type == .common {
                Text(log.status.icon)
            } else {
                Image(systemName: "network")
                    .resizable()
                    .foregroundColor(.blue)
                    .frame(width: 20, height: 20)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(log.items)
                    .lineLimit(log.type == .network ? 10 : nil)
                if let details = log.details {
                    Text(details)
                }
                if log.type == .network {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 15, height: 15)
                        Text(log.size)
                    }
                }
                HStack {
                    Text(log.formattedCreatedAt)
                }
                .foregroundColor(.gray)
                .font(.subheadline)
            }
            Spacer()
        }
        .contextMenu {
            Button {
                vm.copyLog(log)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }

        }
    }
}

struct KVKLoggerView_Previews: PreviewProvider {
    static var previews: some View {
        let result = KVKPersistenceСontroller(inMemory: true)
        let viewContext = result.viewContext
        let newItem1 = ItemLog(context: viewContext)
        newItem1.createdAt = Date()
        newItem1.status = KVKStatus.info
        newItem1.logType = KVKLogType.debug
        newItem1.items = String(describing: "Test description log Test description log Test description log")
        let newItem2 = ItemLog(context: viewContext)
        newItem2.createdAt = Date()
        newItem2.status = KVKStatus.verbose
        newItem2.logType = KVKLogType.print
        newItem2.details = "\(#file)\n\(#function)\n\(#line)"
        newItem2.items = "Test description log Test description log Test description log"
        let newItem3 = ItemLog(context: viewContext)
        newItem3.createdAt = Date()
        newItem3.data = "Test response".data(using: .utf8)
        newItem3.type = ItemLogType.network
        newItem3.logType = KVKLogType.print
        newItem3.items = "Test description network Test description network Test description network"
        viewContext.saveContext()
        return Group {
            KVKLoggerProxyView()
            KVKLoggerProxyView()
                .preferredColorScheme(.dark)
        }
        .environment(\.managedObjectContext, viewContext)
    }
}
