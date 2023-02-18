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
                KVKLogger.shared.log(statuses, "{\n    result =     (\n                {\n            assignedAtUtcDate = \"2023-01-30T18:11:22.2072087Z\";\n            assignedByUser =             {\n                displayName = \"Chad Jones\";\n                globalUserName = \"1007.sleapman\";\n                tenantId = 0;\n                userId = 38;\n                userImageThumbnailUrl = \"https://symplastdevelopment.s3.amazonaws.com/1007/UserImage/1007/Thumb_38.jpg\";\n            };\n            assignedByUserGlobalId = \"1007.38\";\n            assignedUser =             {\n                displayName = \"Chad Jones\";\n                globalUserName = \"1007.sleapman\";\n                tenantId = 0;\n                userId = 38;\n                userImageThumbnailUrl = \"https://symplastdevelopment.s3.amazonaws.com/1007/UserImage/1007/Thumb_38.jpg\";\n            };\n            assignedUserGlobalId = \"1007.38\";\n            auditLogs =             (\n            );\n            createdByGlobalId = \"1007.38\";\n            createdByUser =             {\n                displayName = \"Chad Jones\";\n",
                                     status: selectedStatus,
                                     type: .print)
            }
            Button("Print network request") {
                Task {
                    await writeManyStringToLog()
                }
            }
            Button("Show console (Modal)") {
                isOpenedConsole = true
            }
        }
        .sheet(isPresented: $isOpenedConsole) {
            if #available(iOS 16.0, *) {
                KVKLoggerView()
                    .presentationDetents([.large])
            } else {
                KVKLoggerView()
            }
        }
        .padding()
    }
    
    func writeManyStringToLog() async {
        let text = """
POST https://practiceapp-dev.symplast.com/AppActions/Stats (200)BODY: {
    actionId = "362713CB-34EF-4C13-ABC4-6A2599643667";
    platform = iOS;
    version = "2.71.1";
}

[Network Duration]: 1.5066689252853394s
[Serialization Duration]: 0:00.000
[Response]: {
    result =     {
        actions =         (
                        {
                backgroundColor = "#eaf4f8";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/action-center.png";
                id = "630f3aba-5e2d-471a-9efd-121cbb23b046";
                isHidden = 0;
                name = "Action Center";
                path = ActionCenter;
            },
                        {
                backgroundColor = "#ececfe";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/calendar.png";
                id = "12d89f54-f49a-4716-ad99-c461a21ad04c";
                isHidden = 0;
                name = Calendar;
                path = Calendar;
            },
                        {
                backgroundColor = "#ececfe";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/new-appointment.png";
                id = "d516f03a-c81f-4c55-a482-577e1dc769df";
                isHidden = 0;
                name = "Create New Appointment";
                parentId = "12d89f54-f49a-4716-ad99-c461a21ad04c";
                path = "Calendar/Appointments/New";
            },
                        {
                backgroundColor = "#ececfe";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/patient-checkin.png";
                id = "cab88ceb-48e4-47af-bea4-1b2f42609123";
                isHidden = 0;
                name = "Check-In Patient";
                parentId = "12d89f54-f49a-4716-ad99-c461a21ad04c";
                path = "Calendar/Patient/Check-In";
            },
                        {
                backgroundColor = "#ececfe";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/patient-checkout.png";
                id = "de87e4b7-19a1-42e7-87d3-a8829fd9b680";
                isHidden = 0;
                name = "Check-Out Patient";
                parentId = "12d89f54-f49a-4716-ad99-c461a21ad04c";
                path = "Calendar/Patient/Check-Out";
            },
                        {
                backgroundColor = "#ececfe";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/calendar-view.png";
                id = "da000982-94f2-4159-8fcb-b240ed4b24b2";
                isHidden = 0;
                name = "View Calendar";
                parentId = "12d89f54-f49a-4716-ad99-c461a21ad04c";
                path = Calendar;
            },
                        {
                backgroundColor = "#fbf6ef";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/practice-flow.png";
                id = "2cdf34a3-e21a-43c9-9f9d-602ccd39e176";
                isHidden = 0;
                name = "Practice Flow";
                path = PracticeFlow;
            },
                        {
                backgroundColor = "#f3f3f3";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/secure-messaging.png";
                id = "11607992-dda7-4dba-85c3-37a867c920eb";
                isHidden = 0;
                name = "Secure Messaging";
                path = SecureMessaging;
            },
                        {
                backgroundColor = "#eff5ed";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/global-catalog.png";
                id = "24f89fa3-9fcb-4f2b-8ec0-34aba7a05c7e";
                isHidden = 0;
                name = "Global Catalog";
                path = GlobalCatalog;
            },
                        {
                backgroundColor = "#edf8f6";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/estimates-and-invoices.png";
                id = "faaeb959-1028-4c0f-bad2-094c0fd62311";
                isHidden = 0;
                name = Financials;
                path = Financials;
            },
                        {
                backgroundColor = "#edf8f6";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/pricelist.png";
                id = "cd39c02a-8b54-45aa-bc68-ed89b095ccac";
                isHidden = 0;
                name = "Price List";
                parentId = "faaeb959-1028-4c0f-bad2-094c0fd62311";
                path = "Financials/Prices";
            },
                        {
                backgroundColor = "#edf8f6";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/sell-product.png";
                id = "91943062-e49c-4e1d-a79f-9876244b6771";
                isHidden = 0;
                name = "Sell an Item";
                parentId = "faaeb959-1028-4c0f-bad2-094c0fd62311";
                path = "Financials/Invoices/New";
            },
                        {
                backgroundColor = "#edf8f6";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/estimates.png";
                id = "3b84197f-59f9-43da-b73c-4919eeee1e26";
                isHidden = 0;
                name = Estimates;
                parentId = "faaeb959-1028-4c0f-bad2-094c0fd62311";
                path = "Financials/Estimates";
            },
                        {
                backgroundColor = "#edf8f6";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/invoices.png";
                id = "bf47bee5-58fe-45ce-9d02-86db54c25b32";
                isHidden = 0;
                name = Invoices;
                parentId = "faaeb959-1028-4c0f-bad2-094c0fd62311";
                path = "Financials/Invoices";
            },
                        {
                backgroundColor = "#edf8f6";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/credit-notes.png";
                id = "ae63285d-4e1e-4cf0-8788-d5363edec3f3";
                isHidden = 0;
                name = "Credit Notes";
                parentId = "faaeb959-1028-4c0f-bad2-094c0fd62311";
                path = "Financials/CreditNotes";
            },
                        {
                backgroundColor = "#edf8f6";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/payments.png";
                id = "627f6807-f9a1-4d53-a57e-f944d90cb63e";
                isHidden = 0;
                name = Payments;
                parentId = "faaeb959-1028-4c0f-bad2-094c0fd62311";
                path = "Financials/Payments";
            },
                        {
                backgroundColor = "#eaeffb";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/eRx.png";
                id = "0ee113bd-4e32-4f7b-b333-1151968700d7";
                isHidden = 0;
                name = eRX;
                path = eRX;
            },
                        {
                backgroundColor = "#fff4f9";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/reports.png";
                id = "ef589476-a14e-4bb7-ad58-190a2c32c452";
                isHidden = 0;
                name = Reports;
                path = Reports;
            },
                        {
                backgroundColor = "#F0F2F4";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/task_manager.png";
                id = "362713cb-34ef-4c13-abc4-6a2599643667";
                isHidden = 0;
                name = "Task Management";
                path = TaskManager;
            },
                        {
                backgroundColor = "#fff6e8";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/profile.png";
                id = "7856f926-64ff-4d59-adeb-d8938c7bcd4d";
                isHidden = 0;
                name = "My Profile";
                path = EditUser;
            },
                        {
                backgroundColor = "#f3f3f3";
                iconUrl = "https://symplastproduction.s3.amazonaws.com/Images/Actions/settings.png";
                id = "9c7f7e3c-17c5-464f-9dc6-e331905707ed";
                isHidden = 0;
                name = "Practice Settings";
                path = Settings;
            }
        );
        favorites =         (
            "2cdf34a3-e21a-43c9-9f9d-602ccd39e176",
            "ef589476-a14e-4bb7-ad58-190a2c32c452",
            "11607992-dda7-4dba-85c3-37a867c920eb",
            "630f3aba-5e2d-471a-9efd-121cbb23b046",
            "9c7f7e3c-17c5-464f-9dc6-e331905707ed",
            "faaeb959-1028-4c0f-bad2-094c0fd62311",
            "24f89fa3-9fcb-4f2b-8ec0-34aba7a05c7e",
            "12d89f54-f49a-4716-ad99-c461a21ad04c"
        );
        recent =         (
            "362713cb-34ef-4c13-abc4-6a2599643667",
            "bf47bee5-58fe-45ce-9d02-86db54c25b32",
            "3b84197f-59f9-43da-b73c-4919eeee1e26",
            "cab88ceb-48e4-47af-bea4-1b2f42609123",
            "7856f926-64ff-4d59-adeb-d8938c7bcd4d",
            "d516f03a-c81f-4c55-a482-577e1dc769df",
            "da000982-94f2-4159-8fcb-b240ed4b24b2",
            "0ee113bd-4e32-4f7b-b333-1151968700d7"
        );
    };
    statusCode = 200;
    version = "0.219.0";
}
[Result]: success(5941 bytes)
"""
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 1 {
                group.addTask {
                    await KVKLogger.shared.network(text, type: .debug)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
