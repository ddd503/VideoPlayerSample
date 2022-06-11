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
    func updateActionButtonsIsEnabled(_ isEnabled: Bool)
}

final class PlayerViewPresenter {
    private let videoUrl: URL
    private let avPlayer: AVPlayer
    private let forwardTimeOnce: Float = 2
    private let backwardTimeOnce: Float = 2
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

    func didTapForwardButton() {
        guard let currentItem = avPlayer.currentItem else {
            return
        }
        let duration = Float(currentItem.duration.seconds)
        let currentRate = avPlayer.rate
        let currentTime = Float(CMTimeGetSeconds(avPlayer.currentTime()))
        let canForwardMax = duration - (currentTime + forwardTimeOnce) > 0
        // 再生時間がスキップ時間を超える場合は末尾までスキップ
        let afterForwardTime = canForwardMax ? Double(currentTime + forwardTimeOnce) : Double(duration)
        avPlayer.rate = 0
        avPlayer.seek(to: CMTime(seconds: afterForwardTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))) { [weak self] completed in
            if completed {
                self?.avPlayer.rate = currentRate
            }
        }
    }

    func didTapBackwardButton() {
        let currentRate = avPlayer.rate
        let currentTime = Float(CMTimeGetSeconds(avPlayer.currentTime()))
        let canBackwardMax = (currentTime - backwardTimeOnce) > 0
        // スキップ結果が0を下回る場合は始めの位置(0)までスキップする
        let afterBackwardTime = canBackwardMax ? Double((currentTime - backwardTimeOnce)) : 0
        avPlayer.rate = 0
        avPlayer.seek(to: CMTime(seconds: afterBackwardTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))) { [weak self] completed in
            if completed {
                self?.avPlayer.rate = currentRate
            }
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
            self?.output?.updateActionButtonsIsEnabled(observeAvPlayer.currentItem?.canPlayFastForward ?? false)
        }

        // 再生完了時、動画を最初まで戻す
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem, queue: nil) { _ in
            if let currentItem = avPlayer.currentItem, currentItem.currentTime() == currentItem.duration {
                currentItem.seek(to: .zero, completionHandler: nil)
            }
        }
    }
}
