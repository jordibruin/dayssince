//
//  SupporterVideoPlayerController.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation
import UIKit
import SwiftUI
import AVKit

struct SupporterVideoPlayerController: UIViewControllerRepresentable {
    
    var videoURL: URL
    @Binding var stopPlayer: Bool
    @Binding var muted: Bool
    
    typealias UIViewControllerType = AVPlayerViewController
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: videoURL)
        
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        playerViewController.videoGravity = .resizeAspect
        playerViewController.view.backgroundColor = .clear
        player.isMuted = true
        
        player.play()
        
        // Rewind video at the end
        
        // This causes memory leak
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
//                                               object: nil,
//                                               queue: nil) { [weak self] note in
//                                                player.seek(to: CMTime.zero)
//                                                player.play()
//        }
//
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if muted {
            uiViewController.player?.isMuted = true
        } else {
            uiViewController.player?.isMuted = false
        }
        
        if stopPlayer {
            uiViewController.player?.pause()
        } else {
            uiViewController.player?.play()
        }
    }
}
