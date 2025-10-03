//
//  Helper.swift
//  Helper
//
//  Created by David Rosenberg on 10/3/25.
//

import AppKit
import Foundation

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class Helper: NSObject, HelperProtocol {

    /// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
    @objc func performCalculation(
        firstNumber: Int,
        secondNumber: Int,
        with reply: @escaping (Int) -> Void
    ) {
        let response = firstNumber + secondNumber
        reply(response)
    }

    @objc func uninstallApp(bundleID: String, with reply: @escaping (NSError?) -> Void) {
        // Check if an app with the given bundle ID is installed
        let workspace = NSWorkspace.shared
        guard let appUrl = workspace.urlForApplication(withBundleIdentifier: bundleID) else {
            reply(UninstallError.notFound as NSError)
            return
        }

        // Check if the app is a system app
        if appUrl.path.hasPrefix("/System/") {
            reply(UninstallError.systemApp as NSError)
            return
        }

        // Check if the app is locked by policy
        let defaults = UserDefaults.standard
        let lockedBundleIDs =
            defaults.array(
                forKey: ManagedPrefsKeys.lockedBundleIDs
            ) as? [String] ?? []

        if lockedBundleIDs.contains(bundleID) {
            reply(UninstallError.lockedByPolicy as NSError)
            return
        }

        // Attempt to delete the app
        do {
            try FileManager.default.trashItem(at: appUrl, resultingItemURL: nil)
            reply(nil)
        } catch {
            reply(
                UninstallError.failed(
                    "Failed to uninstall app with bundle ID \(bundleID): \(error.localizedDescription)"
                ) as NSError
            )
        }
    }
}
