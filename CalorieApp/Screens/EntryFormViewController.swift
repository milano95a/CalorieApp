//
//  EntryFormViewController.swift
//  CalorieApp
//
//  Created by Workspace on 21/04/22.
//

import UIKit
import Firebase
import Kingfisher

class EntryFormViewController: BaseViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var calorieTextView: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var userTextView: UITextField!
    @IBOutlet weak var warningLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateTextField: UITextField!
    
    var entry: Entry?
    var users = [String]()
    var isAdmin = false
    
    private var image: UIImage? {
        didSet { imageView.image = image }
    }
    private var datePicker: UIDatePicker!
    
    @IBAction func saveTapped(_ sender: UIButton) {
        var userID = UserDefaults.standard.string(forKey: USER_ID) ?? ""
        
        guard let name = nameTextView.text, !name.isEmpty, name.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "name is not valid"
            return
        }
        guard let calorieStr = calorieTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !calorieStr.isEmpty else {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "calorie is not valid"
            return
        }
        guard let calorie = Int(calorieStr), calorie > 0 else {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "calorie is not valid"
            return
        }
        if isAdmin {
            guard let user = userTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !user.isEmpty, isValidEmail(user) else {
                errorMessageLabel.isHidden = false
                errorMessageLabel.text = "user is not valid"
                return
            }
            userID = user
        }
        guard let dateText = dateTextField.text, !dateText.isEmpty else {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "date field is empty"
            return
        }
        errorMessageLabel.isHidden = true
        
        if !isReachable() { return }
        
        isLoading = true

        if entry == nil {
            entry = Entry()
        }
        
        entry?.name = name
        entry?.calorie = calorie
        entry?.userId = userID
        entry?.date = datePicker.date
        
        FirebaseManager.shared.saveEntry(image?.jpegData(compressionQuality: 0.25), entry!) { error in
            if let error = error {
                self.isLoading = false
                self.showAlert("Error", "Ooops, something went wrong. \(error.localizedDescription)")
            } else {
                NotificationCenter.default.post(name: NOTIFICATIONS_DATA_UPDATE, object: nil)
                self.dismiss(animated: true)
                self.isLoading = false
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func imageTapped() {
        ImagePickerManager().pickImage(self) { [weak self] pickedImage in
            self?.image = pickedImage
        }
    }
    
    @objc func doneTapped() {
        dateTextField.text = datePicker.date.stringDateAndTime
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if isAdmin {
            setupAdminUI()
        } else {
            setupUI()
        }
        
        if let entry = entry {
            populate(with: entry)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {

        }
    }
    
    private func setupUI() {
        setupGenericUI()
        
        userTextView.isHidden = true
        warningLabelTopConstraint.constant = -userTextView.frame.height
    }
    
    private func setupAdminUI() {
        setupGenericUI()
        
        userTextView.isHidden = false
        warningLabelTopConstraint.constant = 8
    }
    
    private func setupGenericUI(){
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.layer.cornerRadius = 10
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        errorMessageLabel.isHidden = true
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = .wheels

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneTapped))
        toolbar.setItems([doneButton], animated: true)
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        
        let toToolbar = UIToolbar()
        toToolbar.sizeToFit()
    }
    
    private func populate(with entry: Entry) {
        if !entry.imageURL.isEmpty {
            guard let url = URL(string: entry.imageURL) else { return }
            imageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .processor(DownsamplingImageProcessor(size: imageView.frame.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ],
                completionHandler: nil)
        }
        nameTextView.text = entry.name
        calorieTextView.text = "\(entry.calorie)"
        dateTextField.text = entry.date.stringDateAndTime
        datePicker.date = entry.date
        userTextView.text = entry.userId
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}
