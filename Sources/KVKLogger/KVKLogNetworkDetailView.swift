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
                        .foregroundColor(Color(uiColor: .systemGray))
                        .multilineTextAlignment(.leading)
                    Text(log.items)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                if let json = log.networkJson {
                    HStack {
                        Text("SIZE:")
                            .foregroundColor(Color(uiColor: .systemGray))
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .foregroundColor(Color(uiColor: .systemGreen))
                            .frame(width: 20, height: 20)
                        Text(log.size)
                        Spacer()
                    }
                    HStack {
                        Text("RESULT:")
                            .foregroundColor(Color(uiColor: .systemGray))
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    UIPasteboard.general.string = log.copyTxt
                    isCopied.toggle()
                } label: {
                    Image(systemName: isCopied ? "doc.on.doc.fill" : "doc.on.doc")
                }
            }
        }
    }
}

struct KVKLogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = KVKPersistenceСontroller(inMemory: true).viewContext
        let newItem3 = ItemLog(context: viewContext)
        newItem3.createdAt = Date()
        newItem3.data = "Test response".data(using: .utf8)
        newItem3.type = .network
        newItem3.logType = KVKLogType.print
        newItem3.items = "Test description network"
        return NavigationView {
            KVKLogNetworkDetailView(log: newItem3)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.managedObjectContext, viewContext)
    }
}
