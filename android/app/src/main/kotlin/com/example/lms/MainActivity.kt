package com.wwitplwebinarhub.lms

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val VIDEO_CHANNEL = "lms.video.player"
        private const val ZOOM_CHANNEL = "lms.zoom"

        private const val METHOD_OPEN_VIDEO = "openVideoPlayer"
        private const val METHOD_JOIN_ZOOM = "joinZoomMeeting"

        private const val REQUEST_ZOOM = 9001
    }

    private var pendingZoomResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        // =====================================================
        // VIDEO CHANNEL
        // =====================================================

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            VIDEO_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                METHOD_OPEN_VIDEO -> {

                    val videoUrl =
                        call.argument<String>("videoUrl")

                    if (videoUrl.isNullOrBlank()) {

                        result.error(
                            "VIDEO_URL_MISSING",
                            "Video URL is missing",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    val intent =
                        Intent(
                            this,
                            VideoPlayerActivity::class.java
                        )

                    intent.putExtra(
                        "videoUrl",
                        videoUrl
                    )

                    startActivity(intent)

                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }

        // =====================================================
        // ZOOM CHANNEL
        // =====================================================

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ZOOM_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                METHOD_JOIN_ZOOM -> {

                    // -----------------------------------------
                    // Prevent duplicate requests
                    // -----------------------------------------

                    if (pendingZoomResult != null) {

                        result.error(
                            "ZOOM_ALREADY_OPEN",
                            "A Zoom meeting is already open.",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    // -----------------------------------------
                    // Arguments
                    // -----------------------------------------

                    val meetingNumber =
                        call.argument<String>(
                            "meetingNumber"
                        )

                    val meetingPassword =
                        call.argument<String>(
                            "meetingPassword"
                        )

                    val userName =
                        call.argument<String>(
                            "userName"
                        )

                    val jwt =
                        call.argument<String>(
                            "jwt"
                        )

                    // -----------------------------------------
                    // Validate meeting number
                    // -----------------------------------------

                    if (meetingNumber.isNullOrBlank()) {

                        result.error(
                            "MEETING_NUMBER_MISSING",
                            "Meeting number is missing",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    // -----------------------------------------
                    // Validate JWT
                    // -----------------------------------------

                    if (jwt.isNullOrBlank()) {

                        result.error(
                            "JWT_MISSING",
                            "Zoom Meeting SDK JWT is missing",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    // -----------------------------------------
                    // Create Intent
                    // -----------------------------------------

                    val intent =
                        Intent(
                            this,
                            ZoomActivity::class.java
                        )

                    intent.putExtra(
                        "meetingNumber",
                        meetingNumber.trim()
                    )

                    intent.putExtra(
                        "meetingPassword",
                        meetingPassword ?: ""
                    )

                    intent.putExtra(
                        "userName",
                        userName
                            ?.trim()
                            .takeUnless {
                                it.isNullOrEmpty()
                            }
                            ?: "LMS User"
                    )

                    intent.putExtra(
                        "jwt",
                        jwt.trim()
                    )

                    // -----------------------------------------
                    // Store Flutter result
                    //
                    // IMPORTANT:
                    // Do NOT call result.success() here.
                    // -----------------------------------------

                    pendingZoomResult = result

                    try {

                        startActivityForResult(
                            intent,
                            REQUEST_ZOOM
                        )

                    } catch (e: Exception) {

                        pendingZoomResult = null

                        result.error(
                            "ZOOM_LAUNCH_FAILED",
                            e.message,
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // =========================================================
    // ZOOM ACTIVITY RESULT
    // =========================================================

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {

        super.onActivityResult(
            requestCode,
            resultCode,
            data
        )

        if (requestCode != REQUEST_ZOOM) {
            return
        }

        val result =
            pendingZoomResult

        pendingZoomResult = null

        if (result == null) {
            return
        }

        when (resultCode) {

            Activity.RESULT_OK -> {

                result.success(true)
            }

            Activity.RESULT_CANCELED -> {

                result.success(false)
            }

            else -> {

                result.success(false)
            }
        }
    }

    override fun onDestroy() {

        pendingZoomResult = null

        super.onDestroy()
    }
}