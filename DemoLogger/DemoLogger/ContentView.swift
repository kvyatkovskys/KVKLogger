//
//  ContentView.swift
//  DemoLogger
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI
import KVKLogger

struct ContentView: View {
    
    @State private var statuses: [KVKStatus] = [
        .info, .error, .debug, .warning, .verbose, .custom("Custom")
    ]
    @State private var selectedStatus: KVKStatus = .info
    @State private var isOpenedConsole = false
    
    var body: some View {
        VStack(spacing: 20) {
            Menu("Status of error: \(selectedStatus.rawValue)") {
                Picker("", selection: $selectedStatus) {
                    ForEach(statuses) { (status) in
                        Text(status.title)
                    }
                }
            }
            Button("Print common log") {
                KVKLogger.shared.log(statuses, "Test",
                                     status: selectedStatus,
                                     type: .print)
            }
            Button("Print network request") {
                KVKLogger.shared.network("Network Response",
                                         data: "Test data".data(using: .utf8),
                                         type: .debug)
            }
            Button("Show console (Modal)") {
                isOpenedConsole = true
            }
        }
        .sheet(isPresented: $isOpenedConsole) {
            if #available(iOS 16.0, *) {
                KVKLoggerView()
                    .presentationDetents([.medium, .large])
            } else {
                KVKLoggerView()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
