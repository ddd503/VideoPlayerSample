//
//  PlayerView.swift
//  VideoPlayerSample
//
//  Created by kawaharadai on 2022/05/10.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

