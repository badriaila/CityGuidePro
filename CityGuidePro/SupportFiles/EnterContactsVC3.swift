//
//  EnterContactsVC.swift
//  CityGuidePro
//
//  Updated by AJ
//

import UIKit

class EnterContactsVC3: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTxt3: UITextField!
    
    
    @IBOutlet weak var phoneNumberTxt3: UITextField!
    
    
    @IBOutlet weak var submitButton3: UIButton!
    
    
    @IBOutlet weak var cancelButton3: UIButton!
    
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi2()


        // Do any additional setup after loading the view.
    }
    
    func setupUi2() {
        submitButton3.isEnabled = false

        userNameTxt3.delegate = self
        userNameTxt3.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        phoneNumberTxt3.delegate = self
        phoneNumberTxt3.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange(textField _: UITextField) {
        enableDisableButton()
    }
    
    private func enableDisableButton() {
        let buttonState = userNameTxt3.text?.count ?? 0 > 2
        submitButton3.isEnabled = buttonState
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
    
    
    
    @IBAction func SubmitButton3Action(_ sender: Any) {
        let usernameValue = userNameTxt3.text
        let phoneNumberValue = phoneNumberTxt3.text
        userDefaults.set(usernameValue, forKey: "myContactUserNameKey3")
        userDefaults.set(phoneNumberValue, forKey: "myContactUserNumberKey3")
        showToast(message: "Saved Successfully", seconds: 1.0)
    }
    
    
    
    @IBAction func CancelButton3Action(_ sender: Any) {
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
