//
//  HomePageViewController+MapExxtention.swift
//  User
//
//  Created by CSS on 06/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps



extension HomepageViewController : GMSMapViewDelegate,CLLocationManagerDelegate{
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            isGestureMoveMap = true
            self.hideView()
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if isGestureMoveMap {
            isGestureMoveMap = false
            self.showView()
        }
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }

    func showView(){ //MARK:- show ViewOffline View
//        if self.viewGoogleRetraction != nil {
//             self.viewGoogleRetraction.showAnimateView(self.viewGoogleRetraction, isShow: true, direction: .Bottom)
//        }
       
    self.rideAcceptViewNib?.viewVisualEffect.showAnimateView((self.rideAcceptViewNib?.viewVisualEffect)!, isShow: true, direction: .Top)
    self.arrviedView?.viewVisualEffectMain.showAnimateView((self.arrviedView?.viewVisualEffectMain)!, isShow: true, direction: .Top)
        self.floatyButton?.isHidden = false
        self.tollView?.isHidden  = false
    }
    
    func hideView(){ //MARK:- hide Viewoffline view
//        if self.viewGoogleRetraction != nil {
//             self.viewGoogleRetraction.showAnimateView(self.viewGoogleRetraction, isShow: false, direction: .Top)
//        }
       
        self.rideAcceptViewNib?.viewVisualEffect.showAnimateView((self.rideAcceptViewNib?.viewVisualEffect)!, isShow: false, direction: .Bottom)
        self.arrviedView?.viewVisualEffectMain.showAnimateView((self.arrviedView?.viewVisualEffectMain)!, isShow: false, direction: .Bottom)
        self.floatyButton?.isHidden = true
        self.tollView?.isHidden  = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        self.currentBearing?(newHeading.trueHeading)
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.tollView?.removeFromSuperview()
        self.tollView = nil
    }
    
    
    func setMapStyle(){ //MARK:- set map style 
        do {
            // Set the map style by passing a valid JSON string.
            if let url = Bundle.main.url(forResource: "Map_style", withExtension: "json") {
                self.gMSmapView.mapStyle = try GMSMapStyle(contentsOfFileURL: url)
            }else {
                print("error")
            }
            
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    
    func setGustureForGoogleMapRetraction(){
//        let gusture = UITapGestureRecognizer(target: self, action: #selector(openGoogleMap))
//        
//        viewGoogleRetraction.addGestureRecognizer(gusture)
    }
    
    @IBAction func openGoogleMap(){

        let slat = self.requestDetail?.requests?.first?.request?.s_latitude
        let sLong = self.requestDetail?.requests?.first?.request?.s_longitude
        let dLat = self.requestDetail?.requests?.first?.request?.d_latitude
        let dLong = self.requestDetail?.requests?.first?.request?.d_longitude
        
        var stopLat:Double?
        var stopLng:Double?
        let status = self.requestDetail?.requests?.first?.request?.status
        if let way_points = self.requestDetail?.requests?.first?.request?.way_points {
            let wayPnts:[WayPoint]? = way_points.data(using: .utf8)?.getDecodedObject(from: [WayPoint].self)
            stopLat = wayPnts?.first?.lat
            stopLng = wayPnts?.first?.lng
        }

        let alert = UIAlertController(title: "Navigation", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Google", style: .destructive , handler:{ (UIAlertAction)in
            print("User click Approve button")
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                
                print(self.pickupLocation as Any, "   ", self.dropLocation as Any)
                
                guard let _ = self.pickupLocation, let _ = self.dropLocation, var url = URL(string: "comgooglemaps://?saddr=\(slat ?? 0),\(sLong ?? 0)&daddr=\(dLat ?? 0),\(dLong ?? 0)&directionsmode=driving"), UIApplication.shared.canOpenURL(url) else { return }
                
                if stopLat != nil && stopLng != nil {
                    if status == requestType.pickedUp.rawValue {
                        url = URL(string: "comgooglemaps://?saddr=\(slat ?? 0),\(sLong ?? 0)&daddr=\(dLat!),\(dLong!)+to:\(stopLat ?? 0),\(stopLng ?? 0)&directionsmode=driving")!
                    } else {
                        url = URL(string: "comgooglemaps://?saddr=\(slat ?? 0),\(sLong ?? 0)&daddr=\(stopLat!),\(stopLng!)+to:\(dLat ?? 0),\(dLong ?? 0)&directionsmode=driving")!
                    }
                }
                
                UIApplication.shared.open(url, options: [:]) { (true) in
                    print("google map open")
                }
            } else {
                print("Can't use comgooglemaps://")
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Waze", style: .default , handler:{ (UIAlertAction)in
            print("User click Edit button")

            if (UIApplication.shared.canOpenURL(URL(string:"waze://")!)) {
                print(self.pickupLocation as Any, "   ", self.dropLocation as Any)
//                let address = self.labelPickUp.text == Constants.string.pickUpLocation.localize() ? "\(slat ?? 0),\(sLong ?? 0)" : self.labelPickUp.text == Constants.string.stopLocation.localize() ? "\(stopLat ?? 0),\(stopLng ?? 0)" : "\(dLat ?? 0),\(dLong ?? 0)"
//                guard let _ = self.pickupLocation, let _ = self.dropLocation, let url = URL(string: "waze://?ll=\(address)&navigate=yes"), UIApplication.shared.canOpenURL(url) else { return }
//
//                UIApplication.shared.open(url, options: [:]) { (true) in
//                    print("waze app open")
//                }
                if status == requestType.pickedUp.rawValue {
                    let address = self.labelPickUp.text == Constants.string.pickUpLocation.localize() ? "\(slat ?? 0),\(sLong ?? 0)" : self.labelPickUp.text == Constants.string.stopLocation.localize() ? "\(dLat ?? 0),\(dLong ?? 0)" : "\(stopLat ?? 0),\(stopLng ?? 0)"
                    guard let _ = self.pickupLocation, let _ = self.dropLocation, let url = URL(string: "waze://?ll=\(address)&navigate=yes"), UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url, options: [:]) { (true) in
                        print("waze app open")
                    }
                } else if status == requestType.midstopped.rawValue {
                    let address = self.labelPickUp.text == Constants.string.pickUpLocation.localize() ? "\(slat ?? 0),\(sLong ?? 0)" : self.labelPickUp.text == Constants.string.dropLocation.localize() ? "\(stopLat ?? 0),\(stopLng ?? 0)" : "\(dLat ?? 0),\(dLong ?? 0)"
                    guard let _ = self.dropLocation, let url = URL(string: "waze://?ll=\(address)&navigate=yes"), UIApplication.shared.canOpenURL(url) else { return }
                    print("*****************************", "   ", url)
                    UIApplication.shared.open(url, options: [:]) { (true) in
                        print("waze app open")
                    }
                } else {
                    let address = self.labelPickUp.text == Constants.string.pickUpLocation.localize() ? "\(slat ?? 0),\(sLong ?? 0)" : self.labelPickUp.text == Constants.string.stopLocation.localize() ? "\(stopLat ?? 0),\(stopLng ?? 0)" : "\(dLat ?? 0),\(dLong ?? 0)"
                    guard let _ = self.pickupLocation, let _ = self.dropLocation, let url = URL(string: "waze://?ll=\(address)&navigate=yes"), UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url, options: [:]) { (true) in
                        print("waze app open")
                    }
                }
            } else {
                print("Can't use waze://")
                UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/waze-navigation-live-traffic/id323229106?mt=8")!, options: [:], completionHandler: { (success) in
                })

            }

        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })

    }
}


public extension CLLocation {
    
    func bearingToLocationRadian(_ destinationLocation: CLLocation) -> CGFloat {
        
        let lat1 = self.coordinate.latitude.degreesToRadians
        let lon1 = self.coordinate.longitude.degreesToRadians
        
        let lat2 = destinationLocation.coordinate.latitude.degreesToRadians
        let lon2 = destinationLocation.coordinate.longitude.degreesToRadians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return CGFloat(radiansBearing)
    }
    
    func bearingToLocationDegrees(destinationLocation: CLLocation) -> CGFloat {
        return bearingToLocationRadian(destinationLocation).radiansToDegrees
    }
}



extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var radiansToDegrees: CGFloat { return self * 180 / .pi }
}

extension Double {
    var degreesToRadians: Double { return Double(CGFloat(self).degreesToRadians) }
    var radiansToDegrees: Double { return Double(CGFloat(self).radiansToDegrees) }
}

