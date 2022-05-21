//
//  ViewController.swift
//  VideoPlayerSample
//
//  Created by kawaharadai on 2022/05/07.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var menuButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuButton()
    }

    private func setupMenuButton() {
        let buttonMenus = UIMenu(options: .displayInline, children: [
            UIAction(title: "AVPlayerViewController実装",
                     image: UIImage(systemName: "video"),
                     handler: { _ in
                         let player = AVPlayer(url: self.videoUrl(at: "cat_1"))
                         let playerViewController = AVPlayerViewController()
                         playerViewController.player = player
                         self.present(playerViewController, animated: true) {
                             player.play()
                         }
                     }),
            UIAction(title: "AVPlayer実装",
                     image: UIImage(systemName: "video"),
                     handler: { _ in
                         let presenter = PlayerViewPresenter(videoUrl: self.videoUrl(at: "cat_2"))
                         let playerViewController = PlayerViewController(presenter: presenter)
                         presenter.output = playerViewController
                         self.present(playerViewController, animated: true)
                     })
        ])
        // 違うoptionsのUIMenuをchildrenに入れて併用できるようにUIMenuの生成を分けている
        menuButton.menu = UIMenu(title: "再生方法を選択", children: [buttonMenus])
        menuButton.showsMenuAsPrimaryAction = true
    }

    private func videoUrl(at name: String, type: String = "mov") -> URL {
        return Bundle.main.url(forResource: name, withExtension: type)!
    }
}

