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
    @State private var json = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                Text("REQUEST:")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                Text(log.items)
                    .multilineTextAlignment(.leading)
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
                Text("RESULT:")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                Text(json)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .onAppear() {
            prepareJson()
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
    
    private func prepareJson() {
        do {
            json = try log.getNetworkJson()
        } catch {
            json = error.localizedDescription
        }
    }
    
}

struct KVKLogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let store = KVKPersistenceСontroller(inMemory: true)
        let newItem3 = ItemLog(context: store.viewContext)
        newItem3.createdAt = Date()
        newItem3.data = "Test response Test response".data(using: .utf8)
        newItem3.type = ItemLogType.network
        newItem3.logType = KVKLogType.print
        newItem3.items = "Test description network"
        return NavigationView {
            KVKLogNetworkDetailView(log: newItem3)
        }
#if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
#endif
        .environment(\.managedObjectContext, store.viewContext)
    }
}
