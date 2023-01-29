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
        .info, .error, .debug, .warning, .verbose, .custom("Custom", .systemPink)
    ]
    @State private var selectedStatus: KVKStatus = .info
    @State private var isOpenedConsole = false
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Status of Error", selection: $selectedStatus) {
                ForEach(statuses) { (status) in
                    Text(status.title)
                }
            }
            Button("Print to console") {
                KVKLogger.shared.log("test test test test test",
                                     status: selectedStatus)
            }
            Button("Show console (Modal)") {
                isOpenedConsole = true
            }
        }
        .sheet(isPresented: $isOpenedConsole) {
            if #available(iOS 16.0, *) {
                KVKLoggerView()
                    .presentationDetents([.height(200), .medium, .large])
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
