//
//  GetSMSViewController.swift
//  Provider
//
//  Created by JackCJ on 3/15/20.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit

class GetSMSViewController: UIViewController {

    @IBOutlet weak var countryCode: HoshiTextField!
    @IBOutlet weak var ivCountryCode: UIImageView!
    @IBOutlet weak var phonenumber: HoshiTextField!
    @IBOutlet weak var btnGetSMS: UIButton!
    
    var phone : String = ""
    var email : String = ""
    var country_Code : String = ""
    private var dialCode : String = ""
    var onCompleteVerified : ((_ code:String, _ phone:String) -> Void)?
    private lazy var loader : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phonenumber.text = phone
    }
    
    @IBAction func onClickSMS(_ sender: Any) {
        
        struct Params : JSONSerializable {
            var country_code:String?
            var email:String?
            var cellphone:String?
        }
        var params = Params()
        params.country_code = dialCode
        params.email = email
        params.cellphone = phonenumber.text!
        print(params)
        self.loader.isHidden = false
        Webservice().retrieve(api: .requestSMS, url: nil, data:params.toData(), imageData: nil, paramters: nil, type: .POST) { (error, data) in
            self.loader.isHidden = true
            if error == nil {
                struct Res : JSONSerializable {
                    var success : Bool?
                    var message : String?
                    var authy_id : String?
                }
                let responseObject = data?.getDecodedObject(from: Res.self)
                if let success = responseObject?.success, success == true {
                    if let VerifySMSVC = Router.user.instantiateViewController(withIdentifier: Storyboard.Ids.VerifySMSViewController) as? VerifySMSViewController {
                        VerifySMSVC.onCompleteVerified = self.onCompleteVerified
                        VerifySMSVC.phone = self.phonenumber.text!
                        VerifySMSVC.country_Code = self.country_Code
                        VerifySMSVC.authy_id = responseObject?.authy_id ?? ""
                        self.navigationController?.pushViewController(VerifySMSVC, animated: true)
                    }
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

extension GetSMSViewController {
    
    private func localize(){
        self.btnGetSMS.setTitle(Constants.string.Get_SMS.localize(), for: .normal)
        self.phonenumber.placeholder = Constants.string.Phone_Number.localize()
        self.countryCode.placeholder = Constants.string.country.localize()
        btnGetSMS.titleLabel?.font = UIFont(name: FontCustom.medium.rawValue, size: 16)
        btnGetSMS.setTitleColor(.white, for: .normal)
    }
    
    func SetNavigationcontroller(){
        self.navigationController?.isNavigationBarHidden = false
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.barTintColor = UIColor.white
        }
        else {
        }
        title = Constants.string.Enter_your_mobile_number.localize()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon"), style: .plain, target: self, action: #selector(self.backBarButton(sender:)))
        
        print(country_Code)
        
        let country = Common.getCountries()
        for eachCountry in country {
            if country_Code == eachCountry.code {
                print(eachCountry.dial_code)
                self.dialCode = eachCountry.dial_code
                self.countryCode.text = eachCountry.dial_code
                let myImage = UIImage(named: "CountryPicker.bundle/\(eachCountry.code).png")
                ivCountryCode.image = myImage
            }
        }
    }
    
    @objc func backBarButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension GetSMSViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == countryCode {
            let coutryListvc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.CountryListController) as! CountryListController
            coutryListvc.FromSignUpPage = true
            self.present(coutryListvc, animated: true, completion: nil)
            coutryListvc.searchCountryCode = { code in
                print(code)
                self.country_Code = code
                let country = Common.getCountries()
                for eachCountry in country {
                    if code == eachCountry.code {
                        print(eachCountry.dial_code)
                        self.dialCode = eachCountry.dial_code
                        self.countryCode.text = eachCountry.dial_code
                        let myImage = UIImage(named: "CountryPicker.bundle/\(eachCountry.code).png")
                        self.ivCountryCode.image = myImage
                    }
                }
            }
            
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
}
