//
//  RideAcceptView.swift
//  User
//
//  Created by CSS on 03/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import HCSStarRatingView

class RideAcceptView: UIView {

    
    //MARK:- IBOutlet
    
    @IBOutlet var viewRequest: UIView!
    @IBOutlet var viewVisualEffect: UIVisualEffectView!
    @IBOutlet var pickUpLocation: UILabel!
    @IBOutlet var userName: UILabel!
    @IBOutlet var labelPickUp: UILabel!
    @IBOutlet var labelDrop: UILabel!
    @IBOutlet var labelDropLocationValue: UILabel!
    @IBOutlet var viewRatings: HCSStarRatingView!
    @IBOutlet var RejectBtn: UIButton!
    @IBOutlet var AcceptBtn: UIButton!
    @IBOutlet private var labelScheduleTime : Label!
    @IBOutlet var UserProfile: UIImageView!
    @IBOutlet var labelTime : UILabel!
    @IBOutlet weak var scheduleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var ivPayMethod: UIImageView!
    @IBOutlet weak var lbPayMethod: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var LabelStop: UILabel!
    @IBOutlet weak var LabelStopValue: UILabel!
    @IBOutlet weak var labelPayvia: UILabel!
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var labelNoteValue: UILabel!
    
    //MARK:- LocalVariable

    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelTime.text = ""
        setRequestAnimation()
        setCommonFont()
        setRoundCorner()
        localization()
    }
    
    func setRequestAnimation(){
        
        let layer = setupCircleLayers(view: viewRequest)
        self.viewRequest.layer.insertSublayer(layer, below: labelTime.layer)
        self.viewRequest.bringSubviewToFront(self.labelTime)
    }
    
    func setCommonFont(){
        setFont(TextField: nil, label: userName, Button: RejectBtn, size: nil)
        setFont(TextField: nil, label: nil, Button: RejectBtn, size: nil)
        setFont(TextField: nil, label: pickUpLocation, Button: nil, size: nil)
        setFont(TextField: nil, label: nil, Button: AcceptBtn, size: nil)
        setFont(TextField: nil, label: labelPickUp, Button: nil, size: nil)
        setFont(TextField: nil, label: labelDrop, Button: nil, size: nil)
        setFont(TextField: nil, label: labelDropLocationValue, Button: nil, size: nil)
        setFont(TextField: nil, label: LabelStop, Button: nil, size: nil)
        setFont(TextField: nil, label: LabelStopValue, Button: nil, size: nil)
        setFont(TextField: nil, label: lbPayMethod, Button: nil, size: nil)
        setFont(TextField: nil, label: labelPrice, Button: nil, size: nil)
        setFont(TextField: nil, label: labelNote, Button: nil, size: nil)
        setFont(TextField: nil, label: labelNoteValue, Button: nil, size: nil)
    }
    
    func localization(){
        self.labelDrop.text = Constants.string.dropLocation.localize()
        self.labelPickUp.text = Constants.string.pickUpLocation.localize()
        self.LabelStop.text = Constants.string.stopLocation.localize()
        self.labelPayvia.text = Constants.string.payVia.localize()
        self.AcceptBtn.setTitle(Constants.string.accept.localize().uppercased(), for: .normal)
        self.RejectBtn.setTitle(Constants.string.reject.localize().uppercased(), for: .normal)
    }
    
    func setRoundCorner(){
        self.UserProfile.cornerRadius = self.UserProfile.frame.height/2
        self.UserProfile.clipsToBounds = true
    }
    
    func setSchedule(date : Date) {
        self.labelScheduleTime.text = "\(Constants.string.scheduledFor.localize()) \(Formatter.shared.getString(from: date, format: DateFormat.list.MMM_dd_yyyy_hh_mm_ss_a))"
       
        self.labelScheduleTime.attributeColor = .primary
        self.labelScheduleTime.startLocation = 0
        self.labelScheduleTime.length = Constants.string.scheduledFor.localize().count
    }
    func displaySchduleView (isScheduled: Bool){
        if !(isScheduled){
            scheduleLabelHeight.constant = 15
            let newConstraint = NSLayoutConstraint(item: labelScheduleTime, attribute: scheduleLabelHeight.firstAttribute, relatedBy: .equal, toItem: scheduleLabelHeight.secondItem, attribute: scheduleLabelHeight.secondAttribute, multiplier: scheduleLabelHeight.multiplier, constant: scheduleLabelHeight.constant)
            labelScheduleTime.removeConstraint(scheduleLabelHeight)
            labelScheduleTime.addConstraint(newConstraint)
        } else {
            scheduleLabelHeight.constant = 60
            let newConstraint = NSLayoutConstraint(item: labelScheduleTime, attribute: scheduleLabelHeight.firstAttribute, relatedBy: .greaterThanOrEqual, toItem: scheduleLabelHeight.secondItem, attribute: scheduleLabelHeight.secondAttribute, multiplier: scheduleLabelHeight.multiplier, constant: scheduleLabelHeight.constant)
            labelScheduleTime.removeConstraint(scheduleLabelHeight)
            labelScheduleTime.addConstraint(newConstraint)
        }
    }
}
