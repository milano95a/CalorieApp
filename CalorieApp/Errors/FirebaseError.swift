//
//  FirebaseError.swift
//  CalorieApp
//
//  Created by Workspace on 25/04/22.
//

import Foundation

enum FirebaseError: Error {
    case userNotFound
}
extension FirebaseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            return NSLocalizedString("User not found", comment: "FirebaseError")
        }
    }
}

