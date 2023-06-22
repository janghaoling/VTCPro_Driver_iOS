//
//  AdsPageViewController.swift
//  TranxitUser
//
//  Created by Xiaoming Tian on 7/14/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit

class AdsPageViewController: UIPageViewController {

    private var adsControllers = [UIViewController]()
    
    var timer:Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
        self.dataSource = self
        self.delegate = self
    }
    
    deinit {
        self.invalidateTimer()
    }
}

extension AdsPageViewController {
    
    private func initialLoads() {
        
        Webservice().retrieve(api: .getAds, url: nil, data:nil, imageData: nil, paramters: nil, type: .GET) { (error, data) in
            if (error != nil) {
                NotificationCenter.default.post(name: Notification.Name("NOTIFICATION.NAME_FAILEDADS"), object: nil, userInfo: nil)
            } else {
                if let responseObject:[AppAdvertisement] = data?.getDecodedObject(from: [AppAdvertisement].self) {
                    for i in 0..<responseObject.count {
                        if let viewCtrl = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.AdsPageItemViewController) as? AdsPageItemViewController {
                            viewCtrl.ad = responseObject[i]
                            self.adsControllers.append(viewCtrl)
                        }
                    }
                }
                if self.adsControllers.count > 0 {
                    self.setViewControllers([self.adsControllers[0]], direction: .forward, animated: true, completion: nil)
                    if self.adsControllers.count > 1 {
                        self.initTimer()
                    }
                    NotificationCenter.default.post(name: Notification.Name("NOTIFICATION.NAME_GOTADS"), object: nil, userInfo: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name("NOTIFICATION.NAME_FAILEDADS"), object: nil, userInfo: nil)
                }
            }
        }

    }
    
    private func initTimer() {
        self.invalidateTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (t) in
            self.goToNextPage()
        })
    }
    
    private func invalidateTimer() {
        if (timer != nil), timer!.isValid {
            timer?.invalidate()
            timer = nil
        }
    }
    
}

extension AdsPageViewController {
    
    func goToNextPage(){
        
        guard let currentViewController = self.viewControllers?.first else { return }
        
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }
    
    
    func goToPreviousPage(){
        
        guard let currentViewController = self.viewControllers?.first else { return }
        
        guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
        
        setViewControllers([previousViewController], direction: .reverse, animated: true, completion: nil)
        
    }
    
}

extension AdsPageViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = adsControllers.index(of: viewController)
        if adsControllers.count == 1 {
            return nil
        }
        index = index == 0 ? adsControllers.count : index
        return adsControllers[index!-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = adsControllers.index(of: viewController)
        if adsControllers.count == 1 {
            return nil
        }
        index = index == adsControllers.count - 1 ? -1 : index
        return adsControllers[index!+1]
    }
}

