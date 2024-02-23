//
//  EnterContactsVC.swift
//  CityGuidePro
//
//  Updated by AJ
//

import UIKit

class EnterContactsVC1: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameTxt: UITextField!
    
    @IBOutlet weak var PhoneNumberTxt: UITextField!
    
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    @IBOutlet weak var CancelButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi2()


        // Do any additional setup after loading the view.
    }
    
    func setupUi2() {
        submitButton.isEnabled = false
        submitButton.isEnabled = false

        usernameTxt.delegate = self
        usernameTxt.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange(textField _: UITextField) {
        enableDisableButton()
    }
    
    private func enableDisableButton() {
        let buttonState = usernameTxt.text?.count ?? 0 > 2
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
        let phoneNumberValue = PhoneNumberTxt.text
        userDefaults.set(usernameValue, forKey: "myContactUserNameKey1")
        userDefaults.set(phoneNumberValue, forKey: "myContactUserNumberKey1")
        showToast(message: "Saved Successfully", seconds: 1.0)
    }
    
    
   
    
    @IBAction func CancelBtnClicked(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
