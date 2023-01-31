//
//  KVKLoggerView.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

public struct KVKLoggerView: View {
    let persistenceContainer = KVKPersistenceСontroller.shared
    
    public init() {}
    
    public var body: some View {
        KVKLoggerProxyView()
            .environment(\.managedObjectContext, persistenceContainer.container.viewContext)
    }
}

struct KVKLoggerProxyView: View {
    
    @Environment (\.managedObjectContext) private var viewContext
    @Environment (\.dismiss) private var dismiss
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ItemLog.createdAt_, ascending: true)],
                  animation: .default)
    private var logs: FetchedResults<ItemLog>
    
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
                        //Text(log.status.icon)
                        //                            VStack(alignment: .leading) {
                        //                                Text(log.formattedTxt)
                        //                                if let details = log.details {
                        //                                    Text(details)
                        //                                }
                        //                                Text(log.formattedDate)
                        //                                    .foregroundColor(Color(uiColor: .systemGray))
                        //                                    .font(.subheadline)
                        //                            }
                        Spacer()
                    }
                    .id(log.id)
                    .padding(5)
                }
            }
            .task {
                withAnimation {
                    //proxy.scrollTo(logs.endIndex - 1)
                }
            }
            .padding([.leading, .trailing], 5)
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
            }
        }
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        KVKLogger.shared.log("Test description")
        KVKLogger.shared.log("Test description", status: .error)
        KVKLogger.shared.log("Test description", status: .verbose)
        return Group {
            KVKLoggerProxyView()
            KVKLoggerProxyView()
                .preferredColorScheme(.dark)
        }
        .environment(\.managedObjectContext, KVKPersistenceСontroller.preview.container.viewContext)
    }
}
