//
//  PlayerViewController.swift
//  VideoPlayerSample
//
//  Created by kawaharadai on 2022/05/10.
//

import UIKit
import AVFoundation

final class PlayerViewController: UIViewController {
    @IBOutlet weak var playerView: PlayerView!
    private let videoUrl: URL
    private let avPlayer = AVPlayer()
    private let playButtonImageTitle = "play.circle.fill"
    private let pauseButtonImageTitle = "pause.circle.fill"

    init(videoUrl: URL) {
        self.videoUrl = videoUrl
        super.init(nibName: String(describing: PlayerViewController.self), bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let asset = AVURLAsset(url: videoUrl)
        self.playerView.player = avPlayer
        avPlayer.replaceCurrentItem(with: AVPlayerItem(asset: asset))
    }

    @IBAction func didTapPlayButton(_ sender: UIButton) {
        avPlayer.play()
    }
}
