//
//  AppData.swift
//  User
//
//  Created by CSS on 10/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

let AppName = "VTCPro Fleet Drvier"
var deviceTokenString = Constants.string.noDevice
var deviceId = Constants.string.noDevice
    
let googleMapKey = "AIzaSyDbwbcteVmKUjLCL4ZJ339ewX5Y6yRs6WU"
let appSecretKey = "OMV3biaXeE78bOW5TIOJABYLkLOnz2YTx5kadSK3"
let appClientId = 2

var helpMail = "support@vtc.com"
var helpEmailContant = "Hello \(AppName)"
let helpWeblink = baseUrl
var helpPhoneNumber = "1098"
let defaultMapLocation = LocationCoordinate(latitude: 13.009245, longitude: 80.212929)
let baseUrl = "https://fleet.solutionweb.io/"
//let baseUrl = "http://192.168.0.105:8000/"

//let stripePublishableKey = "pk_live_BRC1qqtBTAuLSm4mAuzcTdLw"

let driverBundleID = "com.vtcpro.driver"

enum AppStoreUrl : String {
    
    case user = "https://itunes.apple.com/fr/app/uber/id368677368"
    case driver = "https://itunes.apple.com/fr/app/uber-driver-pour-chauffeurs/id1131342792?mt=8"
}
