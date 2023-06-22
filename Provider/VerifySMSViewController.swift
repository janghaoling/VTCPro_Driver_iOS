//
//  VerifySMSViewController.swift
//  Provider
//
//  Created by JackCJ on 3/15/20.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit

class VerifySMSViewController: UIViewController {

    @IBOutlet weak var verifyCode: HoshiTextField!
    @IBOutlet weak var btnVerify: UIButton!
    
    var authy_id : String = ""
    var country_Code : String = ""
    var phone : String = ""
    
    var onCompleteVerified : ((_ code:String, _ phone:String) -> Void)?
    private lazy var loader : UIView = {
        return createActivityIndicator(self.view)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickVerify(_ sender: Any) {
        struct Params : JSONSerializable {
            var authy_id:String?
            var auth_token:String?
        }
        var params = Params()
        params.authy_id = authy_id
        params.auth_token = verifyCode.text
        self.loader.isHidden = false
        Webservice().retrieve(api: .verifySMS, url: nil, data:params.toData(), imageData: nil, paramters: nil, type: .POST) { (error, data) in
            self.loader.isHidden = true
            if error == nil {
                struct Res : JSONSerializable {
                    var success : Bool?
                    var message : String?
                    var authy_id : String?
                }
                let responseObject = data?.getDecodedObject(from: Res.self)
                if let success = responseObject?.success, success == true {
                    self.onCompleteVerified?(self.country_Code, self.phone)
                    return
                }
            }
            // show error message.
            UIApplication.shared.keyWindow?.makeToast("Something went wrong. Please try again.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        localize()
        SetNavigationcontroller()
    }

}

extension VerifySMSViewController {
    
    private func localize(){
        self.btnVerify.setTitle(Constants.string.VERIFY.localize(), for: .normal)
        self.verifyCode.placeholder = Constants.string.Verify_Code.localize()
        btnVerify.titleLabel?.font = UIFont(name: FontCustom.medium.rawValue, size: 16)
        btnVerify.setTitleColor(.white, for: .normal)
    }
    
    func SetNavigationcontroller(){
        self.navigationController?.isNavigationBarHidden = false
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.barTintColor = UIColor.white
        }
        else {
        }
        title = Constants.string.Verify_SMS.localize()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon"), style: .plain, target: self, action: #selector(self.backBarButton(sender:)))
                
    }
    
    @objc func backBarButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
