//
//  Errors.swift
//  UninstallAssistant
//
//  Created by David Rosenberg on 10/3/25.
//

import Foundation

enum UninstallError: Error {
    case notFound
    case systemApp
    case lockedByPolicy
    case failed(String)
}
