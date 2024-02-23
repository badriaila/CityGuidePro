//
//  ProfileVC.swift
//  CityGuidePro
//
//  Updated by AJ
//

import UIKit

class ProfileVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    let userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        
    }
    
    func setupUi() {
        submitButton.isEnabled = false
        usernameTxt.delegate = self
        usernameTxt.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange(textField _: UITextField) {
        enableDisableButton()
    }
    
    private func enableDisableButton() {
        let buttonState = usernameTxt.text?.count ?? 0 >= 1
        submitButton.isEnabled = buttonState
    }
    
    func showToast(message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.alpha = 0.8
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: false)
        }
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        let usernameValue = usernameTxt.text
        userDefaults.set(usernameValue, forKey: "myUserNameKey")
        showToast(message: "Saved Successfully", seconds: 1.0)
    }
}
