//
//  ReportViewController.swift
//  CalorieApp
//
//  Created by Workspace on 24/04/22.
//

import UIKit
import Firebase

class ReportViewController: BaseViewController {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var last7DaysNumberOfEntries: UILabel!
    @IBOutlet weak var previous7DaysNumberOfEntries: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        retreiveData()
    }
    
    private var sevenDaysCaloriesByUser = [String: Int]()
    private var users = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var lastSevenDaysNumberOfEntries = 0 {
        didSet {
            last7DaysNumberOfEntries.text = "\(lastSevenDaysNumberOfEntries)"
        }
    }
    private var previousSevenDaysNumberOfEntries = 0 {
        didSet {
            previous7DaysNumberOfEntries.text = "\(previousSevenDaysNumberOfEntries)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        retreiveData()
        dayLabel.text = Date().dayInWeek
    }
    
    private func retreiveData() {
        
        if !isReachable() { return }
        
        isLoading = true
        
        Firestore.firestore().collection(ENTRIES).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Ooops, something went wrong. \(error.localizedDescription)")
                self?.isLoading = false
                self?.showAlert("Error", "Ooops, something went wrong. \(error.localizedDescription)")
            } else {
                print("Loaded data from Firebase")
                self?.processData(querySnapshot!.documents)
                self?.isLoading = false
            }
        }
    }
    
    private func processData(_ documents: [QueryDocumentSnapshot]) {
        let today = Date()
        let sevendDaysAgo = today - 7
        let fourteenDaysAgo = today - 14
        var lastSevenDaysEntryCount = 0
        var previousSevenDaysEntryCount = 0
        
        self.sevenDaysCaloriesByUser.removeAll()
        
        for document in documents {
            let data = document.data()
            let calorie = data[ENTRY_CALORIE] as? Int ?? 0
            let dateInMill = data[ENTRY_DATE] as? Int64 ?? 0
            let date = Date(milliseconds: dateInMill)
            let userId = data[ENTRY_USER_ID] as? String ?? ""
            
            if date >= sevendDaysAgo {
                if let _ = sevenDaysCaloriesByUser[userId] {
                    sevenDaysCaloriesByUser[userId]! += calorie
                } else {
                    sevenDaysCaloriesByUser[userId] = calorie
                }
            }
            
            if date >= fourteenDaysAgo {
                if date >= sevendDaysAgo {
                    lastSevenDaysEntryCount += 1
                } else {
                    previousSevenDaysEntryCount += 1
                }
            }
        }
        
        self.lastSevenDaysNumberOfEntries = lastSevenDaysEntryCount
        self.previousSevenDaysNumberOfEntries = previousSevenDaysEntryCount
        self.users = Array(sevenDaysCaloriesByUser.keys)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: ReportTableViewCell.id, bundle: nil), forCellReuseIdentifier: ReportTableViewCell.id)
    }
}


// MARK: UITableViewDelegate
extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sevenDaysCaloriesByUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportTableViewCell.id, for: indexPath) as? ReportTableViewCell else {
            return UITableViewCell()
        }
        
        let user = users[indexPath.row]
        cell.configure(user: user, calories: sevenDaysCaloriesByUser[user]!/7)

        return cell
    }

}
