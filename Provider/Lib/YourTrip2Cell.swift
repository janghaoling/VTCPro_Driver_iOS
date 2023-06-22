//
//  YourTrip2Cell.swift
//  Provider
//
//  Created by Xiaoming Tian on 7/17/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit
import HCSStarRatingView
import CountdownLabel

class YourTrip2Cell: UITableViewCell {

    @IBOutlet weak var ivGoogleMap: UIImageView!
    @IBOutlet weak var viewTimer: UIView!
    @IBOutlet weak var lbTimer: CountdownLabel!
    @IBOutlet weak var lbTimer2: UILabel!
    @IBOutlet weak var ivUserAvatar: UIImageView!
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbPickupTitle: UILabel!
    @IBOutlet weak var lbPickupLocation: UILabel!
    @IBOutlet weak var lbDropOffTitle: UILabel!
    @IBOutlet weak var lbDropOffLocation: UILabel!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var labelStop: UILabel!
    @IBOutlet weak var labelStopValue: UILabel!
    
    var animationCircleLayer:CAShapeLayer?
    var onclickCancel:((Int)->())?
    var onclickAccept:((Int)->())?
    var onTimerTimeout:((Int)->())?
    var requestId : Int?
    var isSettedTimer: Bool = false
    var coundDownLB: CountdownLabel?
    var animation:CABasicAnimation?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ivUserAvatar.makeRoundedCorner()
        lbPickupTitle.text = Constants.string.pickUpLocation.localize()
        lbDropOffTitle.text = Constants.string.dropLocation.localize()
        labelStop.text = Constants.string.stopLocation.localize()
        btnAccept.setTitle(Constants.string.accept.localize(), for: .normal)
        btnReject.setTitle(Constants.string.reject.localize(), for: .normal)
    }

    private func setRequestAnimation(time:CFTimeInterval){
        if (animationCircleLayer != nil) {
            return
        }
        let (layer, animation) = setupCircleLayers(view: viewTimer, time: time)
        animationCircleLayer = layer
        self.animation = animation
        self.viewTimer.layer.insertSublayer(animationCircleLayer!, below: lbTimer2.layer)
        self.viewTimer.bringSubviewToFront(self.lbTimer2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(values : YourTripModelResponse?) {
        
        self.requestId = values?.id
        
        let mapImage = values?.static_map?.replacingOccurrences(of: "%7C", with: "|").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Cache.image(forUrl: mapImage) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.ivGoogleMap.image = image
                }
            }
        }
        
        if let dateObject = Formatter.shared.getDate(from: values?.schedule_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss)
        {
            let dateString = Formatter.shared.getString(from: dateObject, format: DateFormat.list.ddMMMyyyy)
            let timeString = Formatter.shared.getString(from: dateObject, format: DateFormat.list.hhMMTTA)
            lbDate.text = dateString+" \(Constants.string.at.localize()) "+timeString
        }
        lbPickupLocation.text = values?.s_address ?? ""
        lbDropOffLocation.text = values?.d_address ?? ""
        lbUsername.text = "\(values?.user?.first_name ?? "") \(values?.user?.last_name ?? "")"
        ratingView.value = CGFloat(Float(values?.user?.rating ?? "0.0")!)
        
        let picture = "\(baseUrl)storage/\(values?.user?.picture ?? "")"
        Cache.image(forUrl: picture) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.ivUserAvatar.image = image
                }
            }
        }

        if !isSettedTimer {
            let timezone = values?.timezone
            let manual_assigned_at = Formatter.shared.getDate(from: values?.manual_assigned_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss)
            if manual_assigned_at != nil, timezone != nil {
                let endDate = Calendar.current.date(byAdding: .hour, value: values?.timeout ?? 0, to: manual_assigned_at!)
                var diff = Calendar.current.dateComponents([.second], from: Date(), to: endDate!).second
                let nyTimeZone = TimeZone(identifier: timezone!)
                diff! += TimeZone.current.secondsFromGMT() - nyTimeZone!.secondsFromGMT()

                setRequestAnimation(time: Double(diff!))
                
                coundDownLB = CountdownLabel(frame: CGRect.zero, minutes: Double(diff!))
                coundDownLB?.countdownDelegate = self
                coundDownLB?.start()
//                lbTimer.addTime(time: Double(diff!))
//                lbTimer.start()
//                lbTimer.countdownDelegate = self
                isSettedTimer = true
            }
        }
        
        // if there is stop location then show else hide
        if let way_points = values?.way_points {
            let wayPnts:[WayPoint]? = way_points.data(using: .utf8)?.getDecodedObject(from: [WayPoint].self)
            let address = wayPnts?.first?.address
            labelStopValue.text = address ?? ""
        } else {
            labelStopValue.isHidden = true
            labelStop.isHidden = true
        }

//        labelAmount.text = Formatter.shared.appPriceFormat(string: "\(values?.total_price ?? 0)")

    }
    
    deinit {
        if (coundDownLB != nil) {
        }
    }
    
    @IBAction func onClickReject(_ sender: Any) {
        if self.requestId != nil {
            self.onclickCancel?(self.requestId!)
        }
    }
    
    @IBAction func onClickAccept(_ sender: Any) {
        if self.requestId != nil {
            self.onclickAccept?(self.requestId!)
        }
    }
}

extension YourTrip2Cell: CountdownLabelDelegate {
    @objc func countdownFinished() {
        if (onTimerTimeout != nil) {
            self.onTimerTimeout?(self.requestId!)
        }
    }
    
    @objc func countingAt(timeCounted: TimeInterval, timeRemaining: TimeInterval)
    {
        let day = Int((timeRemaining / (60 * 60 * 24)))
        let hour = Int((Int(timeRemaining) % Int(60 * 60 * 24)) / (60 * 60))
        let min = Int((Int(timeRemaining) % Int(60 * 60)) / 60)
        let second = Int((Int(timeRemaining) % Int(60)))
        lbTimer2.text = String(format:"%02d:%02d:%02d", Int(day * 24) + Int(hour), Int(min), Int(second))
        
    }
}
