//
//  KVKLogNetworkDetailView.swift
//  
//
//  Created by Sergei Kviatkovskii on 2/4/23.
//

import SwiftUI
import CoreData

struct KVKLogNetworkDetailView: View {

    @ObservedObject var vm: KVKLogDetailVM
    @State private var isCopied = false
    
    init(vm: KVKLogDetailVM) {
        self.vm = vm
        vm.fetchObjectIfNeeded()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let size = vm.size {
                    HStack {
                        Text("SIZE:")
                            .foregroundColor(.gray)
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 20, height: 20)
                        Text(size)
                        Spacer()
                    }
                }
                Text("REQUEST:")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                Text(vm.text)
                    .multilineTextAlignment(.leading)
                Text("RESULT:")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                Text(vm.json)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle(vm.title)
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.copy()
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
        let store = KVKPersistenceСontroller(inMemory: true)
        let newItem3 = ItemLog(context: store.backgroundContext)
        newItem3.createdAt = Date()
        newItem3.items = "Test response Test response"
        newItem3.type = ItemLogType.network
        newItem3.logType = KVKLogType.print
        newItem3.data = "{\n    result =     (\n                {\n            assignedAtUtcDate = \"2023-01-30T18:11:22.2072087Z\";\n            assignedByUser =             {\n                displayName = \"Chad Jones\";\n                globalUserName = \"1007.sleapman\";\n                tenantId = 0;\n                userId = 38;\n                userImageThumbnailUrl = \"https://symplastdevelopment.s3.amazonaws.com/1007/UserImage/1007/Thumb_38.jpg\";\n            };\n            assignedByUserGlobalId = \"1007.38\";\n            assignedUser =             {\n                displayName = \"Chad Jones\";\n                globalUserName = \"1007.sleapman\";\n                tenantId = 0;\n                userId = 38;\n                userImageThumbnailUrl = \"https://symplastdevelopment.s3.amazonaws.com/1007/UserImage/1007/Thumb_38.jpg\";\n            };\n            assignedUserGlobalId = \"1007.38\";\n            auditLogs =             (\n            );\n            createdByGlobalId = \"1007.38\";\n            createdByUser =             {\n                displayName = \"Chad Jones\";\n".data(using: .utf8)
        store.backgroundContext.saveContext()
        return NavigationView {
            KVKLogNetworkDetailView(vm: KVKLogDetailVM(id: newItem3.objectID))
        }
#if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
#endif
        .environment(\.managedObjectContext, store.viewContext)
    }
}
