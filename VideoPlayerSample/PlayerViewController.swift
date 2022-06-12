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
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var seekBar: UISlider!

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

    @IBAction func didTapForwardButton(_ sender: UIButton) {
        presenter.didTapForwardButton()
    }

    @IBAction func didTapBackwardButton(_ sender: UIButton) {
        presenter.didTapBackwardButton()
    }

    @IBAction func seekBarDidChange(_ sender: UISlider) {
        presenter.seekBarDidChange(afterChangeTime: sender.value)
    }

}

extension PlayerViewController: PlayViewOutput {
    func setupPlayerView(avPlayer: AVPlayer) {
        self.playerView.player = avPlayer
    }

    func setupSeekBar(at avPlayer: AVPlayer) {
        seekBar.minimumValue = 0
        let duration = avPlayer.currentItem?.duration ?? .zero
        seekBar.maximumValue = Float(CMTimeGetSeconds(duration))
        seekBar.value = 0
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

    func updateForwardButtonIsEnabled(_ isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.forwardButton.isEnabled = isEnabled
        }
    }

    func updateBackwardButtonIsEnabled(_ isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.backwardButton.isEnabled = isEnabled
        }
    }

    func updateSeekBarIsEnabled(_ isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.seekBar.isEnabled = isEnabled
        }
    }
    
    func updateSeekBarValue(_ value: Float) {
        DispatchQueue.main.async { [weak self] in
            self?.seekBar.value = value
        }
    }
}
