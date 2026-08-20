package com.webinarhub.lms

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val CHANNEL = "lms.video.player"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "openVideoPlayer") {

                val videoUrl = call.argument<String>("videoUrl")

                val intent = Intent(this, VideoPlayerActivity::class.java)

                intent.putExtra("videoUrl", videoUrl)

                startActivity(intent)

                result.success(true)

            } else {

                result.notImplemented()
            }
        }
    }
}

