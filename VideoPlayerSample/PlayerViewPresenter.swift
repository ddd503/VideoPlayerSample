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
    func setupSeekBar(at avPlayer: AVPlayer)
    func updatePlayButtonImage(imageName: String)
    func updatePlayButtonIsEnabled(_ isEnabled: Bool)
    func updateForwardButtonIsEnabled(_ isEnabled: Bool)
    func updateBackwardButtonIsEnabled(_ isEnabled: Bool)
    func updateSeekBarIsEnabled(_ isEnabled: Bool)
    func updateSeekBarValue(_ value: Float)
}

final class PlayerViewPresenter {
    private let videoUrl: URL
    private let avPlayer: AVPlayer
    private let forwardTimeOnce: Float = 2
    private let backwardTimeOnce: Float = 2
    private var playerTimeControlStatusObserver: NSKeyValueObservation?
    private var playerItemFastForwardObserver: NSKeyValueObservation?
    private var playerItemReverseObserver: NSKeyValueObservation?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var timeObserverToken: Any?
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

    func seekBarDidChange(afterChangeTime: Float) {
        let newTime = CMTime(seconds: Double(afterChangeTime), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        avPlayer.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
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

        // 動画が早送り可能かを判定、早送りボタンの活性非活性を切り替える
        playerItemFastForwardObserver = avPlayer.observe(\AVPlayer.currentItem?.canPlayFastForward,
                                                          options: [.initial, .new]) { [weak self] observeAvPlayer, _ in
            self?.output?.updateForwardButtonIsEnabled(observeAvPlayer.currentItem?.canPlayFastForward ?? false)
        }

        playerItemReverseObserver = avPlayer.observe(\AVPlayer.currentItem?.canPlayReverse,
                                                          options: [.initial, .new]) { [weak self] observeAvPlayer, _ in
            self?.output?.updateBackwardButtonIsEnabled(observeAvPlayer.currentItem?.canPlayReverse ?? false)
        }

        // 再生完了時、動画とシークバーを最初まで戻す
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem, queue: nil) { [weak self] _ in
            if let currentItem = avPlayer.currentItem, currentItem.currentTime() == currentItem.duration {
                currentItem.seek(to: .zero, completionHandler: nil)
                self?.output?.updateSeekBarValue(0)
            }
        }

        playerItemStatusObserver = avPlayer.observe(\AVPlayer.currentItem?.status,
                                                     options: [.initial, .new]) { [weak self] observeAvPlayer, _ in
            guard let status = observeAvPlayer.currentItem?.status else {
                return
            }
            switch status {
            case .readyToPlay:
                self?.output?.updatePlayButtonIsEnabled(true)
                self?.output?.setupSeekBar(at: avPlayer)
                self?.output?.updateSeekBarIsEnabled(true)
            case .failed:
                self?.output?.updatePlayButtonIsEnabled(false)
                self?.output?.updateSeekBarIsEnabled(false)
            default:
                self?.output?.updatePlayButtonIsEnabled(false)
                self?.output?.updateSeekBarIsEnabled(false)
            }
        }

        let interval = CMTime(value: 1, timescale: 60) // 1秒60フレーム
        timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: interval,
                                                           queue: .main) { [weak self] time in
            let newValue = Float(time.seconds)
            self?.output?.updateSeekBarValue(newValue)
        }
    }
}
