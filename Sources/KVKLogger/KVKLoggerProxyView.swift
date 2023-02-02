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
    @Environment (\.dismiss) private var dismiss
    @FetchRequest(fetchRequest: ItemLog.fecth(), animation: .default)
    private var logs: FetchedResults<ItemLog>
    @ObservedObject private var vm = KVKLoggerVM()
    
    var body: some View {
        navigationView
    }
    
    private var navigationView: some View {
        if #available(iOS 16.0, *) {
            return NavigationStack {
                bodyView
            }
        } else {
            return NavigationView {
                bodyView
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private var bodyView: some View {
        ScrollViewReader { (proxy) in
            ScrollView {
                ForEach(logs) { (log) in
                    HStack {
                        Text(log.status.icon)
                        VStack(alignment: .leading) {
                            Text(log.items)
                            if let details = log.details {
                                Text(details)
                            }
                            Text(log.formattedCreatedAt)
                                .foregroundColor(Color(uiColor: .systemGray))
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .id(log.id)
                    .padding(5)
                }
            }
            .task {
                withAnimation {
                    proxy.scrollTo(logs.last?.id)
                }
            }
            .padding([.leading, .trailing], 5)
            .searchable(text: $vm.query, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Console")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }

                }
            }
        }
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        let result = KVKPersistenceСontroller(inMemory: true)
        let viewContext = result.viewContext
        for _ in 0..<10 {
            let newItem = ItemLog(context: viewContext)
            newItem.createdAt = Date()
            newItem.status = KVKStatus.info
            newItem.type = KVKLogType.debug
            newItem.details = "\(#file)\n\(#function)\n\(#line)"
            newItem.items = "Test description log"
        }
        viewContext.saveContext()
        return Group {
            KVKLoggerProxyView()
            KVKLoggerProxyView()
                .preferredColorScheme(.dark)
        }
        .environment(\.managedObjectContext, viewContext)
    }
}
