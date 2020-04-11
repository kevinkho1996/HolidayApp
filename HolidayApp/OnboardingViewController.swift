//
//  ViewController.swift
//  HolidayApp
//
//  Created by Kevin Kho on 11/04/20.
//  Copyright © 2020 Kevin Kho. All rights reserved.
//

import UIKit
import AVFoundation
import Combine
class OnboardingViewController: UIViewController {

    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var getstartedButton: UIButton!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let notificationCenter = NotificationCenter.default
    private var appEventSubscribers = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeAppEvents()
        setupPlayerIfNeeded()
        restartVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAppEventsSubscribers()
        removePlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupViews(){
        getstartedButton.layer.cornerRadius = getstartedButton.frame.height / 2
        getstartedButton.layer.masksToBounds = true
        darkView.backgroundColor = UIColor.init(white: 0.1, alpha: 0.4)
    }
    
    private func buildPlayer() -> AVPlayer? {
        guard let filePath = Bundle.main.path(forResource: "bg_video", ofType: "mp4") else {return nil}
        let url = URL(fileURLWithPath: filePath)
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.isMuted = true
        return player
    }
    
    private func buildPlayerLayer () -> AVPlayerLayer? {
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
    
    private func playVideo() {
        player?.play()
    }
    
    private func restartVideo() {
        player?.seek(to: .zero)
        playVideo()
    }
    
    private func pauseVideo () {
        player?.pause()
    }
    
    private func setupPlayerIfNeeded(){
        self.player = buildPlayer()
        self.playerLayer = buildPlayerLayer()
        
        if let layer = self.playerLayer, view.layer.sublayers?.contains(layer) == false {
            view.layer.insertSublayer(layer, at: 0)
        }
    }
    private func observeAppEvents(){
        notificationCenter.publisher(for: .AVPlayerItemDidPlayToEndTime).sink { [weak self] _ in
            self?.restartVideo()
        }.store(in: &appEventSubscribers)
        
        notificationCenter.publisher(for: UIApplication.willResignActiveNotification).sink { [weak self] _ in
            self?.pauseVideo()
        }.store(in: &appEventSubscribers)
        
        notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self] _ in
            self?.playVideo()
        }.store(in: &appEventSubscribers)
    }
    
    private func removeAppEventsSubscribers(){
        appEventSubscribers.forEach { subscriber in
            subscriber.cancel()
        }
    }
    private func removePlayer() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    @IBAction func getstartedButtonTapped(_ sender: Any) {
        
    }
    
}

