//
//  ViewController.swift
//  HLSPlayer
//
//  Created by 성호 on 2023/10/31.
//

import Combine
import AVFoundation
import AVKit
import UIKit

class ViewController: UIViewController {

    private lazy var player: AVPlayer = AVPlayer()
    
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPlayerView()
        playMedia(at: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"))
        addLogObserver()
    }
    
    func addPlayerView() {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        addChild(playerViewController)
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func playMedia(at url: URL?) {
        guard let url else { return }
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(
            asset: asset,
            automaticallyLoadedAssetKeys: [.tracks, .duration, .commonMetadata]
        )
        
        // Register to observe the status property before associating with player.
        playerItem.publisher(for: \.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    // Ready to play. Present playback UI.
                    print("readyToPlay")
                case .failed:
                    // A failure while loading media occurred.
                    print("failed")
                default:
                    print("unknown")
                }
            }
            .store(in: &subscriptions)
        
        // Set the item as the player's current item.
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    private func addLogObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAVPlayerAccess),
            name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
            object: nil
        )
    }
    
    @objc private func handleAVPlayerAccess(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem,
            let lastEvent = playerItem.accessLog()?.events.last else {
            return
        }

        print("AVPlayerItemNewAccessLogEntry lastEvent: \(lastEvent)")
    }
}
