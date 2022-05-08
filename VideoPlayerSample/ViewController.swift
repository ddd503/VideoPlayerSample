//
//  ViewController.swift
//  VideoPlayerSample
//
//  Created by kawaharadai on 2022/05/07.
//

import UIKit

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
                         print("メニュー3が押されました")
                     }),
            UIAction(title: "AVPlayer実装",
                     image: UIImage(systemName: "video"),
                     handler: { _ in
                         print("メニュー2が押されました")
                     })
        ])
        menuButton.menu = UIMenu(title: "再生方法を選択", children: [buttonMenus])
        menuButton.showsMenuAsPrimaryAction = true
    }

}

