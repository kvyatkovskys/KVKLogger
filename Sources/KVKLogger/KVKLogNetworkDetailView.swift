//
//  KVKLogNetworkDetailView.swift
//  
//
//  Created by Sergei Kviatkovskii on 2/4/23.
//

import SwiftUI

struct KVKLogNetworkDetailView: View {
    
    @ObservedObject var log: ItemLog
    @State private var isCopied = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack {
                    Text("REQUEST:")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    Text(log.items)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                if let json = log.networkJson {
                    HStack {
                        Text("SIZE:")
                            .foregroundColor(.gray)
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 20, height: 20)
                        Text(log.size)
                        Spacer()
                    }
                    HStack {
                        Text("RESULT:")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                        Text(json)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
            }
            .padding()
        }
        .navigationTitle(log.formattedShortCreatedAt)
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // in progress
                    UIPasteboard.general.string = log.copyTxt
                    isCopied.toggle()
                } label: {
                    Image(systemName: isCopied ? "doc.on.doc.fill" : "doc.on.doc")
                }
            }
#endif
        }
    }
}

struct KVKLogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = KVKPersistenceСontroller(inMemory: true).viewContext
        let newItem3 = ItemLog(context: viewContext)
        newItem3.createdAt = Date()
        newItem3.data = "Test response".data(using: .utf8)
        newItem3.type = ItemLogType.network
        newItem3.logType = KVKLogType.print
        newItem3.items = "Test description network"
        return NavigationView {
            KVKLogNetworkDetailView(log: newItem3)
        }
#if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
#endif
        .environment(\.managedObjectContext, viewContext)
    }
}
