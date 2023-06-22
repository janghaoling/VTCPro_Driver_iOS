//
//  YourTripCell.swift
//  User
//
//  Created by CSS on 09/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class YourTripCell: UITableViewCell {
    
    // MARK:- IBOutlet
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var upComingView: UIView!
    @IBOutlet var viewCarBack: UIView!
    
    @IBOutlet var upCommingCarImage: UIImageView!
    @IBOutlet var mapImageView: UIImageView!
    
    @IBOutlet var upCommingDateLabel: UILabel!
    @IBOutlet var upCommingBookingIDLlabel: UILabel!
    @IBOutlet var upCommingCarName: UILabel!
    
    @IBOutlet var upCommingCancelBtn: UIButton!
    @IBOutlet private var labelPrice : UILabel!
    @IBOutlet private var labelModel : UILabel!
    @IBOutlet private var stackViewPrice : UIStackView!
    @IBOutlet weak var userAvatar: UIImageView!
    
    // MARK:- LocalVariable
    
    var requestId : Int?
    var onclickCancel:((Int)->())?
    var isPastButton = false {
        didSet {
            self.stackViewPrice.isHidden = !isPastButton
            self.upCommingCancelBtn.isHidden = isPastButton
            self.userAvatar.isHidden = isPastButton
            self.upCommingCarImage.isHidden = !isPastButton
        }
    }
    
    lazy var loader : UIView = {
        return createActivityIndicator(UIApplication.shared.keyWindow!)
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setCommonFont()
        self.upCommingCancelBtn.setTitle(Constants.string.cancelRide.localize(), for: .normal)
        self.userAvatar.makeRoundedCorner()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewCarBack.makeRoundedCorner()
    }
    
    func set(values : YourTripModelResponse?) {
        print(isPastButton)
        
        self.requestId = values?.id
        if isPastButton {
            Cache.image(forUrl: values?.service_type?.image) { (image) in
                DispatchQueue.main.async {
                    self.upCommingCarImage.image = image == nil ? #imageLiteral(resourceName: "CarplaceHolder") : image
                }
            }
        } else {
            let picture = "\(baseUrl)storage/\(values?.user?.picture ?? "")"
            Cache.image(forUrl: picture) { (image) in
                if image != nil {
                    DispatchQueue.main.async {
                        self.userAvatar.image = image
                    }
                }
            }
        }
        
        let mapImage = values?.static_map?.replacingOccurrences(of: "%7C", with: "|").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Cache.image(forUrl: mapImage) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.mapImageView.image = image
                }
            }
        }
        
        self.upCommingBookingIDLlabel.text = Constants.string.bookingId.localize()+": "+String.removeNil(values?.booking_id)
        self.upCommingCarName.isHidden = isPastButton
        
        if let dateObject = Formatter.shared.getDate(from: isPastButton ? values?.assigned_at : values?.schedule_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss)
        {
            let dateString = Formatter.shared.getString(from: dateObject, format: DateFormat.list.ddMMMyyyy)
            let timeString = Formatter.shared.getString(from: dateObject, format: DateFormat.list.hhMMTTA)
            self.upCommingDateLabel.text = dateString+" \(Constants.string.at.localize()) "+timeString
        }
        
        if self.isPastButton {
            self.labelPrice.text = Formatter.shared.appPriceFormat(string: "\(values?.payment?.total ?? 0)")
//            self.labelPrice.text = "\(String.removeNil(User.main.currency ?? "$")) \(values?.payment?.total ?? 0)"
            self.labelModel.text = values?.service_type?.name
            
        }
                
    }

    private func setCommonFont(){
        
        setFont(TextField: nil, label: upCommingBookingIDLlabel, Button: nil, size: 12)
        setFont(TextField: nil, label: upCommingDateLabel, Button: upCommingCancelBtn, size: 12)
        setFont(TextField: nil, label: upCommingCarName, Button: nil, size: 12)
        setFont(TextField: nil, label: labelModel, Button: nil, size: 12, with: true)
        setFont(TextField: nil, label: labelPrice, Button: nil, size: 12)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

// MARK:- IBAction

extension  YourTripCell {
    @IBAction func ActionCancelButton(_ sender: Any) {
        
        if self.requestId != nil {
            self.onclickCancel?(self.requestId!)
        }
        
    }
}

// MARK:- PostViewProtocol

extension YourTripCell: PostViewProtocol{
    func onError(api: Base, message: String, statusCode code: Int) {
        print(message)
        self.loader.isHidden = true
        UIApplication.shared.keyWindow?.makeToast(message)
    }
    
    
    func getUpdateStatus(api: Base, data: UpdateTripStatusModelResponse?) {
        self.loader.isHidden = true
        if data != nil {
            
        }
        UIApplication.shared.keyWindow?.makeToast(Constants.string.rideCancel.localize())
        //print(data)
    }
}
