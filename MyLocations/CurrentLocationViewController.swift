//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Yixin Xue on 2/21/17.
//  Copyright © 2017 Yixin Xue. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController , CLLocationManagerDelegate{
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    var timer: Timer?
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        if(error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        // 1
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        // 2
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        // 3
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            // 4
            lastLocationError = nil
            location = newLocation
            updateLabels()
            // 5
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                print("*** We're done!")
                stopLocationManager()
                configureGetButton()
                
                if distance > 0{
                    performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding{
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler:
                    // Closure, placemark and error are parameters
                    {placemark, error in
                        print("*** Found placemarks: \(placemark), error: \(error)")
                        self.lastLocationError = error
                        if error == nil, let p = placemark, !p.isEmpty{
                            self.placemark = p.last!
                        }else{
                            self.placemark = nil
                        }
                        self.performingReverseGeocoding = false
                        self.updateLabels()
                    }
                )
            }
        }else if distance < 1{
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10{
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    @IBAction func getLocation() {
        //Ask for authorization
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation{
            stopLocationManager()
        }else{
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func updateLabels(){
        if let location = location{
            latitudeLabel.text = String(format:"%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        }else{
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as? NSError{
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue{
                    statusMessage = "Location Services Disabled"
                }else{
                    statusMessage = "Error Getting Location"
                }
            }else if !CLLocationManager.locationServicesEnabled(){
                statusMessage = "Location Services Disabled"
            }else if updatingLocation{
                statusMessage = "Searching..."
            }else{
                statusMessage = "Tap 'Het My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager(){
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func configureGetButton(){
        if updatingLocation{
            getButton.setTitle("Stop", for: .normal)
        }else{
            getButton.setTitle("Get MyLocation", for: .normal)
        }
    }
    
    func string(from placemark: CLPlacemark) -> String{
        var line1 = ""
        if let s = placemark.subThoroughfare{
            line1 += s + " "
        }
        if let s = placemark.thoroughfare {
            line1 += s }
        
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
    
    // Called after one minute out
    func didTimeOut(){
        print("*** Time out")
        
        if location == nil{
            stopLocationManager()
            
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation"{
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
}

