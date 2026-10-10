package com.wwitplwebinarhub.lms

import android.app.Activity
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Base64
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import org.json.JSONObject
import us.zoom.sdk.JoinMeetingOptions
import us.zoom.sdk.JoinMeetingParams
import us.zoom.sdk.MeetingService
import us.zoom.sdk.ZoomSDK
import us.zoom.sdk.ZoomSDKInitParams
import us.zoom.sdk.ZoomSDKInitializeListener


class ZoomActivity : AppCompatActivity(),
    ZoomSDKInitializeListener {

    companion object {

        private const val TAG = "ZoomActivity"

        private const val EXTRA_MEETING_NUMBER =
            "meetingNumber"

        private const val EXTRA_MEETING_PASSWORD =
            "meetingPassword"

        private const val EXTRA_USER_NAME =
            "userName"

        private const val EXTRA_JWT =
            "jwt"
    }

    // =========================================================
    // DATA
    // =========================================================

    private var meetingNumber = ""
    private var meetingPassword = ""
    private var userName = ""
    private var meetingSdkJwt = ""

    private var meetingService: MeetingService? = null

    // =========================================================
    // STATE
    // =========================================================

    private var isReturning = false
    private var meetingStarted = false
    private var firstResume = true

    /**
     * Prevent multiple join calls.
     */
    private var joinStarted = false

    /**
     * Handler for UI updates.
     */
    private val mainHandler =
        Handler(Looper.getMainLooper())

    // =========================================================
    // UI
    // =========================================================

    private lateinit var rootLayout: FrameLayout
    private lateinit var loadingContainer: FrameLayout
    private lateinit var progressBar: ProgressBar
    private lateinit var titleText: TextView
    private lateinit var statusText: TextView


    // =========================================================
    // ACTIVITY CREATED
    // =========================================================

    override fun onCreate(
        savedInstanceState: Bundle?
    ) {

        super.onCreate(savedInstanceState)

        Log.d(TAG, "================================")
        Log.d(TAG, "ZoomActivity STARTED")
        Log.d(TAG, "================================")

        // =====================================================
        // SHOW LOADING SCREEN FIRST
        // =====================================================

        setupLoadingScreen()

        // =====================================================
        // GET INTENT DATA
        // =====================================================

        meetingNumber =
            intent.getStringExtra(
                EXTRA_MEETING_NUMBER
            )
                ?.trim()
                ?: ""

        meetingPassword =
            intent.getStringExtra(
                EXTRA_MEETING_PASSWORD
            )
                ?.trim()
                ?: ""

        userName =
            intent.getStringExtra(
                EXTRA_USER_NAME
            )
                ?.trim()
                .takeUnless {
                    it.isNullOrEmpty()
                }
                ?: "LMS User"

        meetingSdkJwt =
            intent.getStringExtra(
                EXTRA_JWT
            )
                ?.trim()
                ?: ""

        // =====================================================
        // SAFE LOGGING
        // =====================================================

        Log.d(
            TAG,
            "Meeting Number = $meetingNumber"
        )

        Log.d(
            TAG,
            "Password Present = ${meetingPassword.isNotEmpty()}"
        )

        Log.d(
            TAG,
            "User = $userName"
        )

        Log.d(
            TAG,
            "JWT Present = ${meetingSdkJwt.isNotEmpty()}"
        )

        Log.d(
            TAG,
            "JWT Length = ${meetingSdkJwt.length}"
        )

        // =====================================================
        // VALIDATION
        // =====================================================

        if (meetingNumber.isBlank()) {

            showErrorAndClose(
                "Unable to join webinar.\nMeeting ID is missing."
            )

            return
        }

        if (meetingPassword.isBlank()) {

            showErrorAndClose(
                "Unable to join webinar.\nMeeting password is missing."
            )

            return
        }

        if (meetingSdkJwt.isBlank()) {

            showErrorAndClose(
                "Unable to join webinar.\nAuthentication token is missing."
            )

            return
        }

        // =====================================================
        // UPDATE LOADING UI
        // =====================================================

        updateLoading(
            "Preparing meeting...",
            "Please wait while we prepare your webinar."
        )

        // =====================================================
        // VALIDATE JWT
        // =====================================================

        if (!validateJwt()) {

            return
        }

        // =====================================================
        // INITIALIZE ZOOM
        // =====================================================

        mainHandler.postDelayed({

            if (!isReturning && !isFinishing) {

                updateLoading(
                    "Connecting to Zoom...",
                    "Securely connecting to the webinar."
                )

                initializeZoom()
            }

        }, 300)
    }


    // =========================================================
    // CREATE LOADING SCREEN
    // =========================================================

    private fun setupLoadingScreen() {

        // =====================================================
        // ROOT
        // =====================================================

        rootLayout =
            FrameLayout(this)

        rootLayout.setBackgroundColor(
            Color.rgb(12, 15, 22)
        )

        setContentView(rootLayout)

        // =====================================================
        // LOADING CONTAINER
        // =====================================================

        loadingContainer =
            FrameLayout(this)

        loadingContainer.setBackgroundColor(
            Color.rgb(12, 15, 22)
        )

        val containerParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )

        rootLayout.addView(
            loadingContainer,
            containerParams
        )

        // =====================================================
        // CENTER CONTAINER
        // =====================================================

        val centerContainer =
            FrameLayout(this)

        val centerParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )

        centerParams.gravity =
            Gravity.CENTER

        centerParams.leftMargin = dp(32)
        centerParams.rightMargin = dp(32)

        loadingContainer.addView(
            centerContainer,
            centerParams
        )

        // =====================================================
        // PROGRESS BAR
        // =====================================================

        progressBar =
            ProgressBar(
                this,
                null,
                android.R.attr.progressBarStyleLarge
            )

        progressBar.isIndeterminate = true

        val progressParams =
            FrameLayout.LayoutParams(
                dp(52),
                dp(52)
            )

        progressParams.gravity =
            Gravity.CENTER_HORIZONTAL

        centerContainer.addView(
            progressBar,
            progressParams
        )

        // =====================================================
        // TITLE
        // =====================================================

        titleText =
            TextView(this)

        titleText.text =
            "Preparing meeting..."

        titleText.setTextColor(
            Color.WHITE
        )

        titleText.textSize =
            20f

        titleText.typeface =
            Typeface.create(
                Typeface.DEFAULT,
                Typeface.BOLD
            )

        titleText.gravity =
            Gravity.CENTER

        val titleParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )

        titleParams.gravity =
            Gravity.TOP

        titleParams.topMargin =
            dp(72)

        centerContainer.addView(
            titleText,
            titleParams
        )

        // =====================================================
        // STATUS
        // =====================================================

        statusText =
            TextView(this)

        statusText.text =
            "Please wait while we prepare your webinar."

        statusText.setTextColor(
            Color.rgb(170, 175, 185)
        )

        statusText.textSize =
            14f

        statusText.gravity =
            Gravity.CENTER

        val statusParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )

        statusParams.gravity =
            Gravity.TOP

        statusParams.topMargin =
            dp(112)

        centerContainer.addView(
            statusText,
            statusParams
        )

        // =====================================================
        // SMALL SECURITY TEXT
        // =====================================================

        val securityText =
            TextView(this)

        securityText.text =
            "Connecting securely"

        securityText.setTextColor(
            Color.rgb(120, 125, 135)
        )

        securityText.textSize =
            12f

        securityText.gravity =
            Gravity.CENTER

        val securityParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )

        securityParams.gravity =
            Gravity.TOP

        securityParams.topMargin =
            dp(148)

        centerContainer.addView(
            securityText,
            securityParams
        )
    }


    // =========================================================
    // UPDATE LOADING
    // =========================================================

    private fun updateLoading(
        title: String,
        status: String
    ) {

        mainHandler.post {

            if (
                isFinishing ||
                isDestroyed
            ) {
                return@post
            }

            titleText.text =
                title

            statusText.text =
                status
        }
    }


    // =========================================================
    // HIDE LOADING
    // =========================================================

    private fun hideLoading() {

        mainHandler.post {

            if (
                isFinishing ||
                isDestroyed
            ) {
                return@post
            }

            loadingContainer.visibility =
                View.GONE
        }
    }


    // =========================================================
    // SHOW ERROR
    // =========================================================

    private fun showError(
        message: String
    ) {

        mainHandler.post {

            if (
                !isFinishing &&
                !isDestroyed
            ) {

                Toast.makeText(
                    this@ZoomActivity,
                    message,
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }


    // =========================================================
    // SHOW SUCCESS
    // =========================================================

    private fun showSuccess(
        message: String
    ) {

        mainHandler.post {

            if (
                !isFinishing &&
                !isDestroyed
            ) {

                Toast.makeText(
                    this@ZoomActivity,
                    message,
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    }


    // =========================================================
    // ERROR + CLOSE
    // =========================================================

    private fun showErrorAndClose(
        message: String
    ) {

        showError(message)

        mainHandler.postDelayed({

            returnToFlutter(false)

        }, 800)
    }


    // =========================================================
    // JWT VALIDATION
    // =========================================================

    private fun validateJwt(): Boolean {

        try {

            // =================================================
            // BASIC CHECK
            // =================================================

            if (meetingSdkJwt.isBlank()) {

                showErrorAndClose(
                    "Unable to join webinar.\nAuthentication token is missing."
                )

                return false
            }

            // =================================================
            // JWT MUST HAVE 3 PARTS
            // =================================================

            val parts =
                meetingSdkJwt.split(".")

            if (parts.size != 3) {

                Log.e(
                    TAG,
                    "Invalid JWT format"
                )

                showErrorAndClose(
                    "Unable to join webinar.\nInvalid authentication token."
                )

                return false
            }

            // =================================================
            // DECODE PAYLOAD
            // =================================================

            val payloadBytes =
                Base64.decode(
                    parts[1],
                    Base64.URL_SAFE or
                            Base64.NO_PADDING or
                            Base64.NO_WRAP
                )

            val payload =
                String(
                    payloadBytes,
                    Charsets.UTF_8
                )

            val json =
                JSONObject(payload)

            // =================================================
            // EXPIRATION
            // =================================================

            val exp =
                json.optLong(
                    "exp",
                    0L
                )

            if (exp <= 0L) {

                Log.e(
                    TAG,
                    "JWT expiration missing"
                )

                showErrorAndClose(
                    "Unable to join webinar.\nInvalid authentication token."
                )

                return false
            }

            // =================================================
            // CURRENT TIME
            // =================================================

            val currentTime =
                System.currentTimeMillis() / 1000L

            // =================================================
            // EXPIRATION CHECK
            // =================================================

            if (currentTime >= exp) {

                Log.e(
                    TAG,
                    "JWT expired"
                )

                showErrorAndClose(
                    "Your Zoom session has expired.\nPlease try joining again."
                )

                return false
            }

            // =================================================
            // OPTIONAL TOKEN EXPIRATION
            // =================================================

            val tokenExp =
                json.optLong(
                    "tokenExp",
                    0L
                )

            if (
                tokenExp > 0L &&
                currentTime >= tokenExp
            ) {

                Log.e(
                    TAG,
                    "JWT tokenExp expired"
                )

                showErrorAndClose(
                    "Your Zoom session has expired.\nPlease try again."
                )

                return false
            }

            // =================================================
            // IMPORTANT
            // =================================================
            //
            // Do NOT require:
            //
            // appKey
            // mn
            //
            // because your backend-generated Meeting SDK JWT
            // may not contain those claims depending on the
            // JWT generation implementation.
            //
            // Zoom SDK itself will perform authentication.
            // =================================================

            Log.d(
                TAG,
                "JWT basic validation successful"
            )

            return true

        } catch (e: Exception) {

            Log.e(
                TAG,
                "JWT validation failed",
                e
            )

            showErrorAndClose(
                "Unable to join webinar.\nInvalid authentication token."
            )

            return false
        }
    }


    // =========================================================
    // INITIALIZE ZOOM
    // =========================================================

    private fun initializeZoom() {

        if (isReturning) {
            return
        }

        try {

            val zoomSDK =
                ZoomSDK.getInstance()

            // =================================================
            // CHECK SDK INSTANCE
            // =================================================

            if (zoomSDK == null) {

                Log.e(
                    TAG,
                    "ZoomSDK instance is NULL"
                )

                showErrorAndClose(
                    "Unable to start Zoom.\nPlease try again."
                )

                return
            }

            // =================================================
            // INIT PARAMS
            // =================================================

            val initParams =
                ZoomSDKInitParams().apply {

                    jwtToken =
                        meetingSdkJwt

                    domain =
                        "zoom.us"

                    enableLog =
                        true
                }

            Log.d(
                TAG,
                "================================"
            )

            Log.d(
                TAG,
                "Initializing Zoom SDK"
            )

            Log.d(
                TAG,
                "Meeting = $meetingNumber"
            )

            Log.d(
                TAG,
                "JWT Present = ${meetingSdkJwt.isNotEmpty()}"
            )

            Log.d(
                TAG,
                "================================"
            )

            // =================================================
            // INITIALIZE
            // =================================================

            zoomSDK.initialize(
                applicationContext,
                this,
                initParams
            )

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Zoom initialization failed",
                e
            )

            showErrorAndClose(
                "Unable to start Zoom.\nPlease try again."
            )
        }
    }


    // =========================================================
    // SDK INITIALIZATION RESULT
    // =========================================================

    override fun onZoomSDKInitializeResult(
        errorCode: Int,
        internalErrorCode: Int
    ) {

        if (isReturning) {
            return
        }

        Log.d(
            TAG,
            "================================"
        )

        Log.d(
            TAG,
            "Zoom initialization result"
        )

        Log.d(
            TAG,
            "errorCode = $errorCode"
        )

        Log.d(
            TAG,
            "internalErrorCode = $internalErrorCode"
        )

        Log.d(
            TAG,
            "================================"
        )

        // =====================================================
        // SUCCESS
        // =====================================================

        if (errorCode == 0) {

            updateLoading(
                "Joining webinar...",
                "Connecting you to the live session."
            )

            mainHandler.postDelayed({

                if (!isReturning) {

                    joinMeeting()
                }

            }, 300)

            return
        }

        // =====================================================
        // ERROR
        // =====================================================

        val message =
            getInitializationErrorMessage(
                errorCode
            )

        Log.e(
            TAG,
            "Zoom SDK initialization failed: $message"
        )

        showErrorAndClose(
            message
        )
    }


    // =========================================================
    // INITIALIZATION ERROR
    // =========================================================

    private fun getInitializationErrorMessage(
        errorCode: Int
    ): String {

        return when (errorCode) {

            1 ->
                "Unable to start Zoom.\nInvalid Zoom configuration."

            2 ->
                "Unable to start Zoom.\nPlease check your internet connection."

            3 ->
                "Zoom SDK is not available.\nPlease try again."

            4 ->
                "Zoom authentication failed.\nPlease try again."

            5 ->
                "Zoom authentication failed.\nYour session may have expired."

            else ->
                "Unable to start Zoom.\nPlease try again."
        }
    }


    // =========================================================
    // AUTH EXPIRED
    // =========================================================

    override fun onZoomAuthIdentityExpired() {

        Log.e(
            TAG,
            "Zoom authentication identity expired"
        )

        showErrorAndClose(
            "Your Zoom session has expired.\nPlease try joining again."
        )
    }


    // =========================================================
    // JOIN MEETING
    // =========================================================

    private fun joinMeeting() {

        if (isReturning) {
            return
        }

        // =====================================================
        // PREVENT DUPLICATE JOIN
        // =====================================================

        if (joinStarted) {

            Log.d(
                TAG,
                "Join already started"
            )

            return
        }

        joinStarted = true

        try {

            val zoomSDK =
                ZoomSDK.getInstance()

            // =================================================
            // MEETING SERVICE
            // =================================================

            meetingService =
                zoomSDK.meetingService

            if (meetingService == null) {

                Log.e(
                    TAG,
                    "MeetingService is NULL"
                )

                joinStarted = false

                showErrorAndClose(
                    "Unable to join webinar.\nZoom service is unavailable."
                )

                return
            }

            // =================================================
            // UPDATE UI
            // =================================================

            updateLoading(
                "Joining webinar...",
                "Please wait while Zoom opens your session."
            )

            // =================================================
            // JOIN PARAMETERS
            // =================================================

            val params =
                JoinMeetingParams().apply {

                    displayName =
                        userName

                    meetingNo =
                        meetingNumber

                    password =
                        meetingPassword
                }

            val options =
                JoinMeetingOptions()

            // =================================================
            // LOG
            // =================================================

            Log.d(
                TAG,
                "================================"
            )

            Log.d(
                TAG,
                "JOINING ZOOM"
            )

            Log.d(
                TAG,
                "Meeting = $meetingNumber"
            )

            Log.d(
                TAG,
                "User = $userName"
            )

            Log.d(
                TAG,
                "Password Present = ${meetingPassword.isNotEmpty()}"
            )

            Log.d(
                TAG,
                "================================"
            )

            // =================================================
            // JOIN
            // =================================================

            val result =
                meetingService!!.joinMeetingWithParams(
                    this,
                    params,
                    options
                )

            Log.d(
                TAG,
                "joinMeetingWithParams result = $result"
            )

            // =================================================
            // SUCCESS
            // =================================================

            if (result == 0) {

                meetingStarted =
                    true

                Log.d(
                    TAG,
                    "Zoom meeting launch successful"
                )

                // Do NOT finish this Activity here.
                //
                // Zoom opens its own Activity.
                //
                // We wait until user returns from Zoom,
                // then onResume() will call returnToFlutter(true).

            } else {

                // =================================================
                // JOIN FAILED
                // =================================================

                joinStarted =
                    false

                Log.e(
                    TAG,
                    "Zoom join failed: $result"
                )

                val message =
                    getJoinErrorMessage(
                        result
                    )

                showErrorAndClose(
                    message
                )
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Zoom join exception",
                e
            )

            joinStarted =
                false

            showErrorAndClose(
                "Unable to join webinar.\nPlease try again."
            )
        }
    }


    // =========================================================
    // JOIN ERROR MESSAGE
    // =========================================================

    private fun getJoinErrorMessage(
        errorCode: Int
    ): String {

        return when (errorCode) {

            0 ->
                "Joining Zoom..."

            1 ->
                "Unable to join webinar.\nInvalid meeting information."

            2 ->
                "Unable to join webinar.\nMeeting is not available."

            3 ->
                "Unable to join webinar.\nPlease check your internet connection."

            4 ->
                "You are not authorized to join this webinar."

            5 ->
                "Zoom authentication failed.\nPlease try again."

            else ->
                "Unable to join webinar.\nPlease try again."
        }
    }


    // =========================================================
    // ACTIVITY RESUME
    // =========================================================

    override fun onResume() {

        super.onResume()

        Log.d(
            TAG,
            "ZoomActivity onResume"
        )

        // =====================================================
        // FIRST RESUME
        // =====================================================

        if (firstResume) {

            firstResume =
                false

            return
        }

        // =====================================================
        // RETURNED FROM ZOOM
        // =====================================================

        if (
            meetingStarted &&
            !isReturning
        ) {

            Log.d(
                TAG,
                "================================"
            )

            Log.d(
                TAG,
                "Returned from Zoom UI"
            )

            Log.d(
                TAG,
                "================================"
            )

            returnToFlutter(true)
        }
    }


    // =========================================================
    // RETURN TO FLUTTER
    // =========================================================

    private fun returnToFlutter(
        success: Boolean
    ) {

        if (isReturning) {
            return
        }

        isReturning =
            true

        Log.d(
            TAG,
            "================================"
        )

        Log.d(
            TAG,
            "RETURNING TO FLUTTER"
        )

        Log.d(
            TAG,
            "success = $success"
        )

        Log.d(
            TAG,
            "================================"
        )

        // =====================================================
        // CLEANUP
        // =====================================================

        meetingService =
            null

        // =====================================================
        // CANCEL PENDING CALLBACKS
        // =====================================================

        mainHandler.removeCallbacksAndMessages(null)

        // =====================================================
        // RESULT
        // =====================================================

        setResult(
            if (success) {

                Activity.RESULT_OK

            } else {

                Activity.RESULT_CANCELED
            }
        )

        // =====================================================
        // FINISH
        // =====================================================

        if (!isFinishing) {

            finish()
        }
    }


    // =========================================================
    // ANDROID BACK
    // =========================================================

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {

        Log.d(
            TAG,
            "Android back pressed"
        )

        // =====================================================
        // If Zoom meeting is already open, normally this
        // Activity will not receive the back press.
        //
        // If this Activity itself receives back:
        // return to Flutter.
        // =====================================================

        returnToFlutter(
            meetingStarted
        )
    }


    // =========================================================
    // DESTROY
    // =========================================================

    override fun onDestroy() {

        Log.d(
            TAG,
            "================================"
        )

        Log.d(
            TAG,
            "ZoomActivity DESTROYED"
        )

        Log.d(
            TAG,
            "================================"
        )

        mainHandler.removeCallbacksAndMessages(
            null
        )

        meetingService =
            null

        super.onDestroy()
    }


    // =========================================================
    // DP HELPER
    // =========================================================

    private fun dp(
        value: Int
    ): Int {

        return (
            value *
                    resources.displayMetrics.density
            ).toInt()
    }
}