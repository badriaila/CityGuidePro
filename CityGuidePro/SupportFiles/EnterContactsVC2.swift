//
//  EnterContactsVC.swift
//  CityGuidePro
//
//  Updated by AJ
//

import UIKit

class EnterContactsVC2: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var userNametext2: UITextField!
    
    @IBOutlet weak var phoneNumberText2: UITextField!
    
    
    @IBOutlet weak var SubmitButton2: UIButton!
    
    
    @IBOutlet weak var CancelButton2: UIButton!
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi2()


        // Do any additional setup after loading the view.
    }
    
    func setupUi2() {
        SubmitButton2.isEnabled = false

        userNametext2.delegate = self
        userNametext2.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        phoneNumberText2.delegate = self
        phoneNumberText2.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange(textField _: UITextField) {
        enableDisableButton()
    }
    
    private func enableDisableButton() {
        let buttonState = userNametext2.text?.count ?? 0 > 2
        SubmitButton2.isEnabled = buttonState
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
    
    
    @IBAction func SubmitButton2Action(_ sender: Any) {
        let usernameValue = userNametext2.text
        let phoneNumberValue = phoneNumberText2.text
        userDefaults.set(usernameValue, forKey: "myContactUserNameKey2")
        userDefaults.set(phoneNumberValue, forKey: "myContactUserNumberKey2")
        showToast(message: "Saved Successfully", seconds: 1.0)
        
    }
    
    
    @IBAction func CancelButton2Action(_ sender: Any) {
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
