//
//  BaseViewController.swift
//  CalorieApp
//
//  Created by Workspace on 21/04/22.
//

import UIKit

class BaseViewController: UIViewController {
    
    var isLoading = false {
        didSet {
            if isLoading {
                spinnerContainer.isHidden = false
                spinner.startAnimating()
            } else {
                spinnerContainer.isHidden = true
                spinner.stopAnimating()
            }
        }
    }
    
    private var spinnerContainer: UIView!
    private var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .light
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        spinnerContainer = UIView()
        spinnerContainer.backgroundColor = .black.withAlphaComponent(0.3)
        spinnerContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinnerContainer)
        spinnerContainer.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        spinnerContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        spinnerContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        spinnerContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        spinnerContainer.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerYAnchor.constraint(equalTo: spinnerContainer.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: spinnerContainer.centerXAnchor).isActive = true
        
        spinnerContainer.isHidden = true
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func isReachable() -> Bool {
        if !Reachability.isConnectedToNetwork() {
            showAlert("Error", "Oops, something went wrong. No network connectivity")
            return false
        }
        return true
    }

}
