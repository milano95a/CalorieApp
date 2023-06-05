//
//  String+CalorieApp.swift
//  CalorieApp
//
//  Created by Workspace on 23/04/22.
//

import Foundation

extension String {
    static func getRandomEmail(currentStringAsUsername: Bool = false) -> String {
        let providers = ["gmail.com", "hotmail.com", "icloud.com", "live.com"]
        let randomProvider = providers.randomElement()!
        let username = UUID.init().uuidString.prefix(8).replacingOccurrences(of: "-", with: "")
        return "user_\(username)@\(randomProvider)".lowercased()
    }
}
