//
//  KVKLogDetailView.swift
//  
//
//  Created by Sergei Kviatkovskii on 2/4/23.
//

import SwiftUI

struct KVKLogDetailView: View {
    
    @ObservedObject var log: ItemLog
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                Text(log.items)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let json = log.networkJson {
                    Text(json)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle("Detail Log")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    UIPasteboard.general.string = log.copyTxt
                } label: {
                    Image(systemName: "doc.on.doc")
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
            KVKLogDetailView(log: newItem3)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.managedObjectContext, viewContext)
    }
}
