//
//  firstScreenVC.swift
//  CityGuidePro
//
//  Updated by AJ
//

import UIKit

class firstScreenVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

        
    @IBOutlet var pickerView: UIPickerView!
    let words = ["Difficulty Seeing" , "General User" , "Limited Mobility"]
    var chosenWord: String?
    var chosenWordIndex: Int = 0

      override func viewDidLoad() {
          super.viewDidLoad()
          
          pickerView.delegate = self
          pickerView.dataSource = self
          
          // Load the chosen word from UserDefaults
          chosenWord = UserDefaults.standard.string(forKey: "chosenWord")
          if let chosenWord = chosenWord, let index = words.firstIndex(of: chosenWord) {
              pickerView.selectRow(index, inComponent: 0, animated: false)
          }
      }

      // Number of columns in the picker view
      func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
      }

      // Number of rows in the picker view
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          return words.count
      }

      // Title for each row in the picker view
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
          return words[row]
      }

      // Handle selection of a row in the picker view
      func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
          chosenWord = words[row]

          
          if(chosenWord=="Difficulty Seeing"){
              chosenWord = "Difficulty Seeing"

              chosenWordIndex = 0

          }else if(chosenWord=="General User"){
              chosenWordIndex = 1
              chosenWord = "General User"



          }else if(chosenWord=="Limited Mobility"){
              chosenWordIndex = 2
              chosenWord = "Limited Mobility"



          }
          
      }
    
    
    @IBAction func SubmitButtonActionFC(_ sender: Any) {
        UserDefaults.standard.set(chosenWordIndex, forKey: "chosenWordIndex")

//        let usernameValue = userNameTxt3.text
//        let phoneNumberValue = phoneNumberTxt3.text
//        userDefaults.set(usernameValue, forKey: "myContactUserNameKey3")
//        userDefaults.set(phoneNumberValue, forKey: "myContactUserNumberKey3")
        showToast(message: "Selection saved!", seconds: 1.0)

//        showToast(message: "Saved Successfully as \(chosenWord) ", seconds: 1.0)
        
        self.dismiss(animated: true, completion: nil)

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
    
    
    
    @IBAction func CancelButtonActionFC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }

}


