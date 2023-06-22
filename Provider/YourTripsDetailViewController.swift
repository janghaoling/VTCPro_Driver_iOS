//
//  YourTripsViewController.swift
//  User
//
//  Created by CSS on 13/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import ImageSlideshow
import AlamofireImage

class YourTripsDetailViewController: UITableViewController {
    
    // MARK:- IBOutlet
    
    @IBOutlet private weak var imageViewMap : UIImageView!
    @IBOutlet private weak var imageViewProvider : UIImageView!
    @IBOutlet private weak var labelProviderName : UILabel!
    @IBOutlet private weak var viewRating : FloatRatingView!
    @IBOutlet private weak var labelDate : UILabel!
    @IBOutlet private weak var labelTime : UILabel!
    @IBOutlet private weak var labelBookingId : UILabel!
    @IBOutlet private weak var labelPayViaString : UILabel!
    @IBOutlet private weak var imageViewPayVia : UIImageView!
    @IBOutlet private weak var labelPayVia : UILabel!
    @IBOutlet private weak var labelPrice : UILabel!
    @IBOutlet private weak var labelCommentsString : UILabel!
    @IBOutlet private weak var textViewComments : UITextView!
    @IBOutlet private weak var buttonCancelRide : UIButton!
    @IBOutlet private weak var buttonViewReciptAndCall : UIButton!
    @IBOutlet private weak var viewLocation : UIView!
    @IBOutlet private weak var labelSourceLocation : UILabel!
    @IBOutlet private weak var labelMiddleLocation : UILabel!
    @IBOutlet private weak var labelLastLocation : UILabel!
    @IBOutlet weak var viewMidToEnd: UIView!
    @IBOutlet weak var viewEndSquare: UIView!
    
    
    @IBOutlet private weak var viewComments : UIView!
    @IBOutlet private weak var viewButtons : UIView!
    @IBOutlet private weak var viewMore : UIView!
    @IBOutlet private weak var buttonDispute : UIButton!
    
    @IBOutlet weak var lbNoteTitle: UILabel!
    @IBOutlet weak var tvNote: UITextView!
    
    
    @IBOutlet weak var imageViewWeek0: UIImageView!
    @IBOutlet weak var imageViewWeek1: UIImageView!
    @IBOutlet weak var imageViewWeek2: UIImageView!
    @IBOutlet weak var imageViewWeek3: UIImageView!
    @IBOutlet weak var imageViewWeek4: UIImageView!
    @IBOutlet weak var imageViewWeek5: UIImageView!
    @IBOutlet weak var imageViewWeek6: UIImageView!
    @IBOutlet weak var weekday0: UILabel!
    @IBOutlet weak var weekday1: UILabel!
    @IBOutlet weak var weekday2: UILabel!
    @IBOutlet weak var weekday3: UILabel!
    @IBOutlet weak var weekday4: UILabel!
    @IBOutlet weak var weekday5: UILabel!
    @IBOutlet weak var weekday6: UILabel!
    // MARK:- LocalVariable

    var isUpcomingTrips = false
    private var heightArray : [CGFloat] = [62,80,70,145,145, 44,44,44,44,44,44,44]
    private var dataSource : YourTripModelResponse?
    private var viewRecipt : invoiceView?
    private var blurView : UIView?
    private var requestId : Int?
    
    private var disputeView : DisputeLostItemView?
    private var disputeStatusView : DisputeStatusView?
    var disputeList:[String]=[]
    var disputeEntity : Dispute?
    var providerIconUrl = ""
    
    lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    var isBeforeShowedForMore = false
    var isBeforeShowedFordisputeView = false
    var isBeforeShowedFordisputeStatusView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
        self.localize()
        self.setDesign()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageViewProvider.makeRoundedCorner()
        self.setLayouts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.imageViewMap.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var disputeList = DisputeList()
        disputeList.dispute_type = "provider"
        self.presenter?.post(api: .getDisputeList, data: disputeList.toData())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewButtons.isHidden = false
        if isBeforeShowedForMore {
            self.viewMore.isHidden = false
        }
        if isBeforeShowedFordisputeView {
            self.disputeView?.isHidden = false
        }
        if isBeforeShowedFordisputeStatusView {
            self.disputeStatusView?.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideRecipt()
        self.viewButtons.isHidden = true
        
        isBeforeShowedForMore = self.viewMore.isHidden
        isBeforeShowedFordisputeView = !(self.disputeView?.isHidden ?? true)
        isBeforeShowedFordisputeStatusView = !(self.disputeStatusView?.isHidden ?? true)
        
        self.viewMore.isHidden = true
        self.disputeView?.isHidden = true
        self.disputeStatusView?.isHidden = true
    }
    
    deinit {
        self.viewButtons.removeFromSuperview()
        self.viewMore.removeFromSuperview()
        self.disputeView?.removeFromSuperview()
        self.disputeView = nil
        self.disputeStatusView?.removeFromSuperview()
        self.disputeStatusView = nil
        
    }
    
    @IBAction func onClickProviderIcon(_ sender: Any) {
        let vc = FullScreenSlideshowViewController()
        vc.inputs = [
            AlamofireSource(urlString: self.providerIconUrl)!
        ]
        self.present(vc, animated: true, completion:nil)
    }
}

// MARK:- Methods
extension YourTripsDetailViewController {
    
    //Initial Loads
    private func initialLoads() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_more").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.tapMore))
        self.buttonCancelRide.isHidden = !isUpcomingTrips
        self.buttonCancelRide.addTarget(self, action: #selector(self.buttonCancelRideAction(sender:)), for: .touchUpInside)
        self.buttonViewReciptAndCall.addTarget(self, action: #selector(self.buttonCallAndReciptAction(sender:)), for: .touchUpInside)
        self.buttonDispute.addTarget(self, action: #selector(self.buttonDisputeAction(sender:)), for: .touchUpInside)
        self.loader.isHidden = false
        let api : Base = self.isUpcomingTrips ? .upcomingTripDetail : .pastTripDetail
        self.presenter?.get(api: api, parameters: ["request_id":self.requestId!])
        
        self.viewRating.minRating = 1
        self.viewRating.maxRating = 5
        self.viewRating.emptyImage = #imageLiteral(resourceName: "StarEmpty")
        self.viewRating.fullImage = #imageLiteral(resourceName: "StarFull")
        self.textViewComments.isEditable = false
        UIApplication.shared.keyWindow?.addSubview(self.viewButtons)
        self.viewButtons.translatesAutoresizingMaskIntoConstraints = false
        self.viewButtons.widthAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.widthAnchor, multiplier: 0.8, constant: 0).isActive = true
        self.viewButtons.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.viewButtons.bottomAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.bottomAnchor, constant: -16).isActive = true
        self.viewButtons.centerXAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.centerXAnchor, constant: 0).isActive = true
        
        let moreViewY = (self.navigationController?.navigationBar.frame.height)!+(self.navigationController?.navigationBar.frame.origin.y)!
        self.viewMore.frame = CGRect(x: self.view.frame.width-150, y: moreViewY , width: 130, height: 60)
        UIApplication.shared.keyWindow?.addSubview(self.viewMore)
        self.viewMore.alpha = 0
        
        let touchOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchOutside))
        view.addGestureRecognizer(touchOutside)
    }
    
    func setId(id : Int) {
        self.requestId = id
    }
    
    //Localize
    private func localize() {
        
        self.buttonViewReciptAndCall.setTitle((isUpcomingTrips ? Constants.string.call:Constants.string.viewRecipt).localize().uppercased(), for: .normal)
        self.labelPayViaString.text = (isUpcomingTrips ? Constants.string.paymentMethod : Constants.string.payVia).localize()
        
        
        if isUpcomingTrips {
            self.buttonCancelRide.setTitle(Constants.string.cancelRide.localize().uppercased(), for: .normal)
        } else {
            self.labelCommentsString.text = Constants.string.comments.localize()
        }
        self.navigationItem.title = (isUpcomingTrips ? Constants.string.upcomingTripDetails : Constants.string.pastTripDetails).localize()
        
    }
    
    //Set Designs
    
    private func setDesign() {
        setFont(TextField: nil, label: labelDate, Button: nil, size: 12)
        setFont(TextField: nil, label: labelTime, Button: nil, size: 12)
        setFont(TextField: nil, label: labelPrice, Button: nil, size: 12)
        setFont(TextField: nil, label: labelPayVia, Button: nil, size: 12)
        setFont(TextField: nil, label: labelBookingId, Button: nil, size: 12)
        setFont(TextField: nil, label: labelProviderName, Button: nil, size: 12)
        setFont(TextField: nil, label: labelPayViaString, Button: nil, size: 14)
        setFont(TextField: nil, label: labelCommentsString, Button: nil, size: 14)
        setFont(TextField: nil, label: labelSourceLocation, Button: nil, size: 12)
        setFont(TextField: nil, label: labelMiddleLocation, Button: nil, size: 14)
        setFont(TextField: nil, label: labelLastLocation, Button: nil, size: 14)
        Common.setFont(to: self.buttonDispute, isTitle: false)
    }
    
    //Layouts
    
    private func setLayouts() {
        
        let height = tableView.tableFooterView?.frame.origin.y ?? 0//(self.buttonViewReciptAndCall.convert(self.buttonViewReciptAndCall.frame, to: UIApplication.shared.keyWindow ?? self.tableView).origin.y+self.buttonViewReciptAndCall.frame.height)
        guard height < UIScreen.main.bounds.height else { return }
        let footerHeight = UIScreen.main.bounds.height-height
        self.tableView.tableFooterView?.frame.size.height = (footerHeight-(self.buttonViewReciptAndCall.frame.height*2)-(self.navigationController?.navigationBar.frame.height ?? 0))
    }
    
    func showDisputeView(){
        if self.disputeView == nil, let disputeView = Bundle.main.loadNibNamed(XIB.Names.DisputeLostItemView, owner: self, options: [:])?.first as? DisputeLostItemView {
            let disputeHeight =  disputeView.frame.height
            disputeView.frame = CGRect(x: 0, y: self.view.frame.height-disputeHeight, width: self.view.frame.width, height: disputeHeight)
            self.disputeView = disputeView
            
            disputeView.set(value: self.disputeList, requestID: self.requestId!, userID: self.dataSource?.user?.id ?? 0)
            
            UIApplication.shared.keyWindow?.addSubview(disputeView)
            self.disputeView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.5),
                           initialSpringVelocity: CGFloat(1.0),
                           options: .allowUserInteraction,
                           animations: {
                            self.disputeView?.transform = .identity },
                           completion: { Void in()  })
        }
        self.disputeView?.onClickClose = { closed in
            UIView.animate(withDuration: 0.3, animations: {
                self.disputeView?.alpha = 0
            }, completion: { (_) in
                self.disputeView?.removeFromSuperview()
                self.disputeView = nil
            })
        }
    }
    
    private func showDisputeStatus(){
        if self.disputeStatusView == nil, let disputeStatusView = Bundle.main.loadNibNamed(XIB.Names.DisputeStatusView, owner: self, options: [:])?.first as? DisputeStatusView {
            
            disputeStatusView.frame = CGRect(x: 0, y: self.view.frame.height-disputeStatusView.frame.height, width: self.view.frame.width, height: disputeStatusView.frame.height)
            self.disputeStatusView = disputeStatusView
            
            disputeStatusView.setDispute(dispute: disputeEntity ?? Dispute())
            
            UIApplication.shared.keyWindow?.addSubview(disputeStatusView)
            self.disputeStatusView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.5),
                           initialSpringVelocity: CGFloat(1.0),
                           options: .allowUserInteraction,
                           animations: {
                            self.disputeStatusView?.transform = .identity },
                           completion: { Void in()  })
        }
        self.disputeStatusView?.onClickClose = { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.disputeStatusView?.alpha = 0
            }, completion: { (_) in
                self.disputeStatusView?.removeFromSuperview()
                self.disputeStatusView = nil
            })
        }
    }
    
    //Set values
    
    private func setValues() {
        
        let mapImage = self.dataSource?.static_map?.replacingOccurrences(of: "%7C", with: "|").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Cache.image(forUrl: mapImage) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageViewMap.image = image
                }
            }
        }
        
        self.labelProviderName.text = String.removeNil(self.dataSource?.user?.first_name) + " " + String.removeNil(self.dataSource?.user?.last_name)
        let imageUrl = String.removeNil(self.dataSource?.user?.picture).contains(WebConstants.string.http) ? self.dataSource?.user?.picture : Common.getImageUrl(for: self.dataSource?.user?.picture)
        self.providerIconUrl = imageUrl ?? ""
        Cache.image(forUrl: imageUrl) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageViewProvider.image = image
                }
            }
        }
        
        self.viewRating.rating = Float(self.dataSource?.rating?.user_rating ?? 0)
        if self.textViewComments.text.count == 0 {
            self.textViewComments.text = self.dataSource?.rating?.user_comment ?? Constants.string.noComments.localize()
        }else{
            self.textViewComments.text = self.dataSource?.rating?.user_comment ?? Constants.string.noComments.localize()
        }
        
        self.labelSourceLocation.text = self.dataSource?.s_address
        
        if let way_points = self.dataSource?.way_points {
            let wayPnts:[WayPoint]? = way_points.data(using: .utf8)?.getDecodedObject(from: [WayPoint].self)
            let stopAddress = wayPnts?.first?.address
            self.labelMiddleLocation.text = self.dataSource?.d_address
            self.labelLastLocation.text = stopAddress
        } else {
            self.labelMiddleLocation.text = self.dataSource?.d_address
            self.viewMidToEnd.isHidden = true
            self.viewEndSquare.isHidden = true
            self.labelLastLocation.isHidden = true
        }
        
        self.labelPayVia.text = self.dataSource?.payment_mode
        if self.dataSource?.payment_mode == "CASH"{
            self.imageViewPayVia.image = #imageLiteral(resourceName: "money").resizeImage(newWidth: 30)
        }else{
            self.imageViewPayVia.image = #imageLiteral(resourceName: "visa")
        }
        self.labelBookingId.text = self.dataSource?.booking_id
        
        if let dateObject = Formatter.shared.getDate(from: self.dataSource?.finished_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss) {
            self.labelDate.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.ddMMMyyyy)
            self.labelTime.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.hh_mm_a)
        }
        self.labelPrice.text = Formatter.shared.appPriceFormat(string: "\(self.dataSource?.payment?.total ?? 0)")
//        self.labelPrice.text = String.removeNil(User.main.currency)+" \(self.dataSource?.payment?.total ?? 0)"
        self.buttonDispute.setTitle(self.dataSource?.dispute != nil ? Constants.string.disputeStatus.localize() : Constants.string.dispute.localize(), for: .normal)
        
        // Set Recurrent Dates
        if dataSource?.repeated != nil {
            imageViewWeek0.image = ((dataSource?.repeated!.contains(0))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek1.image = ((dataSource?.repeated!.contains(1))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek2.image = ((dataSource?.repeated!.contains(2))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek3.image = ((dataSource?.repeated!.contains(3))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek4.image = ((dataSource?.repeated!.contains(4))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek5.image = ((dataSource?.repeated!.contains(5))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek6.image = ((dataSource?.repeated!.contains(6))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
        }
        weekday0.text = Constants.string.Sunday.localize()
        weekday1.text = Constants.string.Monday.localize()
        weekday2.text = Constants.string.Tuesday.localize()
        weekday3.text = Constants.string.Wednesday.localize()
        weekday4.text = Constants.string.Thursday.localize()
        weekday5.text = Constants.string.Friday.localize()
        weekday6.text = Constants.string.Saturday.localize()

        tvNote.text = dataSource?.note
        if (dataSource?.status == "SCHEDULED" && (dataSource?.manual_assigned_at) != nil) {
            buttonViewReciptAndCall.isHidden = true
        }
        
        if (self.isUpcomingTrips) {
//            self.labelPrice.text = Formatter.shared.appPriceFormat(string:"\(dataSource?.estimated?.estimated_fare ?? 0.0)")
            self.labelPrice.text = Formatter.shared.appPriceFormat(string:"\(dataSource?.total_price ?? 0.0)")
            if let pool_commission = dataSource?.pool_commission {
                let price = (100 - (pool_commission as NSString).floatValue) * (dataSource?.total_price ?? 0.0) / 100
                self.labelPrice.text = Formatter.shared.appPriceFormat(string:"\(price)")
            }
        }
    }
    
    //Show Recipt
    private func showRecipt() {
        
        if let viewReciptView = Bundle.main.loadNibNamed(XIB.Names.invoiceView, owner: self, options: [:])?.first as? invoiceView, self.dataSource != nil {
            viewReciptView.set(request: self.dataSource!)
            viewReciptView.buttonConfirm.addTarget(self, action: #selector(hideRecipt), for: .touchUpInside)
            BackGroundTask.backGroundInstance.detailviewStatus = true
            viewReciptView.frame = CGRect(origin: CGPoint(x: 0, y: (UIApplication.shared.keyWindow?.frame.height)!-viewReciptView.frame.height), size: CGSize(width: self.view.frame.width, height: viewReciptView.frame.height))
            self.viewRecipt = viewReciptView
            UIApplication.shared.keyWindow?.addSubview(viewReciptView)
            viewReciptView.show(with: .bottom) {
                self.addBlurView()
            }
        }
    }
    
    
    private func addBlurView() {
        
        self.blurView = UIView(frame: UIScreen.main.bounds)
        self.blurView?.alpha = 0
        self.blurView?.backgroundColor = .black
        self.blurView?.isUserInteractionEnabled = true
        self.view.addSubview(self.blurView!)
        self.viewRecipt?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideRecipt)))
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView?.alpha = 0.6
        })
        
    }
}

// MARK:- IBAction

extension YourTripsDetailViewController {
    
    @objc func touchOutside() {
        self.viewMore.alpha = 0
    }
    
    @objc func tapMore() {
        UIView.animate(withDuration: 0.3, animations: {
            if self.viewMore?.alpha == 0.0 {
                self.viewMore.alpha = 1.0
            }else{
                self.viewMore.alpha = 0.0
            }
        })
    }
    
    @objc func buttonDisputeAction(sender : UIButton) {
        self.viewMore.alpha = 0.0
        if self.dataSource?.dispute != nil {
            self.showDisputeStatus()
            return
        }
        self.showDisputeView()
        
    }
    
    //Cancel Ride
    
    @objc func buttonCancelRideAction(sender : UIButton) {
        if isUpcomingTrips, self.dataSource?.id != nil {
            self.loader.isHidden = false
            var cancelModel = UpcomingCancelModel()
            cancelModel.id = self.requestId ?? 0
            self.presenter?.post(api: .assignedCancel, data: cancelModel.toData())
//            self.presenter?.post(api: .UpcommingCancel, data: cancelModel.toData())

        }
    }
    //Call and View Recipt
    @objc func buttonCallAndReciptAction(sender : UIButton) {
        
        if isUpcomingTrips {
            let number = "\(self.dataSource?.user?.country_code ?? "")\(self.dataSource?.user?.mobile ?? "")"
            if number != "" {
                Common.call(to: number)
            }
        } else {
            self.showRecipt()
        }
    }
    
    //Remove Recipt
    @objc func hideRecipt() {
        
        self.viewRecipt?.dismissView(onCompletion: {
            self.viewRecipt = nil
            self.blurView?.removeFromSuperview()
        })
    }
    
}

// MARK:- Postview Protocol

extension YourTripsDetailViewController: PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    func getYourTripAPI(api: Base, data: [YourTripModelResponse]?) {
        if data != nil, (data?.count)! > 0{
            self.dataSource = data?.first
        }
        
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.setValues()
        }
    }
    
    func getUpcomingtripResponse(api: Base, data: YourTripModelResponse?) {
        self.dataSource = data
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.setValues()
            self.disputeEntity = self.dataSource?.dispute
            self.tableView.reloadData()
        }
    }
    
    func getUpdateStatus(api: Base, data: UpdateTripStatusModelResponse?) {
        self.loader.isHidden = true
        UIApplication.shared.keyWindow?.makeToast(Constants.string.rideCancel.localize())
        self.popOrDismiss(animation: true)
    }
    
    func getDisputeList(api: Base, data: [DisputeList]) {
        for disputeName in data {
            self.disputeList.append(disputeName.dispute_name ?? "")
        }
    }
}

extension YourTripsDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isUpcomingTrips && indexPath.row == 3 {
            return 0
        }
        
//        if indexPath.row == 4 {
//            if !isUpcomingTrips {return 0}
//            if dataSource?.manual_assigned_at == nil {return 0}
//        }
        
        if indexPath.row >= 5 {
            if !isUpcomingTrips { return 0 }
            if dataSource?.repeated == nil || dataSource?.repeated?.count == 0 {
                return 0
            }
        }

        return heightArray[indexPath.row]

    }
}
