//
//  CurrentRideViewController.swift
//  Provider
//
//  Created by JackCJ on 1/7/20.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit
import HCSStarRatingView

class CurrentRideViewController: UIViewController {

    @IBOutlet weak var lbDriverInformation: UILabel!
    @IBOutlet weak var ivDriverAvatar: UIImageView!
    @IBOutlet weak var lbDriverName: UILabel!
    @IBOutlet weak var ratingDriverReview: HCSStarRatingView!
    @IBOutlet weak var ivCarType: UIImageView!
    @IBOutlet weak var lbCarType: UILabel!
    
    @IBOutlet weak var lbPassengerInformation: UILabel!
    @IBOutlet weak var ivPassenger: UIImageView!
    @IBOutlet weak var lbPassengerName: UILabel!
    @IBOutlet weak var ratingPassenger: HCSStarRatingView!
    
    @IBOutlet weak var lbBookingInformation: UILabel!
    @IBOutlet weak var lbBookingID: UILabel!
    @IBOutlet weak var lbBookingValue: UILabel!

    @IBOutlet weak var lbBookingDateTime: UILabel!
    @IBOutlet weak var lbBookingDateTimeValue: UILabel!

    @IBOutlet weak var lbPickupDateTime: UILabel!
    @IBOutlet weak var lbPickupDateTimeValue: UILabel!

    @IBOutlet weak var lbPickup: UILabel!
    @IBOutlet weak var lbPickupValue: UILabel!

    @IBOutlet weak var lbStop: UILabel!
    @IBOutlet weak var lbStopValue: UILabel!

    @IBOutlet weak var lbDropOff: UILabel!
    @IBOutlet weak var lbDropOffValue: UILabel!

    @IBOutlet weak var lbRidecost: UILabel!
    @IBOutlet weak var ivPayMethod: UIImageView!
    @IBOutlet weak var lbPayMethod: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbPayvia: UILabel!
    
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var lbEmpty: UILabel!
    
    lazy var loader : UIView = {
        return createActivityIndicator(UIApplication.shared.keyWindow!)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalLoads()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func initalLoads() {
        self.view.bringSubviewToFront(viewEmpty)
//        setCommonFont()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.title = Constants.string.currentride.localize()
        localized()
        
        self.ivDriverAvatar.makeRoundedCorner()
        self.ivPassenger.makeRoundedCorner()
        
        checkRequstApi()
    }

    private func checkRequstApi(){
        self.loader.isHidden = false
        Webservice().retrieve(api: .tripStatus, url: nil, data: nil, imageData: nil, paramters: nil, type: .GET) { (err, data) in
            
            if err == nil, data != nil, let detail = Presenter.shared.getRequestDetails(data: data!), detail.requests?.count ?? 0 > 0 {
                let requestDetail = detail.requests![0]
                if requestDetail.request?.status == requestType.started.rawValue ||
                    requestDetail.request?.status == requestType.arrived.rawValue ||
                    requestDetail.request?.status == requestType.pickedUp.rawValue ||
                    requestDetail.request?.status == requestType.midstopped.rawValue ||
                    requestDetail.request?.status == requestType.dropped.rawValue {
                    
                    self.showDetail(requestDetail)
                    self.viewEmpty.isHidden = true

                }
            }
            
            self.loader.isHidden = true
        }
    }
    
    private func showDetail( _ requestModel : RequestInsideModel) {
        
        Cache.image(forUrl: "\(baseUrl)/\(Constants.string.storage)/\(String(describing: User.main.picture ?? "0"))") { (image) in
            DispatchQueue.main.async {
                self.ivDriverAvatar.image = image == nil ? #imageLiteral(resourceName: "young-male-avatar-image") : image
            }
        }
        lbDriverName.text = String.removeNil(User.main.firstName)+" "+String.removeNil(User.main.lastName)
        ratingDriverReview.value = CGFloat(Float(User.main.rating ?? "0.0")!)

        Cache.image(forUrl: "\(User.main.service_image ?? "")") { (image) in
            DispatchQueue.main.async {
                self.ivCarType.image = image
            }
        }
        lbCarType.text = "\(User.main.serviceType ?? "")\n\(User.main.service_model ?? "")\n\(User.main.service_number ?? "")"
        
        //user_rated
        lbPassengerName.text = "\(requestModel.request?.user?.first_name ?? "") \(requestModel.request?.user?.last_name ?? "")"
        let userRating = Float((requestModel.request?.user?.rating ?? "0")) ?? 0
        ratingPassenger.value = CGFloat(userRating)
        
        let imageUrl = String.removeNil(requestModel.request?.user?.picture ?? "").contains(WebConstants.string.http) ? requestModel.request?.user?.picture ?? "" : Common.getImageUrl(for: requestModel.request?.user?.picture ?? "")
        
        Cache.image(forUrl: imageUrl) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.ivPassenger.image = image ?? #imageLiteral(resourceName: "young-male-avatar-image")
                }
            }
        }
        
        lbBookingValue.text = requestModel.request?.booking_id ?? ""
        if let dateObject = Formatter.shared.getDate(from: requestModel.request?.created_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss){
            lbBookingDateTimeValue.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.yyyymmddHHMMss)
        }
        if let dateObject = Formatter.shared.getDate(from: requestModel.request?.started_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss){
            lbPickupDateTimeValue.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.yyyymmddHHMMss)
        } else {
            lbPickupDateTimeValue.text = "Have no pickup time just now"
        }
        lbPickupValue.text = requestModel.request?.s_address ?? ""
        lbDropOffValue.text = requestModel.request?.d_address ?? ""
        
        if let way_points = requestModel.request?.way_points {
            let wayPnts:[WayPoint]? = way_points.data(using: .utf8)?.getDecodedObject(from: [WayPoint].self)
            let stopAddress = wayPnts?.first?.address
            lbStopValue.text = requestModel.request?.d_address ?? ""
            lbDropOffValue.text = stopAddress ?? ""
        } else {
            lbStopValue.isHidden = true
            lbStop.isHidden = true
        }

        
        
        ivPayMethod.image = requestModel.request?.payment_mode == PaymentType.CARD.rawValue ? UIImage(named: "visa") : UIImage(named: "money")
        lbPayMethod.text = requestModel.request?.payment_mode
        
        lbPrice.text = Formatter.shared.appPriceFormat(string:"\(requestModel.request?.total_price ?? 0)")
    }

}

extension CurrentRideViewController {
    private func localized() {
        lbDriverInformation.text = Constants.string.Driver_informations.localize()
        lbPassengerInformation.text = Constants.string.Passenger_informations.localize()
        lbBookingInformation.text = Constants.string.Booking_informations.localize()
        lbBookingID.text = Constants.string.Booking_ID.localize()
        lbBookingDateTime.text = Constants.string.Booking_datetime.localize()
        lbPickupDateTime.text = Constants.string.Pickup_datetime.localize()
        lbPickup.text = Constants.string.pickUpLocation.localize()
        lbStop.text = Constants.string.stopLocation.localize()
        lbDropOff.text = Constants.string.dropLocation.localize()
        lbRidecost.text = Constants.string.Ride_cost.localize()
        lbPayvia.text = Constants.string.payVia.localize()
        lbEmpty.text = Constants.string.empty.localize()
    }
}
