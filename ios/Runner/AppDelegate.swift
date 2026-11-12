import Flutter
import UIKit
import AVKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        let result = super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        if let flutterController =
            window?.rootViewController as? FlutterViewController {

            let channel = FlutterMethodChannel(
                name: "your.channel.name",
                binaryMessenger: flutterController.binaryMessenger
            )

            channel.setMethodCallHandler {
                [weak self] call, result in

                guard call.method == "openVideoPlayer" else {
                    result(FlutterMethodNotImplemented)
                    return
                }

                guard
                    let args = call.arguments as? [String: Any],
                    let videoUrl = args["videoUrl"] as? String,
                    let url = URL(string: videoUrl),
                    let scheme = url.scheme?.lowercased(),
                    ["https", "http"].contains(scheme)
                else {
                    result(
                        FlutterError(
                            code: "INVALID_URL",
                            message: "Invalid video URL",
                            details: nil
                        )
                    )
                    return
                }

                let title = args["title"] as? String ?? "Video"

                let lastPosition =
                    (args["lastPosition"] as? NSNumber)?.int64Value ?? 0

                DispatchQueue.main.async {

                    guard let self = self,
                          let root = self.window?.rootViewController
                    else {
                        result(
                            FlutterError(
                                code: "NO_CONTROLLER",
                                message: "View controller unavailable",
                                details: nil
                            )
                        )
                        return
                    }

                    var presenter = root

                    while let presented =
                        presenter.presentedViewController {
                        presenter = presented
                    }

                    let videoController =
                        VideoPlayerViewController(
                            videoURL: url,
                            title: title,
                            lastPosition: lastPosition
                        )

                    videoController.modalPresentationStyle = .fullScreen

                    presenter.present(
                        videoController,
                        animated: true
                    )

                    result(nil)
                }
            }
        }

        return result
    }
}