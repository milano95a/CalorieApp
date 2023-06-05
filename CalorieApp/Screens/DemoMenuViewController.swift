//
//  DemoMenuViewController.swift
//  CalorieApp
//
//  Created by Workspace on 20/04/22.
//

import UIKit
import Firebase

class DemoMenuViewController: BaseViewController {
    
    let demoAdmin = "admin@gmail.com"
    let demoUser = "user@gmail.com"
    let demoPassword = "password"
    let demoDailyCalorie = 2100
    
    @IBAction func adminTapped(_ sender: UIButton) {
        if !isReachable() { return }
        isLoading = true
                
        FirebaseManager.shared.signIn(demoAdmin, demoPassword) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            if let error = error {
                strongSelf.showAlert("Error", "Ooops, something went wrong. \(error.localizedDescription)")
            } else {
                strongSelf.saveUserSettings(strongSelf.demoAdmin)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "AdminViewControllerID") as? AdminViewController {
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func userTapped(_ sender: UIButton) {
        if !isReachable() { return }
        isLoading = true
        
        FirebaseManager.shared.signIn(demoUser, demoPassword) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            if let error = error {
                strongSelf.showAlert("Error", "Ooops, something went wrong. \(error.localizedDescription)")
            } else {
                strongSelf.saveUserSettings(strongSelf.demoUser)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "EntriesViewControllerID") as? EntriesViewController {
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func newUserTapped(_ sender: UIButton) {
        if !isReachable() { return }
        isLoading = true
        let email = String.getRandomEmail()
        FirebaseManager.shared.createUser(email, demoPassword) { [weak self] error in
            self?.isLoading = false
            if let error = error {                
                self?.showAlert("Error", "Ooops, something went wrong. \(error.localizedDescription)")
            } else {
                self?.saveUserSettings(email)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "EntriesViewControllerID") as? EntriesViewController {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    private func saveUserSettings(_ userId: String) {
        let defaults = UserDefaults.standard
        defaults.set(userId, forKey: USER_ID)
        defaults.set(demoDailyCalorie, forKey: DAILY_CALORIE_LIMIT + userId)
    }
}

