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
    @IBOutlet weak var playButton: UIButton!
    private let presenter: PlayerViewPresenter

    init(presenter: PlayerViewPresenter) {
        self.presenter = presenter
        super.init(nibName: String(describing: PlayerViewController.self), bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

    @IBAction func didTapPlayButton(_ sender: UIButton) {
        presenter.didTapPlayButton()
    }
}

extension PlayerViewController: PlayViewOutput {
    func setupPlayerView(avPlayer: AVPlayer) {
        self.playerView.player = avPlayer
    }

    func updatePlayButtonImage(imageName: String) {
        DispatchQueue.main.async { [weak self] in
            self?.playButton.setBackgroundImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    func updatePlayButtonIsEnabled(_ isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.playButton.isEnabled = isEnabled
        }
    }
}
