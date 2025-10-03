//
//  ContentView.swift
//  UninstallAssistant
//
//  Created by David Rosenberg on 10/3/25.
//

import ServiceManagement
import SwiftUI

struct ContentView: View {
    let helperServiceName = "com.dgrdev.UninstallAssistant.Helper"
    var helperServicePlist: String {
        helperServiceName + ".plist"
    }

    @State private var helperRegistered: Bool = false
    @State private var helperApproved: Bool = false

    @State private var testResult: Int?

    var body: some View {
        VStack {
            HStack {
                Text("Helper Is Registered:")
                Image(systemName: helperRegistered ? "checkmark.square.fill" : "x.square.fill")
                    .foregroundColor(helperRegistered ? Color.green : Color.red)
            }

            HStack {
                Text("Helper Is Approved:")
                Image(systemName: helperApproved ? "checkmark.square.fill" : "x.square.fill")
                    .foregroundColor(helperApproved ? Color.green : Color.red)
            }

            Button("Register Helper Daemon Service") {
                print("Registering \(helperServicePlist)")
                let service = SMAppService.daemon(plistName: helperServicePlist)

                do {
                    try service.register()
                    print("Successfully registered \(service)")
                    checkHelperStatus()
                } catch {
                    print("Unable to register \(error)")
                }
            }

            Button("Unregister Helper Daemon Service") {
                print("Unregistering \(helperServicePlist)")
                let service = SMAppService.daemon(plistName: helperServicePlist)

                do {
                    try service.unregister()
                    print("Successfully unregistered \(service)")
                    helperRegistered = false
                    helperApproved = false
                    testResult = nil
                } catch {
                    print("Unable to unregister \(error)")
                }
            }

            Button("Check Helper Status") {
                checkHelperStatus()
            }

            if helperRegistered && helperApproved {
                Button("Test Helper") {
                    print("TEST: Sending Helper Request")

                    let connection = NSXPCConnection(machServiceName: helperServiceName)
                    print("TEST: Connection: \(connection)")

                    connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
                    connection.interruptionHandler = {
                        print("TEST: XPC connection interrupted")
                    }
                    connection.invalidationHandler = {
                        print("TEST: XPC connection invalidated")
                    }
                    connection.resume()
                    print("TEST: Connection resumed")

                    if let proxy = connection.remoteObjectProxy as? HelperProtocol {
                        print("TEST: Proxy: \(proxy)")
                        proxy.performCalculation(firstNumber: 23, secondNumber: 19) { result in
                            print("Result of calculation is: \(result)")
                            testResult = result
                        }
                        print("TEST: Done")
                    }

                    // connection.invalidate()
                }
            }

            if testResult != nil {
                Text("Test Result: \(testResult!)")
            }
        }
        .padding()
        .navigationTitle("LaunchDaemon Testing")
        .onAppear {
            checkHelperStatus()
        }
    }

    func checkHelperStatus() {
        print("Checking Helper Daemon Service Status")
        let service = SMAppService.daemon(plistName: helperServicePlist)
        print("Helper Daemon Service Status: \(service.status)")

        if service.status == .enabled {
            print("Helper Daemon Service is enabled")
            helperRegistered = true

            if service.status == .requiresApproval {
                print("Helper Daemon Service requires approval")
                SMAppService.openSystemSettingsLoginItems()
            } else {
                print("Helper Daemon Service is approved")
                helperApproved = true
            }
        }
    }
}

#Preview {
    ContentView()
}
