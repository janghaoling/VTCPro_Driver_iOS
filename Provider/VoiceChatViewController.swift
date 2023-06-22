//
//  VoiceChatViewController.swift
//  TranxitUser
//
//  Created by Lonic dev on 25.10.2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit
import AgoraRtcKit

class VoiceChatViewController: UIViewController {

    @IBOutlet weak var controlButtonsView: UIView!
    @IBOutlet weak var avtar:UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var agoraKit: AgoraRtcEngineKit!
    var avPlayerHelper: AVAudioPlayer!
    var connected: Bool = false
    var channelname: String = "";
    private var currentUser: (UserDetails)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "skype_incoming.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            avPlayerHelper = try AVAudioPlayer(contentsOf: url)
        } catch {
            // couldn't load file :(
        }
        
        initializeAgoraEngine()
        joinChannel()
        
        //self.avPlayerHelper = AVPlayerHelper();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }
    
    func initializeAgoraEngine() {
        if connected {
            
        }else{
            avPlayerHelper.play()
        }
        // Initializes the Agora engine with your app ID.
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self)
    }
    
    func joinChannel() {
        // Allows a user to join a channel.
        agoraKit.joinChannel(byToken: nil, channelId: self.channelname, info:nil, uid:0) {[unowned self] (sid, uid, elapsed) -> Void in
            // Joined channel "demoChannel"
            self.agoraKit.setEnableSpeakerphone(true)
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        leaveChannel()
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        hideControlButtons()
        
        UIApplication.shared.isIdleTimerDisabled = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func hideControlButtons() {
        controlButtonsView.isHidden = true
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        // Stops/Resumes sending the local audio stream.
        agoraKit.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction func didClickSwitchSpeakerButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        // Enables/Disables the audio playback route to the speakerphone.
        //
        // This method sets whether the audio is routed to the speakerphone or earpiece. After calling this method, the SDK returns the onAudioRouteChanged callback to indicate the changes.
        agoraKit.setEnableSpeakerphone(sender.isSelected)
    }
}


extension VoiceChatViewController{
    func set(connected: Bool, user : GetRequestModelResponse, requestId: Int){
        self.connected = connected
        self.currentUser = user.requests?.first?.request?.user
        var tempId: Int = self.currentUser.id ?? 0
        self.channelname = "channeluser" + String(tempId)  + "provider" + String(requestId)
    }
    
    func updateUI(){
        self.name.text = currentUser.first_name!
        Cache.image(forUrl: Common.getImageUrl(for: currentUser.picture)) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.avtar?.image = image?.resizeImage(newWidth: 150)?.withRenderingMode(.alwaysOriginal)
                }
            }
        }
    }
}

extension VoiceChatViewController: AgoraRtcEngineDelegate{
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        if avPlayerHelper.isPlaying {
            avPlayerHelper.stop()
        }
    }
}
