//
//  KVKLoggerView.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

public struct KVKLoggerView: View {
    private let persistenceContainer = KVKLogger.shared.store
    
    public init() {}
    
    public var body: some View {
        KVKLoggerProxyView()
            .environment(\.managedObjectContext, persistenceContainer.viewContext)
    }
}

struct KVKLoggerProxyView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @FetchRequest(fetchRequest: ItemLog.request, animation: .none) private var logs: FetchedResults<ItemLog>
    @StateObject private var vm = KVKLoggerVM()
    
    var body: some View {
        navigationView
            .onAppear {
                vm.checkDBSize()
            }
#if os(iOS)
            .searchable(text: $vm.query,
                        placement: .navigationBarDrawer(displayMode: .always))
#else
            .searchable(text: $vm.query)
#endif
            .onSubmit(of: .search, {
                logs.nsPredicate = vm.getPredicatesBy(query: vm.query)
            })
            .onChange(of: vm.query) { (newValue) in
                logs.nsPredicate = vm.getPredicatesBy(query: newValue)
            }
            .onChange(of: vm.selectedDate) { (newValue) in
                logs.nsPredicate = vm.getPredicatesBy(date: newValue)
            }
            .onChange(of: vm.selectedStatusBy) { (newValue) in
                logs.nsPredicate = vm.getPredicatesBy(status: newValue)
            }
    }
    
    private var navigationView: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            return NavigationStack {
                bodyView
#if os(iOS)
                    .toolbarBackground(.regularMaterial, for: .navigationBar)
#endif
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
            .navigationViewStyle(.stack)
#endif
        }
    }
    
    @ViewBuilder
    private var bodyProxyView: some View {
        if logs.isEmpty {
            VStack {
                Spacer()
                Text("No Logs")
                    .font(.largeTitle)
                Spacer()
            }
        } else {
            List(logs) { (log) in
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
            .listStyle(.plain)
        }
    }
    
    private var navBarPosition: ToolbarItemPlacement {
#if os(iOS)
        .navigationBarTrailing
#else
        .navigation
#endif
    }
    
    private var bodyView: some View {
        bodyProxyView
            .navigationTitle("Console")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
                ToolbarItemGroup(placement: navBarPosition) {
                    Button {
                        vm.isDatePopoverPresented = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .popover(isPresented: $vm.isDatePopoverPresented) {
#if os(iOS)
                        if #available(iOS 16.0, *) {
                            KVKDatePopoverView(date: $vm.selectedDate)
                                .presentationDetents([.fraction(0.3)])
                                .presentationDragIndicator(.visible)
                        } else {
                            KVKDatePopoverView(date: $vm.selectedDate)
                        }
#else
                        KVKDatePopoverView(date: $vm.selectedDate)
#endif
                    }
                    if #available(iOS 16.0, macOS 13.0, *) {
                        settingsMenu
                            .menuOrder(.fixed)
                    } else {
                        settingsMenu
                    }
                }
            }
    }
    
    private var settingsMenu: some View {
        Menu {
            filtersMenu
            Divider()
            if let txt = vm.sizeOfDB {
                Text("Size of local DB: \(txt)")
            }
            clearMenu
        } label: {
            Image(systemName: "gear")
        }
    }
    
    private var filtersMenu: some View {
        ForEach(vm.getCurateItems()) { (item) in
            switch item.item {
            case .resetAll:
                Button(item.item.title, role: .destructive) {
                    vm.selectedStatusBy = .none
                }
            case .filterBy:
                ForEach(item.subItems) { (subItem) in
                    switch subItem {
                    case .status:
                        Picker("\(item.item.title) \(vm.filterBy)", selection: $vm.selectedStatusBy) {
                            ForEach(KVKStatus.allCases) { (status) in
                                Text(status.title)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            default:
                EmptyView()
            }
        }
    }
    
    private var clearMenu: some View {
        ForEach(vm.getSettingItems()) { (item) in
            switch item.item {
            case .clearBySchedule:
                Picker("\(item.item.title) \(vm.clearBy)", selection: $vm.selectedClearBy) {
                    ForEach(item.subItems ?? []) { (subItem) in
                        Text(subItem.title)
                    }
                }
                .pickerStyle(.menu)
            case .clearAll:
                Button(role: .destructive) {
                    viewContext.deleteAll()
                    vm.sizeOfDB = nil
                } label: {
                    Text(item.item.title)
                }
            }
        }
    }
    
    @ViewBuilder
    private func getLogView(_ log: ItemLog) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(log.items)
                .lineLimit(log.type == .network ? 8 : nil)
            if let details = log.details {
                Text(details)
            }
            if log.type == .network, let size = log.size {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .resizable()
                        .foregroundColor(.green)
                        .frame(width: 15, height: 15)
                    Text(size)
                }
            }
            HStack {
                if log.type == .common {
                    Text(log.status.icon)
                } else {
                    Image(systemName: "network")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 20, height: 20)
                }
                Text(log.formattedCreatedAt)
            }
            .foregroundColor(.gray)
            .font(.subheadline)
        }
        .contextMenu {
            Button {
                vm.copyLog(log)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            if #available(iOS 16.0, macOS 13.0, *) {
                ShareLink(item: log.copyTxt)
            } else {
                // Fallback on earlier versions
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
        newItem1.status = .info
        newItem1.logType = .debug
        newItem1.items = String(describing: "Test description log Test description log Test description log")
        let newItem2 = ItemLog(context: viewContext)
        newItem2.createdAt = Date()
        newItem2.status = .verbose
        newItem2.logType = .print
        newItem2.details = "\(#file)\n\(#function)\n\(#line)"
        newItem2.items = "Test description log Test description log Test description log"
        let newItem3 = ItemLog(context: viewContext)
        newItem3.createdAt = Date()
        newItem3.data = "Test response".data(using: .utf8)
        newItem3.status = .debug
        newItem3.type = .network
        newItem3.logType = .print
        newItem3.items = "Test description network Test description network Test description network"
        viewContext.saveContext()
        return KVKLoggerProxyView()
            .environment(\.managedObjectContext, viewContext)
    }
}
