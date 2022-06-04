//
//  PlayerViewPresenter.swift
//  VideoPlayerSample
//
//  Created by kawaharadai on 2022/05/21.
//

import Foundation
import AVFoundation

protocol PlayViewOutput: AnyObject {
    func setupPlayerView(avPlayer: AVPlayer)
    func updatePlayButtonImage(imageName: String)
    func updatePlayButtonIsEnabled(_ isEnabled: Bool)
}

final class PlayerViewPresenter {
    private let videoUrl: URL
    private let avPlayer: AVPlayer
    private var playerTimeControlStatusObserver: NSKeyValueObservation?
    private var playerItemFastForwardObserver: NSKeyValueObservation?
    var output: PlayViewOutput?

    init(videoUrl: URL, avPlayer: AVPlayer = AVPlayer()) {
        self.videoUrl = videoUrl
        self.avPlayer = avPlayer
    }

    func viewDidLoad() {
        let asset = AVURLAsset(url: videoUrl)
        avPlayer.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        setupPlayerObservers(avPlayer)
        output?.setupPlayerView(avPlayer: avPlayer)
    }

    func didTapPlayButton() {
        switch avPlayer.timeControlStatus {
        case .paused, .waitingToPlayAtSpecifiedRate:
            avPlayer.play()
        case .playing:
            avPlayer.pause()
        @unknown default:
            avPlayer.pause()
        }
    }

    private func setupPlayerObservers(_ avPlayer: AVPlayer) {
        // 再生中のプレイヤー状態を監視し、再生ボタンのイメージを切り替える
        // .initial, .new = 登録時、都度更新後
        playerTimeControlStatusObserver = avPlayer.observe(\AVPlayer.timeControlStatus,
                                                            options: [.initial, .new]) { [weak self] observeAvPlayer, _ in
            switch observeAvPlayer.timeControlStatus {
            case .paused, .waitingToPlayAtSpecifiedRate:
                self?.output?.updatePlayButtonImage(imageName: "play.circle.fill")
            case .playing:
                self?.output?.updatePlayButtonImage(imageName: "pause.circle.fill")
            @unknown default:
                self?.output?.updatePlayButtonImage(imageName: "pause.circle.fill")
            }
        }

        // 動画が再生可能かどうかを監視し、再生ボタンの活性非活性を管理
        playerItemFastForwardObserver = avPlayer.observe(\AVPlayer.currentItem?.canPlayFastForward,
                                                          options: [.initial, .new]) { [weak self] observeAvPlayer, _ in
            self?.output?.updatePlayButtonIsEnabled(observeAvPlayer.currentItem?.canPlayFastForward ?? false)
        }
    }
}
