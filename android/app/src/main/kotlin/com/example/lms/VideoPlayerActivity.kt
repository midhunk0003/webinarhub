package com.wwitplwebinarhub.lms

import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.SeekBar
import android.widget.TextView
import android.widget.Toast

import androidx.activity.ComponentActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat

import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.TrackSelectionOverride
import androidx.media3.common.Tracks
import androidx.media3.common.VideoSize
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import android.view.TextureView


/**
 * TextureView that keeps the decoded video frame's aspect ratio.
 *
 * Media3 is attached directly to this view to avoid PlayerView/legacy
 * ExoPlayer UI resource collisions caused by the Zoom mobilertc module.
 *
 * The video is FIT_CENTER style:
 * - landscape video stays landscape
 * - portrait video stays portrait
 * - no stretching
 * - no cropping
 * - unused space remains black
 */
private class VideoTextureView(
    context: android.content.Context
) : TextureView(context) {

    private var videoAspectRatio = 16f / 9f

    fun setVideoAspectRatio(
        width: Int,
        height: Int,
        pixelWidthHeightRatio: Float = 1f,
        rotationDegrees: Int = 0
    ) {
        if (width <= 0 || height <= 0) return

        var ratio =
            (width.toFloat() * pixelWidthHeightRatio) /
                height.toFloat()

        if (rotationDegrees == 90 || rotationDegrees == 270) {
            ratio = 1f / ratio
        }

        if (ratio.isFinite() && ratio > 0f) {
            videoAspectRatio = ratio
            post {
                updateVideoTransform()
            }
        }
    }

    override fun onSizeChanged(
        w: Int,
        h: Int,
        oldw: Int,
        oldh: Int
    ) {
        super.onSizeChanged(w, h, oldw, oldh)
        updateVideoTransform()
    }

    private fun updateVideoTransform() {
        val viewWidth = width
        val viewHeight = height

        if (viewWidth <= 0 || viewHeight <= 0) return
        if (!videoAspectRatio.isFinite() || videoAspectRatio <= 0f) return

        val viewAspect =
            viewWidth.toFloat() / viewHeight.toFloat()

        var scaleX = 1f
        var scaleY = 1f

        // The TextureView surface itself is the full screen size.
        // Scale its content down to FIT_CENTER without cropping.
        if (viewAspect > videoAspectRatio) {
            // View is wider than the video.
            scaleX =
                videoAspectRatio / viewAspect
        } else if (viewAspect < videoAspectRatio) {
            // View is taller/narrower than the video.
            scaleY =
                viewAspect / videoAspectRatio
        }

        val matrix = Matrix()

        matrix.setScale(
            scaleX,
            scaleY,
            viewWidth / 2f,
            viewHeight / 2f
        )

        setTransform(matrix)
    }
}

class VideoPlayerActivity : ComponentActivity() {

    companion object {
        private const val TAG = "VideoPlayer"

        private const val SEEK_INCREMENT_MS = 10_000L

        private const val CONTROL_HIDE_DELAY = 4000L

        private const val CONNECTION_TIMEOUT = 30_000

        private const val READ_TIMEOUT = 30_000
    }

    // ---------------------------------------------------------
    // PLAYER
    // ---------------------------------------------------------

    private var player: ExoPlayer? = null

    // ---------------------------------------------------------
    // MAIN UI
    // ---------------------------------------------------------

    private lateinit var rootView: FrameLayout

    private lateinit var videoContainer: FrameLayout

    private lateinit var videoTextureView: VideoTextureView

    private lateinit var loadingView: ProgressBar

    // ---------------------------------------------------------
    // ERROR UI
    // ---------------------------------------------------------

    private lateinit var errorContainer: FrameLayout

    private lateinit var errorText: TextView

    private lateinit var retryButton: Button

    private var errorDialog: android.app.AlertDialog? = null

    // ---------------------------------------------------------
    // TOP BAR
    // ---------------------------------------------------------

    private lateinit var titleView: TextView

    private lateinit var topBar: LinearLayout

    // ---------------------------------------------------------
    // CONTROLS
    // ---------------------------------------------------------

    private lateinit var controlsOverlay: FrameLayout

    private lateinit var centerControls: LinearLayout

    private lateinit var bottomControls: LinearLayout

    private lateinit var qualityButton: Button

    private lateinit var fullscreenButton: Button

    private lateinit var speedButton: Button

    private lateinit var rewindButton: Button

    private lateinit var playPauseButton: Button

    private lateinit var forwardButton: Button

    private lateinit var seekBar: SeekBar

    private lateinit var currentTimeLabel: TextView

    private lateinit var totalTimeLabel: TextView

    // ---------------------------------------------------------
    // HANDLERS
    // ---------------------------------------------------------

    private val controlsHandler =
        Handler(Looper.getMainLooper())

    private val controlsHideRunnable =
        Runnable {
            hideControls(true)
        }

    private val progressRunnable =
        object : Runnable {

            override fun run() {

                try {

                    if (!isFinishing && !isDestroyed) {

                        updateProgress()

                        controlsHandler.postDelayed(
                            this,
                            500L
                        )
                    }

                } catch (e: Exception) {

                    Log.e(
                        TAG,
                        "Progress update failed",
                        e
                    )
                }
            }
        }

    // ---------------------------------------------------------
    // STATE
    // ---------------------------------------------------------

    private var controlsVisible = true

    private var videoUrl = ""

    private var videoTitle = "Video"

    private var lastPosition = 0L

    private var wasPlaying = true

    // Actual decoded video aspect ratio. Used for correct portrait/landscape
    // rendering and for choosing the most natural fullscreen orientation.
    private var videoAspectRatio = 16f / 9f

    private var userSelectedQuality = false

    // ---------------------------------------------------------
    // QUALITY MODEL
    // ---------------------------------------------------------

    private data class VideoQuality(
        val height: Int,
        val width: Int,
        val bitrate: Int,
        val group: Tracks.Group,
        val trackIndex: Int
    )

    // =========================================================
    // ACTIVITY
    // =========================================================

    override fun onCreate(
        savedInstanceState: Bundle?
    ) {
        super.onCreate(savedInstanceState)

        try {

            // Prevent screenshots/screen recording.
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )

            // Keep screen awake.
            window.addFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )

            requestedOrientation =
                ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED

            videoUrl =
                intent.getStringExtra("videoUrl")
                    ?: ""

            videoTitle =
                intent.getStringExtra("title")
                    ?: "Video"

            lastPosition =
                intent.getLongExtra(
                    "lastPosition",
                    0L
                )

            createPlayerUI()

            updateOrientationUI(
                resources.configuration.orientation
            )

            hideSystemBars()

            // ---------------------------------------------
            // Validate URL
            // ---------------------------------------------

            if (videoUrl.isBlank()) {

                showError(
                    "Video URL is empty."
                )

                return
            }

            if (
                !videoUrl.startsWith(
                    "https://",
                    ignoreCase = true
                ) &&
                !videoUrl.startsWith(
                    "http://",
                    ignoreCase = true
                )
            ) {

                showError(
                    "Invalid video URL."
                )

                return
            }

            initializePlayer()

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Activity initialization failed",
                e
            )

            showError(
                "Unable to open video player.\n\n" +
                    (
                        e.message
                            ?: "Unknown error"
                        )
            )
        }
    }

    // =========================================================
    // CREATE UI
    // =========================================================

    private fun createPlayerUI() {

        rootView =
            FrameLayout(this).apply {

                setBackgroundColor(
                    Color.BLACK
                )
            }

        videoContainer =
            FrameLayout(this).apply {

                setBackgroundColor(
                    Color.BLACK
                )
            }

        rootView.addView(
            videoContainer,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        // -----------------------------------------------------
        // MEDIA3 VIDEO SURFACE
        // -----------------------------------------------------
        //
        // IMPORTANT:
        // We intentionally do NOT use Media3 PlayerView here.
        // Zoom mobilertc can bring the legacy ExoPlayer UI classes/resources
        // into the same APK. That can cause:
        //
        // com.google.android.exoplayer2.ui.AspectRatioFrameLayout
        //       cannot be cast to
        // androidx.media3.ui.AspectRatioFrameLayout
        //
        // A plain TextureView avoids the conflicting Media3 UI resource
        // and works cleanly with the custom control overlay.
        // Media3 ExoPlayer can render directly into a TextureView.
        // -----------------------------------------------------

        videoTextureView =
            VideoTextureView(this).apply {
                // The parent videoContainer supplies the black background.
                // VideoTextureView preserves the actual video aspect ratio.
                keepScreenOn = true
            }

        videoContainer.addView(
            videoTextureView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        // -----------------------------------------------------
        // PLAYER CLICK
        // -----------------------------------------------------

        videoTextureView.setOnClickListener {

            try {

                if (controlsVisible) {

                    hideControls(false)

                } else {

                    showControls()
                }

            } catch (e: Exception) {

                Log.e(
                    TAG,
                    "Player click failed",
                    e
                )
            }
        }

        // -----------------------------------------------------
        // TOP BAR
        // -----------------------------------------------------

        topBar =
            LinearLayout(this).apply {

                orientation =
                    LinearLayout.HORIZONTAL

                gravity =
                    Gravity.CENTER_VERTICAL

                setPadding(
                    dp(14),
                    dp(18),
                    dp(18),
                    dp(18)
                )

                background =
                    GradientDrawable(
                        GradientDrawable.Orientation.TOP_BOTTOM,
                        intArrayOf(
                            0xF5000000.toInt(),
                            0xA8000000.toInt(),
                            0x00000000.toInt()
                        )
                    )
            }

        videoContainer.addView(
            topBar,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                dp(90)
            ).apply {

                gravity = Gravity.TOP
            }
        )

        // -----------------------------------------------------
        // BACK BUTTON
        // -----------------------------------------------------

        val backButton =
            makeIconButton(
                "‹",
                "Back",
                31f
            ).apply {

                setOnClickListener {

                    try {

                        finish()

                    } catch (e: Exception) {

                        Log.e(
                            TAG,
                            "Back failed",
                            e
                        )
                    }
                }
            }

        topBar.addView(
            backButton,
            LinearLayout.LayoutParams(
                dp(46),
                dp(46)
            )
        )

        // -----------------------------------------------------
        // TITLE
        // -----------------------------------------------------

        titleView =
            TextView(this).apply {

                text = videoTitle

                textSize = 17f

                setTextColor(
                    Color.WHITE
                )

                maxLines = 1

                ellipsize =
                    android.text.TextUtils.TruncateAt.END

                gravity =
                    Gravity.CENTER_VERTICAL

                setTypeface(
                    typeface,
                    android.graphics.Typeface.BOLD
                )

                setPadding(
                    dp(10),
                    0,
                    dp(8),
                    0
                )
            }

        topBar.addView(
            titleView,
            LinearLayout.LayoutParams(
                0,
                dp(46),
                1f
            )
        )

        // -----------------------------------------------------
        // CONTROLS
        // -----------------------------------------------------

        setupProfessionalControls()

        // -----------------------------------------------------
        // LOADING
        // -----------------------------------------------------

        loadingView =
            ProgressBar(this).apply {

                visibility =
                    View.GONE
            }

        videoContainer.addView(
            loadingView,
            FrameLayout.LayoutParams(
                dp(48),
                dp(48),
                Gravity.CENTER
            )
        )

        // -----------------------------------------------------
        // ERROR SCREEN
        // -----------------------------------------------------

        errorContainer =
            FrameLayout(this).apply {

                visibility =
                    View.GONE

                setBackgroundColor(
                    0xFF080808.toInt()
                )
            }

        rootView.addView(
            errorContainer,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        errorText =
            TextView(this).apply {

                textSize = 17f

                gravity =
                    Gravity.CENTER

                setTextColor(
                    Color.WHITE
                )

                setPadding(
                    dp(30),
                    dp(30),
                    dp(30),
                    dp(30)
                )
            }

        errorContainer.addView(
            errorText,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER
            )
        )

        retryButton =
            Button(this).apply {

                text = "Try again"

                textSize = 14f

                setTextColor(
                    Color.WHITE
                )

                isAllCaps = false

                background =
                    GradientDrawable().apply {

                        cornerRadius =
                            dp(22).toFloat()

                        setColor(
                            0xFF303030.toInt()
                        )
                    }

                setPadding(
                    dp(24),
                    0,
                    dp(24),
                    0
                )

                setOnClickListener {

                    try {

                        hideError()

                        initializePlayer()

                    } catch (e: Exception) {

                        Log.e(
                            TAG,
                            "Retry failed",
                            e
                        )

                        showError(
                            "Unable to retry video."
                        )
                    }
                }
            }

        errorContainer.addView(
            retryButton,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                dp(46),
                Gravity.CENTER
            ).apply {

                topMargin =
                    dp(130)
            }
        )

        setContentView(rootView)

        rootView.viewTreeObserver
            .addOnGlobalLayoutListener {

                try {

                    updateVideoLayout()

                } catch (e: Exception) {

                    Log.e(
                        TAG,
                        "Layout update failed",
                        e
                    )
                }
            }
    }

    // =========================================================
    // CONTROLS
    // =========================================================

    private fun setupProfessionalControls() {

        controlsOverlay =
            FrameLayout(this).apply {

                setBackgroundColor(
                    Color.TRANSPARENT
                )
            }

        videoContainer.addView(
            controlsOverlay,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        // -----------------------------------------------------
        // CENTER CONTROLS
        // -----------------------------------------------------

        centerControls =
            LinearLayout(this).apply {

                orientation =
                    LinearLayout.HORIZONTAL

                gravity =
                    Gravity.CENTER
            }

        rewindButton =
            makeCenterButton(
                "↶",
                "Rewind 10 seconds",
                31f
            )

        playPauseButton =
            makePlayPauseButton()

        forwardButton =
            makeCenterButton(
                "↷",
                "Forward 10 seconds",
                31f
            )

        centerControls.addView(
            rewindButton,
            LinearLayout.LayoutParams(
                dp(64),
                dp(64)
            ).apply {

                marginEnd =
                    dp(38)
            }
        )

        centerControls.addView(
            playPauseButton,
            LinearLayout.LayoutParams(
                dp(84),
                dp(84)
            )
        )

        centerControls.addView(
            forwardButton,
            LinearLayout.LayoutParams(
                dp(64),
                dp(64)
            ).apply {

                marginStart =
                    dp(38)
            }
        )

        controlsOverlay.addView(
            centerControls,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                dp(90),
                Gravity.CENTER
            )
        )

        // -----------------------------------------------------
        // BOTTOM CONTROLS
        // -----------------------------------------------------

        bottomControls =
            LinearLayout(this).apply {

                orientation =
                    LinearLayout.VERTICAL

                setPadding(
                    dp(18),
                    dp(8),
                    dp(18),
                    dp(18)
                )

                background =
                    GradientDrawable(
                        GradientDrawable.Orientation.BOTTOM_TOP,
                        intArrayOf(
                            0xF2000000.toInt(),
                            0xA0000000.toInt(),
                            0x00000000.toInt()
                        )
                    )
            }

        val progressContainer =
            LinearLayout(this).apply {

                orientation =
                    LinearLayout.VERTICAL
            }

        seekBar =
            SeekBar(this).apply {

                max = 1000

                progress = 0

                setPadding(
                    0,
                    0,
                    0,
                    0
                )

                setOnSeekBarChangeListener(
                    object :
                        SeekBar.OnSeekBarChangeListener {

                        override fun onProgressChanged(
                            bar: SeekBar?,
                            progress: Int,
                            fromUser: Boolean
                        ) {

                            if (!fromUser) return

                            try {

                                val duration =
                                    getValidDuration()

                                if (duration > 0L) {

                                    val position =
                                        duration *
                                            progress /
                                            1000L

                                    currentTimeLabel.text =
                                        formatTime(
                                            position
                                        )

                                    totalTimeLabel.text =
                                        formatTime(
                                            duration
                                        )
                                }

                            } catch (e: Exception) {

                                Log.e(
                                    TAG,
                                    "Seek preview failed",
                                    e
                                )
                            }
                        }

                        override fun onStartTrackingTouch(
                            bar: SeekBar?
                        ) {

                            controlsHandler
                                .removeCallbacks(
                                    controlsHideRunnable
                                )

                            showControls()
                        }

                        override fun onStopTrackingTouch(
                            bar: SeekBar?
                        ) {

                            try {

                                val p =
                                    player
                                        ?: return

                                val duration =
                                    getValidDuration()

                                if (duration > 0L) {

                                    val target =
                                        duration *
                                            seekBar.progress /
                                            1000L

                                    p.seekTo(
                                        target
                                    )
                                }

                                updateProgress()

                                scheduleControlsHide()

                            } catch (e: Exception) {

                                Log.e(
                                    TAG,
                                    "Seek failed",
                                    e
                                )

                                showError(
                                    "Unable to seek video."
                                )
                            }
                        }
                    }
                )
            }

        progressContainer.addView(
            seekBar,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(32)
            )
        )

        val durationRow =
            LinearLayout(this).apply {

                orientation =
                    LinearLayout.HORIZONTAL

                gravity =
                    Gravity.CENTER_VERTICAL

                setPadding(
                    dp(4),
                    0,
                    dp(4),
                    0
                )
            }

        currentTimeLabel =
            TextView(this).apply {

                text = "0:00"

                textSize = 12f

                setTextColor(
                    0xFFE8E8E8.toInt()
                )

                gravity =
                    Gravity.START or
                        Gravity.CENTER_VERTICAL
            }

        totalTimeLabel =
            TextView(this).apply {

                text = "0:00"

                textSize = 12f

                setTextColor(
                    0xFFE8E8E8.toInt()
                )

                gravity =
                    Gravity.END or
                        Gravity.CENTER_VERTICAL
            }

        durationRow.addView(
            currentTimeLabel,
            LinearLayout.LayoutParams(
                0,
                dp(24),
                1f
            )
        )

        durationRow.addView(
            totalTimeLabel,
            LinearLayout.LayoutParams(
                0,
                dp(24),
                1f
            )
        )

        progressContainer.addView(
            durationRow,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(24)
            )
        )

        bottomControls.addView(
            progressContainer,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(58)
            )
        )

        // -----------------------------------------------------
        // ACTION BUTTONS
        // -----------------------------------------------------

        val actionRow =
            LinearLayout(this).apply {

                orientation =
                    LinearLayout.HORIZONTAL

                gravity =
                    Gravity.CENTER_VERTICAL
            }

        qualityButton =
            makeBottomButton(
                "⚙  AUTO",
                "Video quality",
                11f
            )

        speedButton =
            makeBottomButton(
                "1×",
                "Playback speed",
                12f
            )

        fullscreenButton =
            makeBottomButton(
                "⛶",
                "Enter fullscreen",
                21f
            )

        actionRow.addView(
            qualityButton,
            LinearLayout.LayoutParams(
                dp(82),
                dp(44)
            ).apply {

                marginEnd =
                    dp(7)
            }
        )

        actionRow.addView(
            speedButton,
            LinearLayout.LayoutParams(
                dp(52),
                dp(42)
            ).apply {

                marginEnd =
                    dp(7)
            }
        )

        actionRow.addView(
            android.widget.Space(this),
            LinearLayout.LayoutParams(
                0,
                dp(42),
                1f
            )
        )

        actionRow.addView(
            fullscreenButton,
            LinearLayout.LayoutParams(
                dp(50),
                dp(42)
            )
        )

        bottomControls.addView(
            actionRow,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(48)
            )
        )

        controlsOverlay.addView(
            bottomControls,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                dp(136)
            ).apply {

                gravity =
                    Gravity.BOTTOM
            }
        )

        // -----------------------------------------------------
        // BUTTON ACTIONS
        // -----------------------------------------------------

        qualityButton.setOnClickListener {

            try {

                showQualityDialog()

                showControls()

            } catch (e: Exception) {

                Log.e(
                    TAG,
                    "Quality dialog failed",
                    e
                )

                showError(
                    "Unable to open video quality."
                )
            }
        }

        speedButton.setOnClickListener {

            try {

                showSpeedDialog()

            } catch (e: Exception) {

                Log.e(
                    TAG,
                    "Speed dialog failed",
                    e
                )
            }
        }

        fullscreenButton.setOnClickListener {

            try {

                toggleOrientation()

            } catch (e: Exception) {

                Log.e(
                    TAG,
                    "Fullscreen failed",
                    e
                )
            }
        }

        rewindButton.setOnClickListener {

            try {

                player?.let { p ->

                    p.seekTo(
                        (
                            p.currentPosition -
                                SEEK_INCREMENT_MS
                            ).coerceAtLeast(0L)
                    )

                    showControls()
                }

            } catch (e: Exception) {

                Log.e(
                    TAG,
                    "Rewind failed",
                    e
                )
            }
        }

        forwardButton.setOnClickListener {

            try {

                player?.let { p ->

                    val duration =
                        p.duration

                    val target =
                        p.currentPosition +
                            SEEK_INCREMENT_MS

                    p.seekTo(
                        if (duration > 0L) {

                            target.coerceAtMost(
                                duration
                            )

                        } else {

                            target
                        }
                    )

                    showControls()
                }

            } catch (e: Exception) {

                Log.e(
                    TAG,
                    "Forward failed",
                    e
                )
            }
        }

        playPauseButton.setOnClickListener {

            try {

                val p =
                    player
                        ?: run {

                            showError(
                                "Video player is not available."
                            )

                            return@setOnClickListener
                        }

                if (p.isPlaying) {

                    p.pause()

                } else {

                    p.play()
                }

                updatePlayPauseButton()

                showControls()

            } catch (e: Exception) {

                Log.e(
                    TAG,
                    "Play/pause failed",
                    e
                )

                showError(
                    "Unable to control video playback."
                )
            }
        }

        controlsOverlay.bringToFront()

        topBar.bringToFront()

        showControls()
    }

    // =========================================================
    // CONTROLS VISIBILITY
    // =========================================================

    private fun showControls() {

        try {

            controlsVisible = true

            if (::controlsOverlay.isInitialized) {

                controlsOverlay
                    .animate()
                    .cancel()

                controlsOverlay.alpha = 1f

                controlsOverlay.visibility =
                    View.VISIBLE
            }

            if (::topBar.isInitialized) {

                topBar.visibility =
                    View.VISIBLE
            }

            updatePlayPauseButton()

            scheduleControlsHide()

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Show controls failed",
                e
            )
        }
    }

    private fun hideControls(
        immediate: Boolean
    ) {

        try {

            controlsVisible = false

            controlsHandler
                .removeCallbacks(
                    controlsHideRunnable
                )

            if (!::controlsOverlay.isInitialized) {
                return
            }

            if (immediate) {

                controlsOverlay.visibility =
                    View.GONE

                if (::topBar.isInitialized) {

                    topBar.visibility =
                        View.GONE
                }

                return
            }

            controlsOverlay
                .animate()
                .alpha(0f)
                .setDuration(220L)
                .withEndAction {

                    try {

                        controlsOverlay.visibility =
                            View.GONE

                        controlsOverlay.alpha =
                            1f

                        if (::topBar.isInitialized) {

                            topBar.visibility =
                                View.GONE
                        }

                    } catch (e: Exception) {

                        Log.e(
                            TAG,
                            "Hide controls end failed",
                            e
                        )
                    }
                }
                .start()

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Hide controls failed",
                e
            )
        }
    }

    private fun scheduleControlsHide() {

        try {

            controlsHandler
                .removeCallbacks(
                    controlsHideRunnable
                )

            controlsHandler.postDelayed(
                controlsHideRunnable,
                CONTROL_HIDE_DELAY
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Schedule controls failed",
                e
            )
        }
    }

    // =========================================================
    // PLAY / PAUSE
    // =========================================================

    private fun updatePlayPauseButton() {

        try {

            if (!::playPauseButton.isInitialized) {
                return
            }

            val p =
                player ?: return

            playPauseButton.text =
                if (p.isPlaying) {

                    "Ⅱ"

                } else {

                    "▶"
                }

            playPauseButton.contentDescription =
                if (p.isPlaying) {

                    "Pause"

                } else {

                    "Play"
                }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Play button update failed",
                e
            )
        }
    }

    // =========================================================
    // PROGRESS
    // =========================================================

    private fun updateProgress() {

        try {

            if (
                !::seekBar.isInitialized ||
                !::currentTimeLabel.isInitialized ||
                !::totalTimeLabel.isInitialized
            ) {
                return
            }

            val p =
                player ?: return

            val duration =
                getValidDuration()

            val position =
                p.currentPosition.coerceAtLeast(
                    0L
                )

            if (duration > 0L) {

                seekBar.progress =
                    (
                        (
                            position.toDouble() /
                                duration.toDouble()
                            ) * 1000.0
                        )
                        .toInt()
                        .coerceIn(
                            0,
                            1000
                        )

                currentTimeLabel.text =
                    formatTime(
                        position.coerceAtMost(
                            duration
                        )
                    )

                totalTimeLabel.text =
                    formatTime(
                        duration
                    )

            } else {

                seekBar.progress = 0

                currentTimeLabel.text =
                    formatTime(position)

                totalTimeLabel.text =
                    "0:00"
            }

            updatePlayPauseButton()

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Update progress failed",
                e
            )
        }
    }

    private fun getValidDuration(): Long {

        return try {

            val duration =
                player?.duration
                    ?: 0L

            if (
                duration ==
                    C.TIME_UNSET ||
                duration <= 0L
            ) {

                0L

            } else {

                duration
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Get duration failed",
                e
            )

            0L
        }
    }

    private fun formatTime(
        milliseconds: Long
    ): String {

        if (milliseconds <= 0L) {
            return "0:00"
        }

        val totalSeconds =
            milliseconds / 1000L

        val seconds =
            totalSeconds % 60L

        val minutes =
            (totalSeconds / 60L) % 60L

        val hours =
            totalSeconds / 3600L

        return if (hours > 0L) {

            String.format(
                java.util.Locale.US,
                "%d:%02d:%02d",
                hours,
                minutes,
                seconds
            )

        } else {

            String.format(
                java.util.Locale.US,
                "%d:%02d",
                minutes,
                seconds
            )
        }
    }

    // =========================================================
    // SPEED DIALOG
    // =========================================================

    private fun showSpeedDialog() {

        val p =
            player

        if (p == null) {

            showError(
                "Video player is not available."
            )

            return
        }

        try {

            val speeds =
                listOf(
                    0.5f,
                    0.75f,
                    1f,
                    1.25f,
                    1.5f,
                    1.75f,
                    2f
                )

            val labels =
                speeds.map { speed ->

                    if (speed == 1f) {

                        "1×"

                    } else {

                        "${speed}×"
                    }

                }.toTypedArray()

            val current =
                p.playbackParameters.speed

            val currentIndex =
                speeds.indices.minByOrNull {

                    kotlin.math.abs(
                        speeds[it] -
                            current
                    )

                } ?: 2

            android.app.AlertDialog
                .Builder(this)
                .setTitle(
                    "Playback speed"
                )
                .setSingleChoiceItems(
                    labels,
                    currentIndex
                ) { dialog, which ->

                    try {

                        p.setPlaybackSpeed(
                            speeds[which]
                        )

                        speedButton.text =
                            labels[which]

                        dialog.dismiss()

                        showControls()

                    } catch (e: Exception) {

                        Log.e(
                            TAG,
                            "Speed change failed",
                            e
                        )

                        dialog.dismiss()

                        showError(
                            "Unable to change playback speed."
                        )
                    }
                }
                .setNegativeButton(
                    "Cancel",
                    null
                )
                .show()

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Speed dialog failed",
                e
            )

            showError(
                "Unable to open playback speed."
            )
        }
    }

    // =========================================================
    // BUTTON HELPERS
    // =========================================================

    private fun makeIconButton(
        icon: String,
        description: String,
        size: Float
    ): Button =
        Button(this).apply {

            text = icon

            textSize = size

            setTextColor(
                Color.WHITE
            )

            gravity =
                Gravity.CENTER

            setPadding(
                0,
                0,
                0,
                0
            )

            minWidth = 0

            minimumWidth = 0

            minHeight = 0

            minimumHeight = 0

            isAllCaps = false

            contentDescription =
                description

            background =
                GradientDrawable().apply {

                    shape =
                        GradientDrawable.OVAL

                    setColor(
                        0x42000000.toInt()
                    )
                }
        }

    private fun makeCenterButton(
        icon: String,
        description: String,
        size: Float
    ): Button =
        Button(this).apply {

            text = icon

            textSize = size

            setTextColor(
                Color.WHITE
            )

            gravity =
                Gravity.CENTER

            setPadding(
                0,
                0,
                0,
                0
            )

            minWidth = 0

            minimumWidth = 0

            minHeight = 0

            minimumHeight = 0

            isAllCaps = false

            contentDescription =
                description

            background =
                GradientDrawable().apply {

                    shape =
                        GradientDrawable.OVAL

                    setColor(
                        0x52000000.toInt()
                    )
                }

            elevation =
                dp(4).toFloat()
        }

    private fun makePlayPauseButton():
        Button =
        Button(this).apply {

            text = "▶"

            textSize = 31f

            setTextColor(
                Color.WHITE
            )

            gravity =
                Gravity.CENTER

            setPadding(
                dp(3),
                0,
                0,
                0
            )

            minWidth = 0

            minimumWidth = 0

            minHeight = 0

            minimumHeight = 0

            isAllCaps = false

            contentDescription =
                "Play"

            background =
                GradientDrawable().apply {

                    shape =
                        GradientDrawable.OVAL

                    setColor(
                        0xD0000000.toInt()
                    )

                    setStroke(
                        dp(1),
                        0x45FFFFFF.toInt()
                    )
                }

            elevation =
                dp(8).toFloat()
        }

    private fun makeBottomButton(
        textValue: String,
        description: String,
        textSizeSp: Float
    ): Button =
        Button(this).apply {

            text = textValue

            textSize = textSizeSp

            setTextColor(
                Color.WHITE
            )

            gravity =
                Gravity.CENTER

            setPadding(
                0,
                0,
                0,
                0
            )

            minWidth = 0

            minimumWidth = 0

            minHeight = 0

            minimumHeight = 0

            isAllCaps = false

            contentDescription =
                description

            background =
                GradientDrawable().apply {

                    cornerRadius =
                        dp(20).toFloat()

                    setColor(
                        0x4A000000.toInt()
                    )

                    setStroke(
                        dp(1),
                        0x24FFFFFF.toInt()
                    )
                }
        }

    // =========================================================
    // LAYOUT
    // =========================================================

    private fun updateVideoLayout() {

        try {

            if (!::videoContainer.isInitialized) {
                return
            }

            val lp =
                videoContainer.layoutParams
                    as FrameLayout.LayoutParams

            lp.width =
                FrameLayout.LayoutParams.MATCH_PARENT

            lp.height =
                FrameLayout.LayoutParams.MATCH_PARENT

            lp.gravity =
                Gravity.CENTER

            videoContainer.layoutParams =
                lp

            updateOrientationUI(
                resources.configuration.orientation
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Video layout update failed",
                e
            )
        }
    }

    private fun updateOrientationUI(
        orientation: Int
    ) {

        try {

            if (!::fullscreenButton.isInitialized) {
                return
            }

            val landscape =
                orientation ==
                    Configuration.ORIENTATION_LANDSCAPE

            fullscreenButton.text =
                "⛶"

            fullscreenButton.contentDescription =
                if (landscape) {

                    "Exit fullscreen"

                } else {

                    "Enter fullscreen"
                }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Orientation UI failed",
                e
            )
        }
    }

    private fun toggleOrientation() {

        try {

            val isLandscape =
                resources.configuration.orientation ==
                    Configuration.ORIENTATION_LANDSCAPE

            requestedOrientation =
                if (isLandscape) {

                    ActivityInfo
                        .SCREEN_ORIENTATION_PORTRAIT

                } else if (
                    videoAspectRatio < 1f
                ) {
                    // Portrait video: keep fullscreen portrait so the
                    // original vertical composition is not cropped.
                    ActivityInfo
                        .SCREEN_ORIENTATION_PORTRAIT

                } else {

                    // Landscape video: use immersive landscape fullscreen.
                    ActivityInfo
                        .SCREEN_ORIENTATION_LANDSCAPE
                }

            hideSystemBars()

            showControls()

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Toggle orientation failed",
                e
            )

            showError(
                "Unable to change screen orientation."
            )
        }
    }

    // =========================================================
    // INITIALIZE PLAYER
    // =========================================================

    private fun initializePlayer() {

        if (isFinishing || isDestroyed) {
            return
        }

        showLoading()

        hideError()

        controlsHandler
            .removeCallbacks(
                progressRunnable
            )

        try {

            // Detach old video surface from player.
            if (::videoTextureView.isInitialized) {
                player?.clearVideoTextureView(videoTextureView)
            }

            // Release old player.
            player?.release()

            player = null

            // -------------------------------------------------
            // HTTP
            // -------------------------------------------------

            val httpDataSourceFactory =
                DefaultHttpDataSource.Factory()
                    .setUserAgent(
                        "Mozilla/5.0 (Linux; Android) " +
                            "AppleWebKit/537.36 " +
                            "(KHTML, like Gecko) " +
                            "Chrome/120.0.0.0 " +
                            "Mobile Safari/537.36"
                    )
                    .setAllowCrossProtocolRedirects(
                        true
                    )
                    .setConnectTimeoutMs(
                        CONNECTION_TIMEOUT
                    )
                    .setReadTimeoutMs(
                        READ_TIMEOUT
                    )

            // -------------------------------------------------
            // MEDIA SOURCE
            // -------------------------------------------------

            val mediaSourceFactory =
                DefaultMediaSourceFactory(
                    httpDataSourceFactory
                )

            // -------------------------------------------------
            // PLAYER
            // -------------------------------------------------

            val newPlayer =
                ExoPlayer.Builder(this)
                    .setMediaSourceFactory(
                        mediaSourceFactory
                    )
                    .build()

            player =
                newPlayer

            // Attach Media3 player directly to TextureView.
            newPlayer.setVideoTextureView(videoTextureView)

            // -------------------------------------------------
            // LISTENER
            // -------------------------------------------------

            newPlayer.addListener(
                object : Player.Listener {

                    override fun onPlaybackStateChanged(
                        state: Int
                    ) {

                        try {

                            when (state) {

                                Player.STATE_BUFFERING -> {

                                    showLoading()
                                }

                                Player.STATE_READY -> {

                                    hideLoading()

                                    updateProgress()

                                    controlsHandler
                                        .removeCallbacks(
                                            progressRunnable
                                        )

                                    controlsHandler.post(
                                        progressRunnable
                                    )

                                    printVideoTracks(
                                        newPlayer.currentTracks
                                    )

                                    updateQualityButton()

                                    controlsHandler
                                        .postDelayed({

                                            if (
                                                !isFinishing &&
                                                !isDestroyed
                                            ) {

                                                updateQualityButton()
                                            }

                                        }, 500L)
                                }

                                Player.STATE_ENDED -> {

                                    hideLoading()

                                    updateProgress()
                                }

                                Player.STATE_IDLE -> {
                                    // Nothing.
                                }
                            }

                        } catch (e: Exception) {

                            Log.e(
                                TAG,
                                "Playback state error",
                                e
                            )
                        }
                    }

                    override fun onIsPlayingChanged(
                        isPlaying: Boolean
                    ) {

                        try {

                            wasPlaying =
                                isPlaying

                            updatePlayPauseButton()

                        } catch (e: Exception) {

                            Log.e(
                                TAG,
                                "Playing state error",
                                e
                            )
                        }
                    }

                    override fun onTracksChanged(
                        tracks: Tracks
                    ) {

                        try {

                            printVideoTracks(
                                tracks
                            )

                            updateQualityButton()

                            controlsHandler
                                .postDelayed({

                                    if (
                                        !isFinishing &&
                                        !isDestroyed
                                    ) {

                                        updateQualityButton()
                                    }

                                }, 300L)

                        } catch (e: Exception) {

                            Log.e(
                                TAG,
                                "Track change error",
                                e
                            )
                        }
                    }

                    override fun onVideoSizeChanged(
                        videoSize: VideoSize
                    ) {

                        try {

                            videoAspectRatio =
                                if (
                                    videoSize.width > 0 &&
                                    videoSize.height > 0
                                ) {
                                    (
                                        videoSize.width.toFloat() *
                                            videoSize.pixelWidthHeightRatio
                                        ) /
                                            videoSize.height.toFloat()
                                } else {
                                    16f / 9f
                                }

                            if (
                                videoSize.unappliedRotationDegrees == 90 ||
                                videoSize.unappliedRotationDegrees == 270
                            ) {
                                videoAspectRatio =
                                    1f / videoAspectRatio
                            }

                            if (
                                videoAspectRatio.isFinite() &&
                                videoAspectRatio > 0f
                            ) {
                                videoTextureView.setVideoAspectRatio(
                                    videoSize.width,
                                    videoSize.height,
                                    videoSize.pixelWidthHeightRatio,
                                    videoSize.unappliedRotationDegrees
                                )
                            }

                            Log.d(
                                TAG,
                                "VIDEO SIZE = ${videoSize.width}x${videoSize.height}, " +
                                    "pixelRatio=${videoSize.pixelWidthHeightRatio}, " +
                                    "rotation=${videoSize.unappliedRotationDegrees}, " +
                                    "aspect=$videoAspectRatio"
                            )

                        } catch (e: Exception) {

                            Log.e(
                                TAG,
                                "Video size update failed",
                                e
                            )
                        }
                    }

                    override fun onTimelineChanged(
                        timeline:
                            androidx.media3.common.Timeline,
                        reason: Int
                    ) {

                        try {

                            updateProgress()

                        } catch (e: Exception) {

                            Log.e(
                                TAG,
                                "Timeline error",
                                e
                            )
                        }
                    }

                    override fun onPlayerError(
                        error: PlaybackException
                    ) {

                        Log.e(
                            TAG,
                            "VIDEO PLAYBACK ERROR",
                            error
                        )

                        hideLoading()

                        showError(
                            getReadableError(
                                error
                            )
                        )
                    }
                }
            )

            // -------------------------------------------------
            // MEDIA ITEM
            // -------------------------------------------------

            val mediaItemBuilder =
                MediaItem.Builder()
                    .setUri(
                        Uri.parse(videoUrl)
                    )

            // HLS.
            if (
                videoUrl
                    .substringBefore("?")
                    .lowercase()
                    .endsWith(".m3u8")
            ) {

                mediaItemBuilder
                    .setMimeType(
                        MimeTypes.APPLICATION_M3U8
                    )
            }

            val mediaItem =
                mediaItemBuilder.build()

            // -------------------------------------------------
            // PREPARE
            // -------------------------------------------------

            newPlayer.setMediaItem(
                mediaItem
            )

            newPlayer.prepare()

            // -------------------------------------------------
            // RESUME
            // -------------------------------------------------

            if (lastPosition > 0L) {

                newPlayer.seekTo(
                    lastPosition
                )
            }

            newPlayer.playWhenReady =
                true

            updatePlayPauseButton()

            showControls()

            Log.d(
                TAG,
                "Player initialized: $videoUrl"
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Player initialization failed",
                e
            )

            player?.release()

            player = null

            if (
                !isFinishing &&
                !isDestroyed
            ) {

                showError(
                    "Unable to initialize video player.\n\n" +
                        (
                            e.message
                                ?: "Unknown error"
                            )
                )
            }
        }
    }

    // =========================================================
    // TRACKS
    // =========================================================

    private fun printVideoTracks(
        tracks: Tracks
    ) {

        try {

            var count = 0

            for (group in tracks.groups) {

                if (
                    group.type !=
                        C.TRACK_TYPE_VIDEO
                ) {
                    continue
                }

                for (
                    i in 0 until
                        group.mediaTrackGroup.length
                ) {

                    val format =
                        group.mediaTrackGroup
                            .getFormat(i)

                    Log.d(
                        TAG,
                        "VIDEO TRACK[$count]: " +
                            "${format.width}x" +
                            "${format.height}, " +
                            "bitrate=${format.bitrate}, " +
                            "index=$i"
                    )

                    count++
                }
            }

            Log.d(
                TAG,
                "TOTAL VIDEO TRACKS = $count"
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Print tracks failed",
                e
            )
        }
    }

    private fun getVideoQualities():
        List<VideoQuality> {

        val p =
            player ?: return emptyList()

        val result =
            mutableListOf<VideoQuality>()

        try {

            for (
                group in
                    p.currentTracks.groups
            ) {

                if (
                    group.type !=
                        C.TRACK_TYPE_VIDEO
                ) {
                    continue
                }

                val trackGroup =
                    group.mediaTrackGroup

                for (
                    i in 0 until
                        trackGroup.length
                ) {

                    val format =
                        trackGroup.getFormat(i)

                    if (
                        format.height <= 0 ||
                        format.width <= 0
                    ) {
                        continue
                    }

                    result +=
                        VideoQuality(
                            height =
                                format.height,
                            width =
                                format.width,
                            bitrate =
                                format.bitrate,
                            group =
                                group,
                            trackIndex =
                                i
                        )
                }
            }

            return result
                .groupBy {
                    it.height
                }
                .values
                .mapNotNull {
                    list ->
                    list.maxByOrNull {
                        it.bitrate
                    }
                }
                .sortedByDescending {
                    it.height
                }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Get video qualities failed",
                e
            )

            return emptyList()
        }
    }

    // =========================================================
    // QUALITY DIALOG
    // =========================================================

    private fun showQualityDialog() {

        if (
            player == null ||
            isFinishing ||
            isDestroyed
        ) {

            showError(
                "Video player is not available."
            )

            return
        }

        try {

            val qualities =
                getVideoQualities()

            val dialog =
                android.app.Dialog(this)

            val box =
                LinearLayout(this).apply {

                    orientation =
                        LinearLayout.VERTICAL

                    setPadding(
                        dp(22),
                        dp(18),
                        dp(22),
                        dp(18)
                    )

                    background =
                        GradientDrawable().apply {

                            cornerRadius =
                                dp(18).toFloat()

                            setColor(
                                0xFF171717.toInt()
                            )
                        }
                }

            val title =
                TextView(this).apply {

                    text =
                        "Video quality"

                    textSize = 20f

                    setTextColor(
                        Color.WHITE
                    )

                    setTypeface(
                        typeface,
                        android.graphics.Typeface.BOLD
                    )

                    setPadding(
                        0,
                        0,
                        0,
                        dp(2)
                    )
                }

            box.addView(title)

            val subtitle =
                TextView(this).apply {

                    text =
                        "Choose the playback resolution"

                    textSize = 13f

                    setTextColor(
                        0xFFAAAAAA.toInt()
                    )

                    setPadding(
                        0,
                        0,
                        0,
                        dp(14)
                    )
                }

            box.addView(subtitle)

            val auto =
                dialogButton(
                    if (!userSelectedQuality) {

                        "✓  Auto"

                    } else {

                        "Auto"
                    }
                )

            auto.setOnClickListener {

                try {

                    setAutoQuality()

                    dialog.dismiss()

                } catch (e: Exception) {

                    Log.e(
                        TAG,
                        "Auto quality failed",
                        e
                    )

                    dialog.dismiss()

                    showError(
                        "Unable to change quality."
                    )
                }
            }

            box.addView(auto)

            if (qualities.isEmpty()) {

                val unavailable =
                    TextView(this).apply {

                        text =
                            "This video provides no additional resolution variants."

                        textSize = 13f

                        setTextColor(
                            0xFFAAAAAA.toInt()
                        )

                        setPadding(
                            dp(12),
                            dp(8),
                            dp(12),
                            dp(12)
                        )
                    }

                box.addView(
                    unavailable
                )
            }

            qualities.forEach { quality ->

                val label =
                    if (
                        quality.bitrate > 0
                    ) {

                        "${quality.height}p   " +
                            "${formatBitrate(
                                quality.bitrate
                            )}"

                    } else {

                        "${quality.height}p"
                    }

                val selected =
                    userSelectedQuality &&
                        qualityButton
                            .text
                            .toString()
                            .contains(
                                "${quality.height}p"
                            )

                val button =
                    dialogButton(
                        if (selected) {

                            "✓  $label"

                        } else {

                            label
                        }
                    )

                button.setOnClickListener {

                    try {

                        setVideoQuality(
                            quality
                        )

                        dialog.dismiss()

                    } catch (e: Exception) {

                        Log.e(
                            TAG,
                            "Quality selection failed",
                            e
                        )

                        dialog.dismiss()

                        showError(
                            "Unable to change video quality."
                        )
                    }
                }

                box.addView(button)
            }

            dialog.setContentView(box)

            dialog.setCanceledOnTouchOutside(
                true
            )

            dialog.setOnDismissListener {
                showControls()
            }

            dialog.show()

            dialog.window
                ?.setBackgroundDrawableResource(
                    android.R.color.transparent
                )

            val width =
                minOf(
                    dp(360),
                    (
                        resources.displayMetrics
                            .widthPixels *
                            0.88f
                        ).toInt()
                )

            dialog.window?.setLayout(
                width,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Quality dialog failed",
                e
            )

            showError(
                "Unable to open video quality."
            )
        }
    }

    // =========================================================
    // DIALOG BUTTON
    // =========================================================

    private fun dialogButton(
        textValue: String
    ): Button =
        Button(this).apply {

            text =
                textValue

            textSize = 15f

            setTextColor(
                Color.WHITE
            )

            gravity =
                Gravity.START or
                    Gravity.CENTER_VERTICAL

            setPadding(
                dp(12),
                0,
                dp(12),
                0
            )

            background =
                GradientDrawable().apply {

                    cornerRadius =
                        dp(12).toFloat()

                    setColor(
                        0xFF242424.toInt()
                    )

                    setStroke(
                        dp(1),
                        0x18FFFFFF.toInt()
                    )
                }

            layoutParams =
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    dp(48)
                ).apply {

                    bottomMargin =
                        dp(7)
                }
        }

    // =========================================================
    // AUTO QUALITY
    // =========================================================

    private fun setAutoQuality() {

        val p =
            player ?: run {

                showError(
                    "Video player is not available."
                )

                return
            }

        try {

            val params =
                p.trackSelectionParameters
                    .buildUpon()
                    .clearOverridesOfType(
                        C.TRACK_TYPE_VIDEO
                    )
                    .clearVideoSizeConstraints()
                    .setForceHighestSupportedBitrate(
                        false
                    )
                    .build()

            p.trackSelectionParameters =
                params

            userSelectedQuality =
                false

            qualityButton.text =
                "⚙  AUTO"

            Log.d(
                TAG,
                "QUALITY = AUTO"
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Auto quality failed",
                e
            )

            showError(
                "Unable to change video quality."
            )
        }
    }

    // =========================================================
    // MANUAL QUALITY
    // =========================================================

    private fun setVideoQuality(
        q: VideoQuality
    ) {

        val p =
            player ?: run {

                showError(
                    "Video player is not available."
                )

                return
            }

        try {

            val position =
                p.currentPosition

            val playing =
                p.isPlaying

            val override =
                TrackSelectionOverride(
                    q.group.mediaTrackGroup,
                    listOf(
                        q.trackIndex
                    )
                )

            val params =
                p.trackSelectionParameters
                    .buildUpon()
                    .clearOverridesOfType(
                        C.TRACK_TYPE_VIDEO
                    )
                    .clearVideoSizeConstraints()
                    .setForceHighestSupportedBitrate(
                        false
                    )
                    .addOverride(
                        override
                    )
                    .build()

            p.trackSelectionParameters =
                params

            if (position > 0L) {

                p.seekTo(
                    position
                )
            }

            p.playWhenReady =
                playing

            userSelectedQuality =
                true

            qualityButton.text =
                "⚙  ${q.height}p"

            Log.d(
                TAG,
                "QUALITY SELECTED = " +
                    "${q.width}x" +
                    "${q.height}, " +
                    "bitrate=${q.bitrate}, " +
                    "track=${q.trackIndex}"
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Manual quality failed",
                e
            )

            showError(
                "Unable to change video quality.\n\n" +
                    "Please try again."
            )
        }
    }

    // =========================================================
    // QUALITY BUTTON
    // =========================================================

    private fun updateQualityButton() {

        try {

            if (!::qualityButton.isInitialized) {
                return
            }

            qualityButton.visibility =
                View.VISIBLE

            val qualities =
                getVideoQualities()

            if (!userSelectedQuality) {

                qualityButton.text =
                    "⚙  AUTO"
            }

            Log.d(
                TAG,
                "QUALITY BUTTON VISIBLE. " +
                    "OPTIONS=${qualities.size}"
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Update quality button failed",
                e
            )
        }
    }

    private fun formatBitrate(
        bitrate: Int
    ): String {

        if (bitrate <= 0) {
            return ""
        }

        return if (
            bitrate >= 1_000_000
        ) {

            String.format(
                java.util.Locale.US,
                "%.1f Mbps",
                bitrate / 1_000_000.0
            )

        } else {

            "${bitrate / 1000} Kbps"
        }
    }

    // =========================================================
    // LOADING
    // =========================================================

    private fun showLoading() {

        try {

            if (::loadingView.isInitialized) {

                loadingView.visibility =
                    View.VISIBLE
            }

            if (::errorContainer.isInitialized) {

                errorContainer.visibility =
                    View.GONE
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Show loading failed",
                e
            )
        }
    }

    private fun hideLoading() {

        try {

            if (::loadingView.isInitialized) {

                loadingView.visibility =
                    View.GONE
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Hide loading failed",
                e
            )
        }
    }

    // =========================================================
    // ERROR DIALOG
    // =========================================================

    private fun showError(
        message: String
    ) {

        runOnUiThread {

            try {

                hideLoading()

                if (
                    isFinishing ||
                    isDestroyed
                ) {
                    return@runOnUiThread
                }

                errorDialog?.dismiss()

                errorDialog =
                    android.app.AlertDialog
                        .Builder(this)
                        .setTitle(
                            "Video Error"
                        )
                        .setMessage(
                            message
                        )
                        .setCancelable(false)
                        .setNegativeButton(
                            "Close"
                        ) { dialog, _ ->

                            dialog.dismiss()

                            finish()
                        }
                        .setPositiveButton(
                            "Retry"
                        ) { dialog, _ ->

                            dialog.dismiss()

                            hideError()

                            initializePlayer()
                        }
                        .create()

                errorDialog?.setOnShowListener {

                    try {

                        errorDialog
                            ?.getButton(
                                android.app.AlertDialog
                                    .BUTTON_POSITIVE
                            )
                            ?.setTextColor(
                                Color.WHITE
                            )

                        errorDialog
                            ?.getButton(
                                android.app.AlertDialog
                                    .BUTTON_NEGATIVE
                            )
                            ?.setTextColor(
                                Color.WHITE
                            )

                    } catch (e: Exception) {

                        Log.e(
                            TAG,
                            "Dialog button setup failed",
                            e
                        )
                    }
                }

                errorDialog?.show()

                // Keep existing fallback error UI updated.
                if (
                    ::errorContainer.isInitialized
                ) {

                    errorContainer.visibility =
                        View.VISIBLE

                    errorText.text =
                        message
                }

            } catch (e: Exception) {

                Log.e(
                    TAG,
                    "Failed to show error dialog",
                    e

                )

                // Last fallback.
                try {

                    if (
                        ::errorContainer.isInitialized
                    ) {

                        errorContainer.visibility =
                            View.VISIBLE

                        errorText.text =
                            message
                    }

                    Toast.makeText(
                        this,
                        message,
                        Toast.LENGTH_LONG
                    ).show()

                } catch (ignored: Exception) {

                    Log.e(
                        TAG,
                        "Error fallback failed",
                        ignored
                    )
                }
            }
        }
    }

    private fun hideError() {

        try {

            errorDialog?.dismiss()

            errorDialog = null

            if (
                ::errorContainer.isInitialized
            ) {

                errorContainer.visibility =
                    View.GONE
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Hide error failed",
                e
            )
        }
    }

    // =========================================================
    // ERROR MESSAGE
    // =========================================================

    private fun getReadableError(
        error: PlaybackException
    ): String {

        Log.e(
            TAG,
            "Playback error code = " +
                error.errorCodeName
        )

        Log.e(
            TAG,
            "Playback error message = " +
                error.message
        )

        val cause =
            error.cause

        // -----------------------------------------------------
        // HTTP
        // -----------------------------------------------------

        if (
            error.errorCode ==
                PlaybackException
                    .ERROR_CODE_IO_BAD_HTTP_STATUS
        ) {

            val code =
                (
                    cause as? androidx.media3
                        .datasource
                        .HttpDataSource
                        .InvalidResponseCodeException
                    )
                    ?.responseCode

            return when (code) {

                400 -> {

                    "Bad video request (HTTP 400).\n\n" +
                        "The video URL may be invalid."
                }

                401 -> {

                    "Video authorization failed " +
                        "(HTTP 401).\n\n" +
                        "Please check video access permission."
                }

                403 -> {

                    "Video access denied " +
                        "(HTTP 403).\n\n" +
                        "Please check Google Drive/Bunny " +
                        "permissions and security settings."
                }

                404 -> {

                    "Video not found " +
                        "(HTTP 404).\n\n" +
                        "The video may have been deleted " +
                        "or the URL is invalid."
                }

                408 -> {

                    "Video request timed out " +
                        "(HTTP 408).\n\n" +
                        "Please try again."
                }

                429 -> {

                    "Too many video requests " +
                        "(HTTP 429).\n\n" +
                        "Please try again later."
                }

                500, 502, 503, 504 -> {

                    "Video server is temporarily unavailable " +
                        "(HTTP $code).\n\n" +
                        "Please try again later."
                }

                else -> {

                    if (code != null) {

                        "Video server returned HTTP $code."

                    } else {

                        "Unable to load video from server."
                    }
                }
            }
        }

        // -----------------------------------------------------
        // NETWORK
        // -----------------------------------------------------

        if (
            error.errorCode ==
                PlaybackException
                    .ERROR_CODE_IO_NETWORK_CONNECTION_FAILED
        ) {

            return (
                "Network connection failed.\n\n" +
                    "Please check your internet connection " +
                    "and try again."
                )
        }

        if (
            error.errorCode ==
                PlaybackException
                    .ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT
        ) {

            return (
                "Video connection timed out.\n\n" +
                    "Please check your internet connection " +
                    "and try again."
                )
        }

        // -----------------------------------------------------
        // MALFORMED VIDEO
        // -----------------------------------------------------

        if (
            error.errorCode ==
                PlaybackException
                    .ERROR_CODE_PARSING_CONTAINER_MALFORMED
        ) {

            return (
                "The video format is not supported " +
                    "or the video file is corrupted."
                )
        }

        // -----------------------------------------------------
        // DECODER
        // -----------------------------------------------------

        if (
            error.errorCode ==
                PlaybackException
                    .ERROR_CODE_DECODER_INIT_FAILED
        ) {

            return (
                "This video cannot be decoded on this device.\n\n" +
                    "Please try another video quality."
                )
        }

        if (
            error.errorCode ==
                PlaybackException
                    .ERROR_CODE_DECODING_FAILED
        ) {

            return (
                "Video decoding failed.\n\n" +
                    "Please retry or choose another quality."
                )
        }

        // -----------------------------------------------------
        // SOURCE ERROR
        // -----------------------------------------------------

        if (
            error.errorCode ==
                PlaybackException
                    .ERROR_CODE_IO_FILE_NOT_FOUND
        ) {

            return (
                "Video file was not found.\n\n" +
                    "Please contact support if the problem continues."
                )
        }

        // -----------------------------------------------------
        // FALLBACK
        // -----------------------------------------------------

        return (
            "Unable to play this video.\n\n" +
                "Error: ${error.errorCodeName}"
            )
    }

    // =========================================================
    // CONFIGURATION
    // =========================================================

    override fun onConfigurationChanged(
        newConfig: Configuration
    ) {

        try {

            super.onConfigurationChanged(
                newConfig
            )

            updateVideoLayout()

            hideSystemBars()

            updateOrientationUI(
                newConfig.orientation
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Configuration change failed",
                e
            )
        }
    }

    // =========================================================
    // SYSTEM BARS
    // =========================================================

    private fun hideSystemBars() {

        try {

            WindowCompat
                .setDecorFitsSystemWindows(
                    window,
                    false
                )

            WindowInsetsControllerCompat(
                window,
                window.decorView
            ).apply {

                hide(
                    WindowInsetsCompat
                        .Type
                        .statusBars() or
                        WindowInsetsCompat
                            .Type
                            .navigationBars()
                )

                systemBarsBehavior =
                    WindowInsetsControllerCompat
                        .BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Hide system bars failed",
                e
            )
        }
    }

    // =========================================================
    // WINDOW FOCUS
    // =========================================================

    override fun onWindowFocusChanged(
        hasFocus: Boolean
    ) {

        try {

            super.onWindowFocusChanged(
                hasFocus
            )

            if (hasFocus) {

                hideSystemBars()
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Window focus failed",
                e
            )
        }
    }

    // =========================================================
    // PAUSE
    // =========================================================

    override fun onPause() {

        try {

            super.onPause()

            player?.let { p ->

                lastPosition =
                    p.currentPosition

                wasPlaying =
                    p.isPlaying
            }

            player?.pause()

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Pause failed",
                e
            )
        }
    }

    // =========================================================
    // RESUME
    // =========================================================

    override fun onResume() {

        try {

            super.onResume()

            hideSystemBars()

            if (
                player != null &&
                wasPlaying &&
                !isFinishing &&
                !isDestroyed
            ) {

                player?.playWhenReady =
                    true
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Resume failed",
                e
            )
        }
    }

    // =========================================================
    // DESTROY
    // =========================================================

    override fun onDestroy() {

        try {

            controlsHandler
                .removeCallbacks(
                    controlsHideRunnable
                )

            controlsHandler
                .removeCallbacks(
                    progressRunnable
                )

            errorDialog?.dismiss()

            errorDialog = null

            if (::videoTextureView.isInitialized) {
                player?.clearVideoTextureView(videoTextureView)
            }

            player?.release()

            player = null

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Player cleanup failed",
                e
            )
        }

        super.onDestroy()
    }

    // =========================================================
    // DP
    // =========================================================

    private fun dp(
        value: Int
    ): Int {

        return (
            value *
                resources
                    .displayMetrics
                    .density
            ).toInt()
    }
}