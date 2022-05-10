//
//  PlayerViewController.swift
//  VideoPlayerSample
//
//  Created by kawaharadai on 2022/05/10.
//

import UIKit

final class PlayerViewController: UIViewController {

    static func make() -> PlayerViewController {
        PlayerViewController(nibName: String(describing: PlayerViewController.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
