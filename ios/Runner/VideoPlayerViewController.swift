import UIKit
import AVKit
import AVFoundation

final class VideoPlayerViewController: AVPlayerViewController {

    private let videoURL: URL
    private let videoTitle: String
    private let lastPositionMs: Int64

    init(
        videoURL: URL,
        title: String,
        lastPosition: Int64
    ) {
        self.videoURL = videoURL
        self.videoTitle = title
        self.lastPositionMs = lastPosition

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = videoTitle
        self.modalPresentationStyle = .fullScreen

        let playerItem = AVPlayerItem(url: videoURL)
        let avPlayer = AVPlayer(playerItem: playerItem)

        self.player = avPlayer

        if lastPositionMs > 0 {
            let seconds = Double(lastPositionMs) / 1000.0

            let position = CMTime(
                seconds: seconds,
                preferredTimescale: 600
            )

            avPlayer.seek(to: position) { [weak avPlayer] _ in
                avPlayer?.play()
            }
        } else {
            avPlayer.play()
        }
    }
}