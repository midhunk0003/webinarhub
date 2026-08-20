package com.webinarhub.lms

import android.net.Uri
import android.os.Bundle
import android.view.WindowManager
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView

class VideoPlayerActivity : ComponentActivity() {

    private var player: ExoPlayer? = null
    private lateinit var playerView: PlayerView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // -----------------------------------------
        // FULLSCREEN
        // -----------------------------------------
        hideSystemBars()

        // Keep screen awake while watching
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )

        // -----------------------------------------
        // PLAYER VIEW
        // -----------------------------------------
        playerView = PlayerView(this)

        playerView.useController = true

        setContentView(playerView)

        // -----------------------------------------
        // GET VIDEO URL
        // -----------------------------------------
        val videoUrl = intent.getStringExtra("videoUrl")

        if (videoUrl.isNullOrEmpty()) {

            Toast.makeText(
                this,
                "Video URL is empty",
                Toast.LENGTH_LONG
            ).show()

            finish()
            return
        }

        // -----------------------------------------
        // VALIDATE URL
        // -----------------------------------------
        if (
            !videoUrl.startsWith("http://") &&
            !videoUrl.startsWith("https://")
        ) {

            Toast.makeText(
                this,
                "Invalid video URL",
                Toast.LENGTH_LONG
            ).show()

            finish()
            return
        }

        // -----------------------------------------
        // INITIALIZE EXOPLAYER
        // -----------------------------------------
        try {

            player = ExoPlayer.Builder(this).build()

            playerView.player = player

            val mediaItem = MediaItem.fromUri(
                Uri.parse(videoUrl)
            )

            player?.setMediaItem(mediaItem)

            player?.prepare()

            player?.play()

        } catch (e: Exception) {

            Toast.makeText(
                this,
                "Unable to play video",
                Toast.LENGTH_LONG
            ).show()

            e.printStackTrace()

            finish()
        }
    }

    // -----------------------------------------
    // HIDE STATUS + NAVIGATION BAR
    // -----------------------------------------
    private fun hideSystemBars() {

        WindowCompat.setDecorFitsSystemWindows(
            window,
            false
        )

        val controller =
            WindowInsetsControllerCompat(
                window,
                window.decorView
            )

        controller.hide(
            WindowInsetsCompat.Type.statusBars() or
                    WindowInsetsCompat.Type.navigationBars()
        )

        controller.systemBarsBehavior =
            WindowInsetsControllerCompat
                .BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
    }

    // -----------------------------------------
    // RESUME FULLSCREEN
    // -----------------------------------------
    override fun onWindowFocusChanged(
        hasFocus: Boolean
    ) {
        super.onWindowFocusChanged(hasFocus)

        if (hasFocus) {
            hideSystemBars()
        }
    }

    // -----------------------------------------
    // RELEASE PLAYER
    // -----------------------------------------
    override fun onDestroy() {

        playerView.player = null

        player?.release()

        player = null

        super.onDestroy()
    }
}