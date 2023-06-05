//
//  EntriesViewController.swift
//  CalorieApp
//
//  Created by Workspace on 20/04/22.
//

import UIKit
import Firebase
import Kingfisher

class EntriesViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    var isAdmin = false
    
    private var entries = [Entry]() {
        didSet { calculateDailyLimits() }
    }
    private var preFilterEntries: [Entry]?
    private var dailyTotals = [String: Int]()
    private var dailyCalorieLimit: Int!
    private var fromDatePicker: UIDatePicker!
    private var toDatePicker: UIDatePicker!
    
    // MARK: Actions
    
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        retreiveData()
    }
    
    @IBAction func clearTapped(_ sender: UIButton) {
        if let preFilterEntries = preFilterEntries {
            entries = preFilterEntries
            self.preFilterEntries = nil
        }
        
        fromTextField.text = ""
        toTextField.text = ""
        toTextField.isEnabled = false
        filterButton.isEnabled = false
        self.view.endEditing(true)
    }
    
    @IBAction func filterTapped(_ sender: UIButton) {
        guard let from = fromTextField.text, !from.isEmpty else { return }
        guard let to = toTextField.text, !to.isEmpty else { return }
        
        if preFilterEntries == nil {
            preFilterEntries = entries
        }
        
        self.view.endEditing(true)
        
        entries = preFilterEntries!.filter {
            $0.date.equalOrAfter(fromDatePicker.date)
            &&
            $0.date.equalOrBefore(toDatePicker.date)
        }
    }
    
    @objc func fromDoneTapped() {
        fromTextField.text = fromDatePicker.date.stringDate
        self.view.endEditing(true)
        
        toTextField.text = ""
        toTextField.isEnabled = true
        toDatePicker.minimumDate = fromDatePicker.date
        filterButton.isEnabled = false
    }
    
    @objc func toDoneTapped() {
        toTextField.text = toDatePicker.date.stringDate
        self.view.endEditing(true)
        filterButton.isEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_ENTRY_FORM_ID {
            guard let vc = segue.destination as? EntryFormViewController else { return }
            vc.isAdmin = isAdmin
        }
    }
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupTableView()
        setupDatePicker()
        loadUserSettings()
        retreiveData()
        subscribeToNotifications()
        
        if isAdmin {
            hideFilter()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Private Methods
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: EntryTableViewCell.id, bundle: nil), forCellReuseIdentifier: EntryTableViewCell.id)
    }
    
    private func setupDatePicker() {
        
        let fromToolbar = UIToolbar()
        fromToolbar.sizeToFit()
        
        fromDatePicker = UIDatePicker()
        fromDatePicker.datePickerMode = .date
        fromDatePicker.preferredDatePickerStyle = .wheels

        let fromDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(fromDoneTapped))
        fromToolbar.setItems([fromDoneButton], animated: true)
        fromTextField.inputAccessoryView = fromToolbar
        fromTextField.inputView = fromDatePicker
        
        let toToolbar = UIToolbar()
        toToolbar.sizeToFit()
        
        toDatePicker = UIDatePicker()
        toDatePicker.datePickerMode = .date
        toDatePicker.preferredDatePickerStyle = .wheels
        
        let toDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(toDoneTapped))
        toToolbar.setItems([toDoneButton], animated: true)
        toTextField.inputAccessoryView = toToolbar
        toTextField.inputView = toDatePicker
        
        toTextField.isEnabled = false
        filterButton.isEnabled = false
    }
    
    private func calculateDailyLimits() {
        self.dailyTotals.removeAll()
        
        for entry in entries {
            let stringDate = entry.date.stringDate
            if let _ = self.dailyTotals[stringDate] {
                self.dailyTotals[stringDate]! += entry.calorie
            } else {
                self.dailyTotals[stringDate] = entry.calorie
            }
        }
        
        tableView.reloadData()
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(retreiveData), name: NOTIFICATIONS_DATA_UPDATE, object: nil)
    }
    
    private func loadUserSettings() {
        let userId = UserDefaults.standard.string(forKey: USER_ID) ?? ""
        dailyCalorieLimit = UserDefaults.standard.integer(forKey: DAILY_CALORIE_LIMIT + userId)
    }
    
    private func hideFilter() {
        tableViewTopConstraint.constant = -fromTextField.frame.height
        fromTextField.isHidden = true
        toTextField.isHidden = true
        filterButton.isHidden = true
        clearButton.isHidden = true
    }
}

// MARK: UITableViewDelegate
extension EntriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EntryTableViewCell.id, for: indexPath) as? EntryTableViewCell else {
            return UITableViewCell()
        }
        
        let entry = entries[indexPath.row]
        
        if isAdmin {
            cell.configure(with: entry)
        } else {
            let dailyTotal = dailyTotals[entries[indexPath.row].date.stringDate]!
            let currentItemDate = entry.date.stringDate
            var isSameDay = false
            
            if entries.indices.contains(indexPath.row - 1) {
                let previousItemDate = entries[indexPath.row - 1].date.stringDate
                isSameDay = previousItemDate == currentItemDate
            }
            
            cell.configure(with: entry, isSameDay, dailyTotal, dailyCalorieLimit)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            self.deleteEntryById(self.entries[indexPath.row].id)
            completion(true)
        }
        deleteAction.image = .trash
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let vc = storyboard.instantiateViewController(withIdentifier: "EntryFormViewControllerID") as? EntryFormViewController {
                vc.entry = self.entries[indexPath.row]
                vc.isAdmin = self.isAdmin
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true)
            }
            completion(true)
        }
        editAction.image = .edit
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

// MARK: Firebase
extension EntriesViewController {
    
    @objc func retreiveData() {
        if isAdmin {
            retreiveDataForAdmin()
        } else {
            retreiveDataForUser()
        }
    }
    
    private func retreiveDataForUser() {
        if !isReachable() { return }
        guard let userID = UserDefaults.standard.string(forKey: USER_ID) else { return }
        isLoading = true
        FirebaseManager.shared.getEntriesByUserId(userID) { (entries, error) in
            self.isLoading = false
            if let error = error {
                self.showAlert("Error", "Ooops, something went wrong. \(error.localizedDescription)")
            } else {
                self.entries = entries
            }
        }
    }
    
    private func retreiveDataForAdmin() {
        if !isReachable() { return }
        isLoading = true
        FirebaseManager.shared.getAllEntries { (entries, error) in
            self.isLoading = false
            if let error = error {
                self.showAlert("Error", "Ooops, something went wrong. \(error.localizedDescription)")
            } else {
                self.entries = entries
            }
        }
    }
    
    private func deleteEntryById(_ id: String) {
        let confirmationAlert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this entry", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "No", style: .cancel)
        confirmationAlert.addAction(dismissAction)
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let strongSelf = self else { return }
            if !strongSelf.isReachable() { return }
            strongSelf.isLoading = true
            FirebaseManager.shared.deleteEntryById(id) { [weak self] error in
                if let error = error {
                    print("Ooops, something went wrong. \(error.localizedDescription)")
                    self?.isLoading = false
                    self?.showAlert("Error", "Ooops, something went wrong. \(error.localizedDescription)")
                } else {
                    print("Successfully deleted!")
                    self?.retreiveData()
                }
            }
        }
        confirmationAlert.addAction(deleteAction)
        
        self.present(confirmationAlert, animated: true)
    }
}
