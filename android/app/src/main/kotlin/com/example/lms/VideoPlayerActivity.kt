package com.webinarhub.lms

import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.graphics.Color
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
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView

class VideoPlayerActivity : ComponentActivity() {

    companion object {
        private const val TAG = "VideoPlayer"
        private const val SEEK_INCREMENT_MS = 10_000L
    }

    private var player: ExoPlayer? = null

    private lateinit var rootView: FrameLayout
    private lateinit var videoContainer: FrameLayout
    private lateinit var playerView: PlayerView
    private lateinit var loadingView: ProgressBar
    private lateinit var errorContainer: FrameLayout
    private lateinit var errorText: TextView
    private lateinit var retryButton: Button
    private lateinit var titleView: TextView
    private lateinit var topBar: LinearLayout

    // Professional custom Netflix-style controller.
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

    private val controlsHandler = Handler(Looper.getMainLooper())
    private val controlsHideRunnable = Runnable { hideControls(true) }
    private val progressRunnable = object : Runnable {
        override fun run() {
            updateProgress()
            controlsHandler.postDelayed(this, 500L)
        }
    }

    private var controlsVisible = true

    private var videoUrl = ""
    private var videoTitle = "Video"
    private var lastPosition = 0L
    private var wasPlaying = true
    private var userSelectedQuality = false

    private data class VideoQuality(
        val height: Int,
        val width: Int,
        val bitrate: Int,
        val group: Tracks.Group,
        val trackIndex: Int
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        // Do not lock the Activity to landscape.
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED

        videoUrl = intent.getStringExtra("videoUrl") ?: ""
        videoTitle = intent.getStringExtra("title") ?: "Video"
        lastPosition = intent.getLongExtra("lastPosition", 0L)

        createPlayerUI()
        updateOrientationUI(resources.configuration.orientation)
        hideSystemBars()

        if (videoUrl.isBlank()) {
            showError("Video URL is empty")
            return
        }

        if (!videoUrl.startsWith("https://") && !videoUrl.startsWith("http://")) {
            showError("Invalid video URL")
            return
        }

        initializePlayer()
    }

    private fun createPlayerUI() {
        rootView = FrameLayout(this).apply {
            setBackgroundColor(Color.BLACK)
        }

        videoContainer = FrameLayout(this).apply {
            setBackgroundColor(Color.BLACK)
        }

        rootView.addView(
            videoContainer,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        // Media3 1.4.1-compatible PlayerView.
        // Do not use setControllerLayoutId(): it is not available in this
        // Media3 version. Quality + Fullscreen are added as a bottom overlay.
        playerView = PlayerView(this).apply {
            // Native Media3 controls are disabled. The custom controller below
            // owns play/pause, seek, quality, speed and fullscreen.
            useController = false
            keepScreenOn = true
            resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT
            setShowBuffering(PlayerView.SHOW_BUFFERING_WHEN_PLAYING)
            setShutterBackgroundColor(Color.BLACK)
        }

        videoContainer.addView(
            playerView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        playerView.setOnClickListener {
            if (controlsVisible) {
                hideControls(false)
            } else {
                showControls()
            }
        }

        // ---------------------------------------------------------
        // NETFLIX-STYLE TOP BAR
        // ---------------------------------------------------------
        topBar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(14), dp(18), dp(18), dp(18))
            background = GradientDrawable(
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

        val backButton = makeIconButton("‹", "Back", 31f).apply {
            setOnClickListener { finish() }
        }

        topBar.addView(
            backButton,
            LinearLayout.LayoutParams(dp(46), dp(46))
        )

        titleView = TextView(this).apply {
            text = videoTitle
            textSize = 17f
            setTextColor(Color.WHITE)
            maxLines = 1
            ellipsize = android.text.TextUtils.TruncateAt.END
            gravity = Gravity.CENTER_VERTICAL
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(dp(10), 0, dp(8), 0)
        }

        topBar.addView(
            titleView,
            LinearLayout.LayoutParams(0, dp(46), 1f)
        )

        setupProfessionalControls()

        // ---------------------------------------------------------
        // LOADING
        // ---------------------------------------------------------
        loadingView = ProgressBar(this).apply {
            visibility = View.GONE
        }

        videoContainer.addView(
            loadingView,
            FrameLayout.LayoutParams(
                dp(48),
                dp(48),
                Gravity.CENTER
            )
        )

        // ---------------------------------------------------------
        // ERROR
        // ---------------------------------------------------------
        errorContainer = FrameLayout(this).apply {
            visibility = View.GONE
            setBackgroundColor(0xFF080808.toInt())
        }

        rootView.addView(
            errorContainer,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        errorText = TextView(this).apply {
            textSize = 17f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            setPadding(dp(30), dp(30), dp(30), dp(30))
        }

        errorContainer.addView(
            errorText,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER
            )
        )

        retryButton = Button(this).apply {
            text = "Try again"
            textSize = 14f
            setTextColor(Color.WHITE)
            isAllCaps = false
            background = GradientDrawable().apply {
                cornerRadius = dp(22).toFloat()
                setColor(0xFF303030.toInt())
            }
            setPadding(dp(24), 0, dp(24), 0)

            setOnClickListener {
                hideError()
                initializePlayer()
            }
        }

        errorContainer.addView(
            retryButton,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                dp(46),
                Gravity.CENTER
            ).apply {
                topMargin = dp(130)
            }
        )

        setContentView(rootView)

        rootView.viewTreeObserver.addOnGlobalLayoutListener {
            updateVideoLayout()
        }
    }

    private fun setupProfessionalControls() {
        controlsOverlay = FrameLayout(this).apply {
            setBackgroundColor(Color.TRANSPARENT)
        }

        videoContainer.addView(
            controlsOverlay,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        // CENTER: rewind | play/pause | forward
        centerControls = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
        }

        rewindButton = makeCenterButton("↶", "Rewind 10 seconds", 31f)
        playPauseButton = makePlayPauseButton()
        forwardButton = makeCenterButton("↷", "Forward 10 seconds", 31f)

        centerControls.addView(
            rewindButton,
            LinearLayout.LayoutParams(dp(64), dp(64)).apply {
                marginEnd = dp(38)
            }
        )
        centerControls.addView(
            playPauseButton,
            LinearLayout.LayoutParams(dp(84), dp(84))
        )
        centerControls.addView(
            forwardButton,
            LinearLayout.LayoutParams(dp(64), dp(64)).apply {
                marginStart = dp(38)
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

        // BOTTOM: progress + quality + speed + fullscreen
        bottomControls = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(18), dp(8), dp(18), dp(18))
            background = GradientDrawable(
                GradientDrawable.Orientation.BOTTOM_TOP,
                intArrayOf(
                    0xF2000000.toInt(),
                    0xA0000000.toInt(),
                    0x00000000.toInt()
                )
            )
        }

        // Progress area:
        // [===================== SEEK BAR =====================]
        // 0:16                                             2:16:16
        val progressContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
        }

        seekBar = SeekBar(this).apply {
            max = 1000
            progress = 0
            setPadding(0, 0, 0, 0)

            setOnSeekBarChangeListener(
                object : SeekBar.OnSeekBarChangeListener {
                    override fun onProgressChanged(
                        bar: SeekBar?,
                        progress: Int,
                        fromUser: Boolean
                    ) {
                        if (!fromUser) return

                        val duration = getValidDuration()
                        if (duration > 0L) {
                            val position = duration * progress / 1000L
                            currentTimeLabel.text = formatTime(position)
                            totalTimeLabel.text = formatTime(duration)
                        }
                    }

                    override fun onStartTrackingTouch(bar: SeekBar?) {
                        controlsHandler.removeCallbacks(controlsHideRunnable)
                        showControls()
                    }

                    override fun onStopTrackingTouch(bar: SeekBar?) {
                        val p = player ?: return
                        val duration = getValidDuration()

                        if (duration > 0L) {
                            val target =
                                duration * this@VideoPlayerActivity.seekBar.progress / 1000L
                            p.seekTo(target)
                        }

                        updateProgress()
                        scheduleControlsHide()
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

        val durationRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(4), 0, dp(4), 0)
        }

        currentTimeLabel = TextView(this).apply {
            text = "0:00"
            textSize = 12f
            setTextColor(0xFFE8E8E8.toInt())
            gravity = Gravity.START or Gravity.CENTER_VERTICAL
        }

        totalTimeLabel = TextView(this).apply {
            text = "0:00"
            textSize = 12f
            setTextColor(0xFFE8E8E8.toInt())
            gravity = Gravity.END or Gravity.CENTER_VERTICAL
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

        val actionRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        qualityButton = makeBottomButton("⚙  AUTO", "Video quality", 11f)
        speedButton = makeBottomButton("1×", "Playback speed", 12f)
        fullscreenButton = makeBottomButton("⛶", "Enter fullscreen", 21f)

        actionRow.addView(
            qualityButton,
            LinearLayout.LayoutParams(dp(82), dp(44)).apply {
                marginEnd = dp(7)
            }
        )
        actionRow.addView(
            speedButton,
            LinearLayout.LayoutParams(dp(52), dp(42)).apply {
                marginEnd = dp(7)
            }
        )
        actionRow.addView(
            android.widget.Space(this),
            LinearLayout.LayoutParams(0, dp(42), 1f)
        )
        actionRow.addView(
            fullscreenButton,
            LinearLayout.LayoutParams(dp(50), dp(42))
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
                gravity = Gravity.BOTTOM
            }
        )

        qualityButton.setOnClickListener {
            showQualityDialog()
            showControls()
        }

        speedButton.setOnClickListener {
            showSpeedDialog()
        }

        fullscreenButton.setOnClickListener {
            toggleOrientation()
        }

        rewindButton.setOnClickListener {
            player?.let { p ->
                p.seekTo(
                    (p.currentPosition - SEEK_INCREMENT_MS)
                        .coerceAtLeast(0L)
                )
                showControls()
            }
        }

        forwardButton.setOnClickListener {
            player?.let { p ->
                val duration = p.duration
                val target = p.currentPosition + SEEK_INCREMENT_MS

                p.seekTo(
                    if (duration > 0L) {
                        target.coerceAtMost(duration)
                    } else {
                        target
                    }
                )
                showControls()
            }
        }

        playPauseButton.setOnClickListener {
            val p = player ?: return@setOnClickListener

            if (p.isPlaying) {
                p.pause()
            } else {
                p.play()
            }

            updatePlayPauseButton()
            showControls()
        }

        controlsOverlay.bringToFront()
        topBar.bringToFront()

        showControls()
    }

    private fun showControls() {
        controlsVisible = true

        if (::controlsOverlay.isInitialized) {
            controlsOverlay.animate().cancel()
            controlsOverlay.alpha = 1f
            controlsOverlay.visibility = View.VISIBLE
        }

        if (::topBar.isInitialized) {
            topBar.visibility = View.VISIBLE
        }

        updatePlayPauseButton()
        scheduleControlsHide()
    }

    private fun hideControls(immediate: Boolean) {
        controlsVisible = false
        controlsHandler.removeCallbacks(controlsHideRunnable)

        if (!::controlsOverlay.isInitialized) return

        if (immediate) {
            controlsOverlay.visibility = View.GONE
            if (::topBar.isInitialized) {
                topBar.visibility = View.GONE
            }
            return
        }

        controlsOverlay.animate()
            .alpha(0f)
            .setDuration(220L)
            .withEndAction {
                controlsOverlay.visibility = View.GONE
                controlsOverlay.alpha = 1f
                if (::topBar.isInitialized) {
                    topBar.visibility = View.GONE
                }
            }
            .start()
    }

    private fun scheduleControlsHide() {
        controlsHandler.removeCallbacks(controlsHideRunnable)
        controlsHandler.postDelayed(
            controlsHideRunnable,
            4000L
        )
    }

    private fun updatePlayPauseButton() {
        if (!::playPauseButton.isInitialized) return

        val p = player ?: return

        playPauseButton.text = if (p.isPlaying) "Ⅱ" else "▶"
        playPauseButton.contentDescription =
            if (p.isPlaying) "Pause" else "Play"
    }

    private fun updateProgress() {
        if (!::seekBar.isInitialized ||
            !::currentTimeLabel.isInitialized ||
            !::totalTimeLabel.isInitialized
        ) {
            return
        }

        val p = player ?: return
        val duration = getValidDuration()
        val position = p.currentPosition.coerceAtLeast(0L)

        if (duration > 0L) {
            seekBar.progress =
                ((position.toDouble() / duration.toDouble()) * 1000.0)
                    .toInt()
                    .coerceIn(0, 1000)

            currentTimeLabel.text = formatTime(position.coerceAtMost(duration))
            totalTimeLabel.text = formatTime(duration)
        } else {
            seekBar.progress = 0
            currentTimeLabel.text = formatTime(position)
            totalTimeLabel.text = "0:00"
        }

        updatePlayPauseButton()
    }

    private fun getValidDuration(): Long {
        val duration = player?.duration ?: 0L
        return if (duration == C.TIME_UNSET || duration <= 0L) {
            0L
        } else {
            duration
        }
    }

    private fun formatTime(milliseconds: Long): String {
        if (milliseconds <= 0L) return "0:00"

        val totalSeconds = milliseconds / 1000L
        val seconds = totalSeconds % 60L
        val minutes = (totalSeconds / 60L) % 60L
        val hours = totalSeconds / 3600L

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

    private fun showSpeedDialog() {
        val speeds = listOf(
            0.5f,
            0.75f,
            1f,
            1.25f,
            1.5f,
            1.75f,
            2f
        )

        val labels = speeds.map { speed ->
            if (speed == 1f) "1×" else "${speed}×"
        }.toTypedArray()

        val current =
            player?.playbackParameters?.speed ?: 1f

        val currentIndex =
            speeds.indices.minByOrNull {
                kotlin.math.abs(speeds[it] - current)
            } ?: 2

        android.app.AlertDialog.Builder(this)
            .setTitle("Playback speed")
            .setSingleChoiceItems(
                labels,
                currentIndex
            ) { dialog, which ->
                player?.setPlaybackSpeed(speeds[which])
                speedButton.text = labels[which]
                dialog.dismiss()
                showControls()
            }
            .show()
    }

    private fun makeIconButton(
        icon: String,
        description: String,
        size: Float
    ): Button =
        Button(this).apply {
            text = icon
            textSize = size
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 0)
            minWidth = 0
            minimumWidth = 0
            minHeight = 0
            minimumHeight = 0
            isAllCaps = false
            contentDescription = description
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(0x42000000.toInt())
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
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 0)
            minWidth = 0
            minimumWidth = 0
            minHeight = 0
            minimumHeight = 0
            isAllCaps = false
            contentDescription = description
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(0x52000000.toInt())
            }
            elevation = dp(4).toFloat()
        }

    private fun makePlayPauseButton(): Button =
        Button(this).apply {
            text = "▶"
            textSize = 31f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(dp(3), 0, 0, 0)
            minWidth = 0
            minimumWidth = 0
            minHeight = 0
            minimumHeight = 0
            isAllCaps = false
            contentDescription = "Play"
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(0xD0000000.toInt())
                setStroke(dp(1), 0x45FFFFFF.toInt())
            }
            elevation = dp(8).toFloat()
        }

    private fun makeBottomButton(
        textValue: String,
        description: String,
        textSizeSp: Float
    ): Button =
        Button(this).apply {
            text = textValue
            textSize = textSizeSp
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 0)
            minWidth = 0
            minimumWidth = 0
            minHeight = 0
            minimumHeight = 0
            isAllCaps = false
            contentDescription = description
            background = GradientDrawable().apply {
                cornerRadius = dp(20).toFloat()
                setColor(0x4A000000.toInt())
                setStroke(dp(1), 0x24FFFFFF.toInt())
            }
        }

    private fun updateVideoLayout() {
        if (!::videoContainer.isInitialized) return

        // The container fills the complete screen. PlayerView FIT centers the
        // entire video in portrait and landscape without cropping.
        val lp =
            videoContainer.layoutParams
                as FrameLayout.LayoutParams

        lp.width = FrameLayout.LayoutParams.MATCH_PARENT
        lp.height = FrameLayout.LayoutParams.MATCH_PARENT
        lp.gravity = Gravity.CENTER

        videoContainer.layoutParams = lp

        updateOrientationUI(
            resources.configuration.orientation
        )
    }

    private fun updateOrientationUI(orientation: Int) {
        if (!::fullscreenButton.isInitialized) return

        val landscape =
            orientation == Configuration.ORIENTATION_LANDSCAPE

        fullscreenButton.text = "⛶"
        fullscreenButton.contentDescription =
            if (landscape) "Exit fullscreen"
            else "Enter fullscreen"
    }

    private fun toggleOrientation() {
        val isLandscape =
            resources.configuration.orientation ==
                Configuration.ORIENTATION_LANDSCAPE

        requestedOrientation =
            if (isLandscape) {
                ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            } else {
                ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
            }

        hideSystemBars()
        showControls()
    }

    private fun initializePlayer() {
        showLoading()
        controlsHandler.removeCallbacks(progressRunnable)

        if (::playerView.isInitialized) {
            playerView.player = null
        }

        player?.release()
        player = null

        try {
            val httpDataSourceFactory =
                DefaultHttpDataSource.Factory()
                    .setUserAgent(
                        "Mozilla/5.0 (Linux; Android) AppleWebKit/537.36 " +
                            "(KHTML, like Gecko) Chrome/120.0.0.0 " +
                            "Mobile Safari/537.36"
                    )
                    .setAllowCrossProtocolRedirects(true)
                    .setConnectTimeoutMs(30_000)
                    .setReadTimeoutMs(30_000)

            val mediaSourceFactory =
                DefaultMediaSourceFactory(httpDataSourceFactory)

            player = ExoPlayer.Builder(this)
                .setMediaSourceFactory(mediaSourceFactory)
                .build()

            playerView.player = player

            player?.addListener(
                object : Player.Listener {

                    override fun onPlaybackStateChanged(state: Int) {
                        when (state) {
                            Player.STATE_BUFFERING -> showLoading()

                            Player.STATE_READY -> {
                                hideLoading()

                                // Duration is reliable after STATE_READY.
                                updateProgress()
                                controlsHandler.removeCallbacks(progressRunnable)
                                controlsHandler.post(progressRunnable)

                                printVideoTracks(
                                    player?.currentTracks ?: return
                                )
                                updateQualityButton()

                                // HLS adaptive variants can be populated immediately
                                // after READY. Refresh once more shortly afterwards.
                                controlsHandler.postDelayed(
                                    {
                                        if (!isFinishing && !isDestroyed) {
                                            updateQualityButton()
                                        }
                                    },
                                    500L
                                )
                            }

                            Player.STATE_ENDED -> {
                                hideLoading()
                            }
                        }
                    }

                    override fun onIsPlayingChanged(isPlaying: Boolean) {
                        wasPlaying = isPlaying
                        updatePlayPauseButton()
                    }

                    override fun onTracksChanged(tracks: Tracks) {
                        printVideoTracks(tracks)
                        updateQualityButton()

                        controlsHandler.postDelayed(
                            {
                                if (!isFinishing && !isDestroyed) {
                                    updateQualityButton()
                                }
                            },
                            300L
                        )
                    }

                    override fun onTimelineChanged(
                        timeline: androidx.media3.common.Timeline,
                        reason: Int
                    ) {
                        updateProgress()
                    }

                    override fun onPlayerError(
                        error: PlaybackException
                    ) {
                        Log.e(TAG, "VIDEO PLAYBACK ERROR", error)
                        hideLoading()
                        showError(getReadableError(error))
                    }
                }
            )

            val builder =
                MediaItem.Builder()
                    .setUri(Uri.parse(videoUrl))

            if (videoUrl.lowercase().contains(".m3u8")) {
                builder.setMimeType(MimeTypes.APPLICATION_M3U8)
            }

            player?.setMediaItem(builder.build())
            player?.prepare()

            if (lastPosition > 0) {
                player?.seekTo(lastPosition)
            }

            player?.playWhenReady = true

            updatePlayPauseButton()
            showControls()

            Log.d(TAG, "Player initialized: $videoUrl")

        } catch (e: Exception) {
            Log.e(TAG, "Player initialization failed", e)
            showError("Unable to initialize video player")
        }
    }

    private fun printVideoTracks(tracks: Tracks) {
        var count = 0

        for (group in tracks.groups) {
            if (group.type != C.TRACK_TYPE_VIDEO) continue

            for (i in 0 until group.mediaTrackGroup.length) {
                val f = group.mediaTrackGroup.getFormat(i)

                Log.d(
                    TAG,
                    "VIDEO TRACK[$count]: " +
                        "${f.width}x${f.height}, " +
                        "bitrate=${f.bitrate}, index=$i"
                )

                count++
            }
        }

        Log.d(TAG, "TOTAL VIDEO TRACKS = $count")
    }

    private fun getVideoQualities(): List<VideoQuality> {
        val p = player ?: return emptyList()
        val result = mutableListOf<VideoQuality>()

        for (group in p.currentTracks.groups) {
            if (group.type != C.TRACK_TYPE_VIDEO) continue

            val trackGroup = group.mediaTrackGroup

            for (i in 0 until trackGroup.length) {
                val f = trackGroup.getFormat(i)

                // Ignore entries that do not contain a usable resolution.
                if (f.height <= 0 || f.width <= 0) continue

                result += VideoQuality(
                    height = f.height,
                    width = f.width,
                    bitrate = f.bitrate,
                    group = group,
                    trackIndex = i
                )
            }
        }

        // One entry per resolution. If the stream contains multiple tracks
        // for the same height, keep the highest bitrate version.
        return result
            .groupBy { it.height }
            .values
            .mapNotNull { list ->
                list.maxByOrNull { it.bitrate }
            }
            .sortedByDescending { it.height }
    }

    private fun showQualityDialog() {
        val qualities = getVideoQualities()

        Log.d(TAG, "QUALITY OPTIONS = ${qualities.size}")

        val dialog = android.app.Dialog(this)

        val box = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(
                dp(22),
                dp(18),
                dp(22),
                dp(18)
            )

            background = GradientDrawable().apply {
                cornerRadius = dp(18).toFloat()
                setColor(0xFF171717.toInt())
            }
        }

        val title = TextView(this).apply {
            text = "Video quality"
            textSize = 20f
            setTextColor(Color.WHITE)
            setTypeface(
                typeface,
                android.graphics.Typeface.BOLD
            )
            setPadding(0, 0, 0, dp(2))
        }

        box.addView(title)

        val subtitle = TextView(this).apply {
            text = "Choose the playback resolution"
            textSize = 13f
            setTextColor(0xFFAAAAAA.toInt())
            setPadding(0, 0, 0, dp(14))
        }

        box.addView(subtitle)

        val auto = dialogButton(
            if (!userSelectedQuality) "✓  Auto" else "Auto"
        )

        auto.setOnClickListener {
            setAutoQuality()
            dialog.dismiss()
        }

        box.addView(auto)

        if (qualities.isEmpty()) {
            val unavailable = TextView(this).apply {
                text = "This video provides no additional resolution variants."
                textSize = 13f
                setTextColor(0xFFAAAAAA.toInt())
                setPadding(dp(12), dp(8), dp(12), dp(12))
            }
            box.addView(unavailable)
        }

        qualities.forEach { quality ->

            val label =
                if (quality.bitrate > 0) {
                    "${quality.height}p   ${formatBitrate(quality.bitrate)}"
                } else {
                    "${quality.height}p"
                }

            val selected = userSelectedQuality &&
                qualityButton.text.toString().contains("${quality.height}p")

            val button = dialogButton(
                if (selected) "✓  $label" else label
            )

            button.setOnClickListener {
                setVideoQuality(quality)
                dialog.dismiss()
            }

            box.addView(button)
        }

        dialog.setContentView(box)
        dialog.setCanceledOnTouchOutside(true)
        dialog.show()

        dialog.window?.setBackgroundDrawableResource(
            android.R.color.transparent
        )

        val width = minOf(
            dp(360),
            (resources.displayMetrics.widthPixels * 0.88f).toInt()
        )

        dialog.window?.setLayout(
            width,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
    }

    private fun dialogButton(textValue: String): Button =
        Button(this).apply {
            text = textValue
            textSize = 15f
            setTextColor(Color.WHITE)
            gravity = Gravity.START or Gravity.CENTER_VERTICAL
            setPadding(dp(12), 0, dp(12), 0)

            background = GradientDrawable().apply {
                cornerRadius = dp(12).toFloat()
                setColor(0xFF242424.toInt())
                setStroke(dp(1), 0x18FFFFFF.toInt())
            }

            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(48)
            ).apply {
                bottomMargin = dp(7)
            }
        }

    private fun setAutoQuality() {
        val p = player ?: return

        try {
            val params =
                p.trackSelectionParameters
                    .buildUpon()
                    .clearOverridesOfType(C.TRACK_TYPE_VIDEO)
                    .clearVideoSizeConstraints()
                    .setForceHighestSupportedBitrate(false)
                    .build()

            p.trackSelectionParameters = params

            userSelectedQuality = false
            qualityButton.text = "⚙  AUTO"

            Log.d(TAG, "QUALITY = AUTO")

        } catch (e: Exception) {
            Log.e(TAG, "Auto quality failed", e)
        }
    }

    private fun setVideoQuality(q: VideoQuality) {
        val p = player ?: return

        try {
            val position = p.currentPosition
            val playing = p.isPlaying

            val override =
                TrackSelectionOverride(
                    q.group.mediaTrackGroup,
                    listOf(q.trackIndex)
                )

            val params =
                p.trackSelectionParameters
                    .buildUpon()
                    .clearOverridesOfType(C.TRACK_TYPE_VIDEO)
                    .clearVideoSizeConstraints()
                    .setForceHighestSupportedBitrate(false)
                    .addOverride(override)
                    .build()

            p.trackSelectionParameters = params

            if (position > 0) {
                p.seekTo(position)
            }

            p.playWhenReady = playing

            userSelectedQuality = true
            qualityButton.text = "⚙  ${q.height}p"

            Log.d(
                TAG,
                "QUALITY SELECTED = " +
                    "${q.width}x${q.height}, " +
                    "bitrate=${q.bitrate}, " +
                    "track=${q.trackIndex}"
            )

        } catch (e: Exception) {
            Log.e(TAG, "Manual quality failed", e)

            Toast.makeText(
                this,
                "Unable to change quality",
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    private fun updateQualityButton() {
        if (!::qualityButton.isInitialized) return

        // Always show the quality selector.
        // Some HLS streams expose their adaptive variants only after the
        // player is READY, and some streams expose only one variant.
        qualityButton.visibility = View.VISIBLE

        val qualities = getVideoQualities()

        if (!userSelectedQuality) {
            qualityButton.text = "⚙  AUTO"
        }

        Log.d(
            TAG,
            "QUALITY BUTTON VISIBLE. OPTIONS=${qualities.size}"
        )
    }

    private fun formatBitrate(bitrate: Int): String {
        if (bitrate <= 0) return ""

        return if (bitrate >= 1_000_000) {
            String.format(
                java.util.Locale.US,
                "%.1f Mbps",
                bitrate / 1_000_000.0
            )
        } else {
            "${bitrate / 1000} Kbps"
        }
    }

    private fun showLoading() {
        if (::loadingView.isInitialized) {
            loadingView.visibility = View.VISIBLE
        }

        if (::errorContainer.isInitialized) {
            errorContainer.visibility = View.GONE
        }
    }

    private fun hideLoading() {
        if (::loadingView.isInitialized) {
            loadingView.visibility = View.GONE
        }
    }

    private fun showError(message: String) {
        hideLoading()

        if (!::errorContainer.isInitialized) return

        errorContainer.visibility = View.VISIBLE
        errorText.text = message
    }

    private fun hideError() {
        if (::errorContainer.isInitialized) {
            errorContainer.visibility = View.GONE
        }
    }

    private fun getReadableError(error: PlaybackException): String {
        val cause = error.cause

        if (
            error.errorCode ==
                PlaybackException.ERROR_CODE_IO_BAD_HTTP_STATUS
        ) {
            val code =
                (
                    cause as? androidx.media3.datasource
                        .HttpDataSource.InvalidResponseCodeException
                    )?.responseCode

            if (code == 403) {
                return "Bunny Stream returned HTTP 403.\n\n" +
                    "Check Token Authentication, Allowed Referrers " +
                    "and video security settings."
            }

            return if (code != null) {
                "Server returned HTTP $code."
            } else {
                "Unable to load video."
            }
        }

        if (
            error.errorCode ==
                PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_FAILED
        ) {
            return "Network connection failed.\n\n" +
                "Please check your internet connection."
        }

        if (
            error.errorCode ==
                PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT
        ) {
            return "Connection timed out.\n\n" +
                "Please try again."
        }

        if (
            error.errorCode ==
                PlaybackException.ERROR_CODE_PARSING_CONTAINER_MALFORMED
        ) {
            return "The video format is not supported or is corrupted."
        }

        return "Unable to play this video.\n\n${error.errorCodeName}"
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)

        updateVideoLayout()
        hideSystemBars()
        updateOrientationUI(newConfig.orientation)
    }

    private fun hideSystemBars() {
        WindowCompat.setDecorFitsSystemWindows(window, false)

        WindowInsetsControllerCompat(
            window,
            window.decorView
        ).apply {
            hide(
                WindowInsetsCompat.Type.statusBars() or
                    WindowInsetsCompat.Type.navigationBars()
            )

            systemBarsBehavior =
                WindowInsetsControllerCompat
                    .BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)

        if (hasFocus) {
            hideSystemBars()
        }
    }

    override fun onPause() {
        super.onPause()

        player?.let {
            lastPosition = it.currentPosition
            wasPlaying = it.isPlaying
        }

        player?.pause()
    }

    override fun onResume() {
        super.onResume()

        hideSystemBars()

        if (player != null && wasPlaying) {
            player?.playWhenReady = true
        }
    }

    override fun onDestroy() {
        controlsHandler.removeCallbacks(controlsHideRunnable)
        controlsHandler.removeCallbacks(progressRunnable)

        lastPosition =
            if (player != null) {
                player?.currentPosition ?: lastPosition
            } else {
                lastPosition
            }

        if (::playerView.isInitialized) {
            playerView.player = null
        }

        player?.release()
        player = null

        super.onDestroy()
    }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()
}
