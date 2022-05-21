//
//  PlayerViewPresenter.swift
//  VideoPlayerSample
//
//  Created by kawaharadai on 2022/05/21.
//

import Foundation
import AVFoundation

enum ViewStatus {
    case play
    case pause
}

protocol PlayViewOutput: AnyObject {
    func setupPlayerView(avPlayer: AVPlayer)
    func updatePlayButtonImage(imageName: String)
}

final class PlayerViewPresenter {
    private var viewStatus: ViewStatus = .pause
    private let videoUrl: URL
    private let avPlayer = AVPlayer()
    var output: PlayViewOutput?

    init(videoUrl: URL) {
        self.videoUrl = videoUrl
    }

    func viewDidLoad() {
        let asset = AVURLAsset(url: videoUrl)
        avPlayer.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        output?.setupPlayerView(avPlayer: avPlayer)
    }

    func didTapPlayButton() {
        switch viewStatus {
        case .play:
            avPlayer.pause()
            output?.updatePlayButtonImage(imageName: "play.circle.fill")
            viewStatus = .pause
        case .pause:
            avPlayer.play()
            output?.updatePlayButtonImage(imageName: "pause.circle.fill")
            viewStatus = .play
        }
    }
}
