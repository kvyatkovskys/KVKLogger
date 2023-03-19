//
//  KVKDatePopoverView.swift
//  
//
//  Created by Sergei Kviatkovskii on 3/18/23.
//

import SwiftUI

struct KVKDatePopoverView: View {
    
    @Environment (\.dismiss) private var dismiss
    
    struct DateContainer: Equatable {
        var start: Date
        var end: Date
    }
    
    @Binding var date: DateContainer?
    @State private var dateProxyStart: Date
    @State private var dateProxyEnd: Date
    @State private var showError: Bool = false
    
    init(date: Binding<DateContainer?>) {
        _date = date
        let dateStart = date.wrappedValue?.start ?? Date()
        _dateProxyStart = State(initialValue: dateStart)
        let dateEnd = Calendar.current.date(byAdding: .hour, value: 1, to: dateStart) ?? Date()
        _dateProxyEnd = State(initialValue: date.wrappedValue?.end ?? dateEnd)
    }
    
    var body: some View {
        VStack {
            Group {
                HStack {
                    DatePicker("Select start:", selection: $dateProxyStart)
                    if date?.start != nil {
                        Spacer()
                        Rectangle()
                            .fill(.purple)
                            .cornerRadius(2)
                            .frame(width: 5, height: 35)
                    }
                }
                HStack {
                    DatePicker("Select end:", selection: $dateProxyEnd)
                    if date?.end != nil {
                        Spacer()
                        Rectangle()
                            .fill(.purple)
                            .cornerRadius(2)
                            .frame(width: 5, height: 35)
                    }
                }
            }
            
            if showError {
                HStack {
                    Spacer()
                    Text("Start date should be less than end date!")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            
            HStack {
                Button {
                    guard dateProxyStart < dateProxyEnd else {
                        showError = true
                        return
                    }
                    
                    date = DateContainer(start: dateProxyStart, end: dateProxyEnd)
                    dismiss()
                } label: {
                    Text("Apply")
                        .foregroundColor(.white)
                        .padding(10)
                }
                .background(.blue)
                .cornerRadius(10)
                .padding(5)

                Button {
                    date = nil
                    dismiss()
                } label: {
                    Text("Clear")
                        .foregroundColor(.white)
                        .padding(10)
                }
                .background(.red)
                .cornerRadius(10)
                .padding(5)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
}

struct KVKDatePopoverView_Previews: PreviewProvider {
    static var previews: some View {
        KVKDatePopoverView(date: .constant(nil))
    }
}
