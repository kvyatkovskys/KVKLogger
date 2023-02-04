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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
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
        return KVKLogDetailView(log: newItem3)
            .environment(\.managedObjectContext, viewContext)
    }
}
