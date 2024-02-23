//
//  CustomPopUpViewController.swift
//  CityGuidePro
//
//  Updated by AJ
//

import UIKit
import CoreLocation

enum CustomAlertScreenScenario {
    case call911
    case sendLocation
}

final class CustomPopUpViewController: UIViewController {
    
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var messageString = ""
    var appVersion = ""
    var customAlertScenario: CustomAlertScreenScenario?
    var locationManager = CLLocationManager()
    var lat: Double?
    var long: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
        setupUI()
        scenario()
    }
    
    private func scenario() {
        switch customAlertScenario {
        case .call911:
            descriptionLabel.text = "Are you sure you want to call 911?"
        case .sendLocation:
            descriptionLabel.text = "Are you sure you want to share your location information with all your contacts?"
        default:
            break
        }
    }
    func setupUI() {
        popUpView.backgroundColor = .white
        popUpView.layer.shadowOpacity = 0.1
        popUpView.layer.cornerRadius = 16
        noButton.layer.cornerRadius = 5
        yesButton.layer.cornerRadius = 5
        
        yesButton.layer.borderColor = UIColor.white.cgColor
        yesButton.layer.borderWidth = 1
        yesButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        yesButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        yesButton.layer.shadowOpacity = 0.8
        yesButton.layer.shadowRadius = 5.0
        yesButton.layer.masksToBounds = false
        
        noButton.layer.borderColor = UIColor.white.cgColor
        noButton.layer.borderWidth = 1
        noButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        noButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        noButton.layer.shadowOpacity = 0.8
        noButton.layer.shadowRadius = 5.0
        noButton.layer.masksToBounds = false
    }
    
    @IBAction func yesButtonAction(_ sender: Any) {
        switch customAlertScenario {
        case .call911:
            guard let phoneCallURL = URL(string: "tel://911") else {
                return
            }
            let application = UIApplication.shared
            guard application.canOpenURL(phoneCallURL) else {
                return
            }
            
            application.open(phoneCallURL, options: [:], completionHandler: nil)
        case .sendLocation:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        switch customAlertScenario {
        case .call911:
            dismiss(animated: true, completion: nil)
        case .sendLocation:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    private func getUserLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
}

extension CustomPopUpViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first {
            lat = userLocation.coordinate.latitude
            long = userLocation.coordinate.longitude
        }
    }
}
