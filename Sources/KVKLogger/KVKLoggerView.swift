//
//  KVKLoggerView.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

public struct KVKLoggerView: View {
    
    @Environment (\.dismiss) private var dismiss
    @ObservedObject private var vm = KVKLogger.shared.vm
    
    public init() {}
    
    public var body: some View {
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
        VStack {
            ScrollViewReader { (proxy) in
                ScrollView {
                    ForEach(vm.logs.indices, id: \.self) { (idx) in
                        let log = vm.logs[idx]
                        HStack {
                            Text(log.status.icon)
                            VStack(alignment: .leading) {
                                Text(log.formattedTxt)
                                if let details = log.details {
                                    Text(details)
                                }
                                Text(log.formattedDate)
                                    .foregroundColor(Color(uiColor: .systemGray))
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        .id(idx)
                        .padding(5)
                    }
                }
                .task {
                    withAnimation {
                        proxy.scrollTo(vm.logs.endIndex - 1)
                    }
                }
                .padding([.leading, .trailing], 5)
            }
        }
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

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        KVKLogger.shared.log("Test description")
        KVKLogger.shared.log("Test description", status: .error)
        KVKLogger.shared.log("Test description", status: .verbose)
        return Group {
            KVKLoggerView()
            KVKLoggerView()
                .preferredColorScheme(.dark)
        }
    }
}
