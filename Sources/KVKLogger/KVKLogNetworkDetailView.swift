//
//  KVKLogNetworkDetailView.swift
//  
//
//  Created by Sergei Kviatkovskii on 2/4/23.
//

import SwiftUI
import CoreData

struct KVKLogNetworkDetailView: View {
    
    private let maxLimitCountInText = 50
    @State private var isCopied = false
    @State private var text: String
    @ObservedObject var log: ItemLog
    
    init(log: ItemLog) {
        self.log = log
        var txtDetails = log.items
        if let response = try? log.getNetworkJson(), !response.isEmpty {
            txtDetails += "\n\n[RESULT]:\n\n\(response)"
        }
        text = txtDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let size = log.size {
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
                TextEditor(text: $text)
        }
        .padding(.leading)
        .navigationTitle(log.formattedShortCreatedAt)
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
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
        let store = KVKPersistenceСontroller(inMemory: true)
        let newItem3 = ItemLog(context: store.viewContext)
        newItem3.createdAt = Date()
        newItem3.items = "Test response Test response"
        newItem3.type = KVKItemLogType.network
        newItem3.logType = KVKLogType.print
        newItem3.data = "{\n    result =     (\n                {\n            assignedAtUtcDate = \"2023-01-30T18:11:22.2072087Z\";\n            assignedByUser =             {\n                displayName = \"Chad Jones\";\n                globalUserName = \"1007.sleapman\";\n                tenantId = 0;\n                userId = 38;\n                userImageThumbnailUrl = \"https://symplastdevelopment.s3.amazonaws.com/1007/UserImage/1007/Thumb_38.jpg\";\n            };\n            assignedByUserGlobalId = \"1007.38\";\n            assignedUser =             {\n                displayName = \"Chad Jones\";\n                globalUserName = \"1007.sleapman\";\n                tenantId = 0;\n                userId = 38;\n                userImageThumbnailUrl = \"https://symplastdevelopment.s3.amazonaws.com/1007/UserImage/1007/Thumb_38.jpg\";\n            };\n            assignedUserGlobalId = \"1007.38\";\n            auditLogs =             (\n            );\n            createdByGlobalId = \"1007.38\";\n            createdByUser =             {\n                displayName = \"Chad Jones\";\n".data(using: .utf8)
        return NavigationView {
            KVKLogNetworkDetailView(log: newItem3)
        }
#if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
#endif
        .environment(\.managedObjectContext, store.viewContext)
    }
}
