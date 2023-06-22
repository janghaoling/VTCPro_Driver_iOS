//
//  AdsPageItemViewController.swift
//  TranxitUser
//
//  Created by Xiaoming Tian on 7/14/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit

class AdsPageItemViewController: UIViewController {

    @IBOutlet weak var ivAds: UIImageView!
    var ad:AppAdvertisement? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
    }
    
    func initializeView() -> Void {
        if self.ad != nil {
            ivAds.setImage(with: self.ad?.image, placeHolder: nil)
        }
    }

    @IBAction func onClickAds(_ sender: Any) {
        if self.ad != nil, self.ad?.click_url != nil {
            let url = URL.init(string:(self.ad?.click_url)!)
            if (UIApplication.shared.canOpenURL(url!)) {
                UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
    }
    
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }

}
