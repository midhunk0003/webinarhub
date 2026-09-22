package com.webinarhub.lms

import android.app.Activity
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity

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

    private var meetingNumber = ""
    private var meetingPassword = ""
    private var userName = ""
    private var meetingSdkJwt = ""

    private var meetingService: MeetingService? = null

    /**
     * Prevent multiple finish calls.
     */
    private var isReturning = false

    /**
     * Indicates that Zoom join was successfully requested.
     */
    private var meetingStarted = false

    /**
     * Used to distinguish the first onResume()
     * from returning from Zoom's internal Activity.
     */
    private var firstResume = true

    override fun onCreate(
        savedInstanceState: Bundle?
    ) {
        super.onCreate(savedInstanceState)

        Log.d(
            TAG,
            "================================"
        )

        Log.d(
            TAG,
            "ZoomActivity STARTED"
        )

        Log.d(
            TAG,
            "================================"
        )

        // =====================================================
        // GET INTENT DATA
        // =====================================================

        meetingNumber =
            intent.getStringExtra(
                EXTRA_MEETING_NUMBER
            )?.trim() ?: ""

        meetingPassword =
            intent.getStringExtra(
                EXTRA_MEETING_PASSWORD
            ) ?: ""

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
            )?.trim() ?: ""

        // =====================================================
        // VALIDATION
        // =====================================================

        if (meetingNumber.isBlank()) {

            Log.e(
                TAG,
                "Meeting number missing"
            )

            returnToFlutter(false)

            return
        }

        if (meetingSdkJwt.isBlank()) {

            Log.e(
                TAG,
                "JWT missing"
            )

            returnToFlutter(false)

            return
        }

        initializeZoom()
    }

    // =========================================================
    // ZOOM INITIALIZATION
    // =========================================================

    private fun initializeZoom() {

        if (isReturning) {
            return
        }

        try {

            val zoomSDK =
                ZoomSDK.getInstance()

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
                "Initializing Zoom SDK"
            )

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

            returnToFlutter(false)
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
            "Zoom init result: error=$errorCode internal=$internalErrorCode"
        )

        if (errorCode == 0) {

            Log.d(
                TAG,
                "Zoom SDK initialized"
            )

            joinMeeting()

        } else {

            Log.e(
                TAG,
                "Zoom SDK initialization failed"
            )

            returnToFlutter(false)
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

        returnToFlutter(false)
    }

    // =========================================================
    // JOIN
    // =========================================================

    private fun joinMeeting() {

        if (isReturning) {
            return
        }

        try {

            val zoomSDK =
                ZoomSDK.getInstance()

            meetingService =
                zoomSDK.meetingService

            if (meetingService == null) {

                Log.e(
                    TAG,
                    "MeetingService is NULL"
                )

                returnToFlutter(false)

                return
            }

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
                "================================"
            )

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

            if (result == 0) {

                meetingStarted = true

                Log.d(
                    TAG,
                    "Zoom meeting launch successful"
                )

            } else {

                Log.e(
                    TAG,
                    "Zoom join failed: $result"
                )

                returnToFlutter(false)
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "Zoom join exception",
                e
            )

            returnToFlutter(false)
        }
    }

    // =========================================================
    // IMPORTANT FALLBACK
    // =========================================================

    override fun onResume() {

        super.onResume()

        Log.d(
            TAG,
            "ZoomActivity onResume"
        )

        /**
         * First onResume() happens when ZoomActivity itself
         * is initially displayed.
         *
         * We don't want to finish there.
         */
        if (firstResume) {

            firstResume = false

            return
        }

        /**
         * After Zoom's internal Activity closes,
         * this Activity can receive onResume().
         *
         * If we already started a meeting, return to Flutter.
         */
        if (
            meetingStarted &&
            !isReturning
        ) {

            Log.d(
                TAG,
                "Returned from Zoom UI"
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

        isReturning = true

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

        meetingService = null

        // =====================================================
        // SEND RESULT TO MAIN ACTIVITY
        // =====================================================

        setResult(
            if (success) {
                Activity.RESULT_OK
            } else {
                Activity.RESULT_CANCELED
            }
        )

        // =====================================================
        // FINISH ONLY THIS ACTIVITY
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

        returnToFlutter(true)
    }

    // =========================================================
    // DESTROY
    // =========================================================

    override fun onDestroy() {

        Log.d(
            TAG,
            "ZoomActivity DESTROYED"
        )

        meetingService = null

        super.onDestroy()
    }
}