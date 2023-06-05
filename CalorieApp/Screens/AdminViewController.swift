//
//  AdminViewController.swift
//  CalorieApp
//
//  Created by Workspace on 23/04/22.
//

import UIKit

class AdminViewController: BaseViewController {

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let entriesVC = segue.destination as? EntriesViewController else { return }
        entriesVC.isAdmin = true
    }
}
