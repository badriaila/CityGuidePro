//
//  ContactVC.swift
//  CityGuidePro
//
//  Updated by AJ
//

import UIKit

import Foundation

import MapKit
import AVFoundation
import CoreHaptics
import Speech
import CoreLocation


class ContactVC: UIViewController, CLLocationManagerDelegate, AVSpeechSynthesizerDelegate, SFSpeechRecognizerDelegate {
    
    let locationManager = CLLocationManager()
    
    let narator = AVSpeechSynthesizer()
    var speechRecognizer = SpeechRecognizer()
    var speechFlag = false
    var muteFlag = false
    var explorationFlag = true
    var voiceSearchFlag = false

    
    @IBOutlet weak var callView: CustomShadowView!
    @IBOutlet weak var sendLocationView: CustomShadowView!
    @IBOutlet weak var shareLocationOneView: CustomShadowView!
    @IBOutlet weak var editContactView: CustomShadowView!
    @IBOutlet weak var shareLocationtwoView: CustomShadowView!
    @IBOutlet weak var editContactTwoView: CustomShadowView!
    @IBOutlet weak var shareLocationThreeView: CustomShadowView!
    @IBOutlet weak var editContactThreeView: CustomShadowView!
    @IBOutlet weak var shareLocationBtnOne: UIButton!
    @IBOutlet weak var editContactBtnOne: UIButton!
    @IBOutlet weak var shareLocationBtnTwo: UIButton!
    @IBOutlet weak var editContactBtnTwo: UIButton!
    @IBOutlet weak var shareLocationBtnThree: UIButton!
    @IBOutlet weak var editContactBtnThree: UIButton!
    
    
    @IBOutlet weak var editContactOne: UIButton!
    @IBOutlet weak var editContactTwo: UIButton!
    @IBOutlet weak var editContactThree: UIButton!
    
    @IBOutlet weak var userNameOne: UILabel!
    @IBOutlet weak var userNameTwo: UILabel!
    @IBOutlet weak var userNameThree: UILabel!
    
    @IBOutlet weak var callContactOne: UIButton!
    @IBOutlet weak var callContactTwo: UIButton!
    @IBOutlet weak var callContactThree: UIButton!
    
    @IBOutlet weak var messageContactOne: UIButton!
    @IBOutlet weak var messageContactTwo: UIButton!
    @IBOutlet weak var messageContactThree: UIButton!
    
    @IBOutlet weak var videoContactOne: UIButton!
    @IBOutlet weak var videoContactTwo: UIButton!
    @IBOutlet weak var videoContactThree: UIButton!
    
    @IBOutlet weak var ContactUserNameLabel1: UILabel!


    @IBOutlet weak var ContactUserNameLabel2: UILabel!
    
    
    @IBOutlet weak var ContactUserNameLabel3: UILabel!
    
    
    
    @IBOutlet weak var Contact1stRowNameLabel: UILabel!
    
    
    
    @IBOutlet weak var Contact1stRowMessage: UILabel!
    
    
    @IBOutlet weak var Contact1stRowVideo: UILabel!
    
        
    @IBOutlet weak var MsgIn2ndRow: UILabel!
    @IBOutlet weak var VideoIn2ndRow: UILabel!
    
    
    @IBOutlet weak var ThirdRowTopLabel: UILabel!
    
    
    @IBOutlet weak var ThirdRowMsg: UILabel!
    
    
    @IBOutlet weak var ThirdRowVideo: UILabel!
    
    let userDefaults = UserDefaults.standard
    
   
    
    let BTNlocationManager = CLLocationManager()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.barTintColor = .black
        //title = "Contacts"
//        let cp1=HomeVC()
        
//        speakThis(sentence: "Contact")
        setupUi()
        BTNlocationManager.delegate = self

        BTNlocationManager.requestWhenInUseAuthorization()

        //    shareLocationBtnOne.tag = 0
        
        
        locationManager.requestAlwaysAuthorization()
               locationManager.requestWhenInUseAuthorization()
               if CLLocationManager.locationServicesEnabled() {
//                   locationManager.delegate = self
                   locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                   locationManager.startUpdatingLocation()
               }
        
    }
    
    func setupUi() {
        shareLocationOneView.layer.cornerRadius = 20
        editContactView.layer.cornerRadius = 20
        
        shareLocationtwoView.layer.cornerRadius = 20
        editContactTwoView.layer.cornerRadius = 20
        
        shareLocationThreeView.layer.cornerRadius = 20
        editContactThreeView.layer.cornerRadius = 20
        
        shareLocationBtnOne.tag = 1
        shareLocationBtnTwo.tag = 2
        shareLocationBtnThree.tag = 3
        
        editContactOne.tag = 1
        editContactTwo.tag = 2
        editContactThree.tag = 3
        
        callContactOne.tag = 1
        callContactTwo.tag = 2
        callContactThree.tag = 3
        
        messageContactOne.tag = 1
        messageContactTwo.tag = 2
        messageContactThree.tag = 3
        
        videoContactOne.tag = 1
        videoContactTwo.tag = 2
        videoContactThree.tag = 3
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            BTNlocationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Handle denied or restricted authorization
            break
        default:
            break
        }
    }
    
    var latestLocation: CLLocation?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else {
                    return
                }
                let latitude = latestLocation.coordinate.latitude
                let longitude = latestLocation.coordinate.longitude
                print("Latitude: \(latitude), Longitude: \(longitude)")    }
    
    @IBAction func actionForCallBtn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CustomPopUpViewController") as! CustomPopUpViewController
        vc.customAlertScenario = .call911
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        speakThis(sentence: "Call 911")
    }
    func speakThis(sentence : String){
        let audioSession = AVAudioSession.sharedInstance()
        do
        {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setMode(AVAudioSession.Mode.default)
            //try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }
        catch
        {
            print("audioSession properties weren't set because of an error.")
        }
        
        //
        var user = 1
        let userProfile = UserDefaults.standard.value(forKey: "checkmarks") as? [String:Int]
        if userProfile == nil{
            user = 0
        }
        else if !userProfile!.isEmpty{
            user = userProfile!["User Category"]!
        }
        
        let utterance = AVSpeechUtterance(string: sentence)
        if user == 0{
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.7
        }
        else{
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.55
        }
        
        if(narator.isSpeaking && explorationFlag && voiceSearchFlag){
            narator.stopSpeaking(at: .immediate)
        }
        
        if !muteFlag{
            //to add speech transcription for enhancing functionality
            narator.speak(utterance)
        }
        else{
            narator.stopSpeaking(at: .immediate)
        }
    }

    
    @IBAction func actionForSendLocationBtn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CustomPopUpViewController") as! CustomPopUpViewController
        vc.customAlertScenario = .sendLocation
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        speakThis(sentence: "Send location to all contacts?")

    }
    
    @IBAction func actionForEditContact(_ sender: UIButton) {
        if sender.tag == 1 {
            let vc = self.storyboard?.instantiateViewController(identifier: "EnterContactsVC1") as! EnterContactsVC1
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
            speakThis(sentence: "Modify Contact Information 1")

            
//
            
        } else if sender.tag == 2 {
            let vc = self.storyboard?.instantiateViewController(identifier: "EnterContactsVC2") as! EnterContactsVC2
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
            speakThis(sentence: "Modify Contact Information 2")

        } else if sender.tag == 3 {
            let vc = self.storyboard?.instantiateViewController(identifier: "EnterContactsVC3") as! EnterContactsVC3
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
            speakThis(sentence: "Modify Contact Information 3")

        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let usernameStr1 = userDefaults.string(forKey: "myContactUserNameKey1")
        
        
        let usernameStr2 = userDefaults.string(forKey: "myContactUserNameKey2")

        let usernameStr3 = userDefaults.string(forKey: "myContactUserNameKey3")

//        ContactUserNameLabel1.text = "Call \(usernameStr1 ?? "NoName")"
        
//        Contact1stRowNameLabel.text = " \(usernameStr1 ?? "NoName")"
        
//        Contact1stRowMessage.text = "Message \(usernameStr1 ?? "NoName")"
//
//        Contact1stRowVideo.text = "Video \(usernameStr1 ?? "NoName")"
        
        
        
        
//        ContactUserNameLabel2.text = "Call \(usernameStr2 ?? "NoName")"
        
//        MsgIn2ndRow.text = "Message \(usernameStr2 ?? "NoName")"
//
//        VideoIn2ndRow.text = "Video \(usernameStr2 ?? "NoName")"
//

        
        
        

//        ContactUserNameLabel3.text = "Call \(usernameStr3 ?? "NoName")"
        
//        ThirdRowVideo.text = "Video \(usernameStr3 ?? "NoName")"

        
//        ThirdRowMsg.text = "Message \(usernameStr3 ?? "NoName")"
//
//        ThirdRowTopLabel.text = " \(usernameStr3 ?? "NoName")"

        
       

        
        
        // Hides the stop icon
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if let usernameStr = userDefaults.string(forKey: "myContactUserNameKey3") {
//            ContactUserNamelabel3.text = "Call \(usernameStr)!"
//        }
//        // Hides the stop icon
//    }
    
    //    @IBAction func editContactBtnOne(_ sender:Any){
    //        let vc = self.storyboard?.instantiateViewController(identifier: "EditDetailsVC") as! EditDetailsVC
    //
    //        let EmergencyContactName = textInputMode
    //        let EmergencyContactNumber = textInputMode
    //
    //        vc.modalTransitionStyle = .crossDissolve
    //        vc.modalPresentationStyle = .overCurrentContext
    //        self.present(vc, animated: true, completion: nil)
    //    }
    //
    //    @IBAction func editContactBtnTwo(_ sender:Any){
    //        let vc = self.storyboard?.instantiateViewController(identifier: "EditDetailsVC") as! EditDetailsVC
    //
    //        let EmergencyContactName = textInputMode
    //        let EmergencyContactNumber = textInputMode
    //
    //        vc.modalTransitionStyle = .crossDissolve
    //        vc.modalPresentationStyle = .overCurrentContext
    //        self.present(vc, animated: true, completion: nil)
    //    }
    //
    //    @IBAction func editContactBtnThree(_ sender:Any){
    //        let vc = self.storyboard?.instantiateViewController(identifier: "EditDetailsVC") as! EditDetailsVC
    //
    //        let EmergencyContactName = textInputMode
    //        let EmergencyContactNumber = textInputMode
    //
    //        vc.modalTransitionStyle = .crossDissolve
    //        vc.modalPresentationStyle = .overCurrentContext
    //        self.present(vc, animated: true, completion: nil)
    //    }
    //
    //    @IBAction func shareLocationBtnOne(_ sender:Any){
    //        let vc = self.storyboard?.instantiateViewController(identifier: "EditDetailsVC") as! EditDetailsVC
    //
    //       // vc.customAlertScenario = .sendLocation
    //
    //        vc.modalTransitionStyle = .crossDissolve
    //        vc.modalPresentationStyle = .overCurrentContext
    //        self.present(vc, animated: true, completion: nil)
    //    }
    //
    //    @IBAction func shareLocationBtnTwo(_ sender:Any){
    //        let vc = self.storyboard?.instantiateViewController(identifier: "EditDetailsVC") as! EditDetailsVC
    //
    //        //vc.customAlertScenario = .sendLocation
    //
    //        vc.modalTransitionStyle = .crossDissolve
    //        vc.modalPresentationStyle = .overCurrentContext
    //        self.present(vc, animated: true, completion: nil)
    //    }
    //
    //    @IBAction func shareLocationBtnThree(_ sender:Any){
    //        let vc = self.storyboard?.instantiateViewController(identifier: "EditDetailsVC") as! EditDetailsVC
    //
    //       // vc.customAlertScenario = .sendLocation
    //
    //        vc.modalTransitionStyle = .crossDissolve
    //        vc.modalPresentationStyle = .overCurrentContext
    //        self.present(vc, animated: true, completion: nil)
    //    }
    
    
    @IBAction func ActionForCallUserBtn(_ sender: UIButton) {
        if sender.tag == 1 {
            
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey1")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
           


            
            speakThis(sentence: "Call Contact 1")

            if let phoneCallURL = URL(string: "tel://\(ss)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                }
              }
            
            
            
        } else if sender.tag == 2 {
            
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey2")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
         

            speakThis(sentence: "Call Contact 2")

            
            if let phoneCallURL = URL(string: "tel://\(ss)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                }
              }
            
            
            
        } else if sender.tag == 3 {
            
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey3")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
            

            
            speakThis(sentence: "Call Contact 3")

            if let phoneCallURL = URL(string: "tel://\(ss)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                }
              }
            
            
        }
    }
    
    @IBAction func actionForMessageBtn(_ sender: UIButton) {
        if sender.tag == 1 {
            
            //
            
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey1")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
            let sms = "sms:\(ss)&body= Hi, I need your assistance please."
            let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL(string: strURL)!, options: [:], completionHandler: nil)
            
            
            
            
            speakThis(sentence: "Message Contact 1")

            
        } else if sender.tag == 2 {
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey2")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
            let sms = "sms:\(ss)&body= Hi, I need your assistance please."
            let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL(string: strURL)!, options: [:], completionHandler: nil)
            
            
            speakThis(sentence: "Message Contact 2")

            
        } else if sender.tag == 3 {
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey3")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
            let sms = "sms:\(ss)&body= Hi, I need your assistance please."
            let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL(string: strURL)!, options: [:], completionHandler: nil)
            
            speakThis(sentence: "Message Contact 3")

            
            
        }
    }
    
    @IBAction func actionForVideoBtn(_ sender: UIButton) {
        if sender.tag == 1 {
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey1")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
            UIApplication.shared.openURL(NSURL(string: "facetime://\(ss)") as! URL)

            
            speakThis(sentence: "Video Call Contact 1")

            
        } else if sender.tag == 2 {
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey2")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
            UIApplication.shared.openURL(NSURL(string: "facetime://\(ss)") as! URL)

            
            speakThis(sentence: "Video Call Contact 2")

            
        } else if sender.tag == 3 {
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey3")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
            
            UIApplication.shared.openURL(NSURL(string: "facetime://\(ss)") as! URL)

            speakThis(sentence: "Video Call Contact 3")

            
        }
    }
    
    @IBAction func actionForShareLocationUser(_ sender: UIButton) {
        
//        guard let locationDEE = latestLocation else {
//                print("Location not available")
//                return
//            }
//
//            let latitude = locationDEE.coordinate.latitude
//            let longitude = locationDEE.coordinate.longitude
//
//            print("Latitude: \(latitude), Longitude: \(longitude)")
        
        let locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
            // Retrieve the current location coordinates
            guard let locationDEE = locationManager.location?.coordinate else {
                print("Unable to retrieve location coordinates")
                return
            }
        
        let latitude = locationDEE.latitude
        let longitude = locationDEE.longitude
        
        if sender.tag == 1 {
            
           
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey1")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
//            let sms = "sms:\(ss)&body= Hi, I'm stuck at this location. Kindly help, From CityGuide!"

            let sms = "sms:\(ss)&body=My current location coordinates are: \nLatitude: \(latitude), Longitude: \(longitude) \n\nHere is the link to my location on Google Maps: \nhttps://www.google.com/maps/@\(latitude),\(longitude),18z"
            let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL(string: strURL)!, options: [:], completionHandler: nil)
            
            
            speakThis(sentence: "Share location with contact 1")

            
            
        } else if sender.tag == 2 {
            
            
            
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey2")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
//            let sms = "sms:\(ss)&body= Hi, I'm stuck at this location. Kindly help, From CityGuide!"

            let sms = "sms:\(ss)&body=My current location coordinates are: \nLatitude: \(latitude), Longitude: \(longitude) \n\nHere is the link to my location on Google Maps: \nhttps://www.google.com/maps/@\(latitude),\(longitude),18z"
            let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL(string: strURL)!, options: [:], completionHandler: nil)
            
            speakThis(sentence: "Share location with contact 2")

            
            
            
        } else if sender.tag == 3 {
            
          
            
            let phoneNumber = userDefaults.string(forKey: "myContactUserNumberKey3")
            
            let ss = "\(phoneNumber ?? "xxx xxx xxxx")"
            
            
            let sms = "sms:\(ss)&body=My current location coordinates are: \nLatitude: \(latitude), Longitude: \(longitude) \n\nHere is the link to my location on Google Maps: \nhttps://www.google.com/maps/@\(latitude),\(longitude),18z"
//            let sms = "sms:\(ss)&body= Hi, I'm stuck at this location. Kindly help, the coordinates are Latitude: \(latitude), Longitude: \(longitude)!"

//            let sms = "sms:\(ss)&body= Hi, I'm stuck at this location. Kindly help, From CityGuide!"
            let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL(string: strURL)!, options: [:], completionHandler: nil)
            
            
            speakThis(sentence: "Share location with contact 3")

            
            
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//            print("locations =========== \(locValue.latitude) \(locValue.longitude)")
//        }
}
