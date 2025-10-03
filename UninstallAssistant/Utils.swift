//
//  Utils.swift
//  UninstallAssistant
//
//  Created by David Rosenberg on 10/3/25.
//

import Foundation

func connectToHelper() -> (NSXPCConnection, HelperProtocol)? {
    let connection = NSXPCConnection(machServiceName: serviceName)
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
        return (connection, proxy)
    }
    return nil
}
