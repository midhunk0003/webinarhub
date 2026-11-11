
import Foundation
import Flutter
import MobileRTC

final class ZoomMeetingManager: NSObject {

    static let shared = ZoomMeetingManager()

    private override init() {
        super.init()
    }

    private var isSDKInitialized = false
    private var isAuthorized = false

    private var pendingMeeting: (
        meetingNumber: String,
        meetingPassword: String,
        userName: String,
        jwt: String
    )?

    private var pendingResult: FlutterResult?

    // MARK: - Join Meeting

    func joinMeeting(
        arguments: [String: Any],
        result: @escaping FlutterResult
    ) {

        let meetingNumber =
            arguments["meetingNumber"] as? String ?? ""

        let meetingPassword =
            arguments["meetingPassword"] as? String ?? ""

        let userName =
            arguments["userName"] as? String ?? ""

        let jwt =
            arguments["jwt"] as? String ?? ""

        if let error = validateInput(
            meetingNumber: meetingNumber,
            meetingPassword: meetingPassword,
            userName: userName,
            jwt: jwt
        ) {
            result(
                FlutterError(
                    code: "INVALID_MEETING_DATA",
                    message: error,
                    details: nil
                )
            )
            return
        }

        guard pendingResult == nil else {
            result(
                FlutterError(
                    code: "MEETING_IN_PROGRESS",
                    message: "A Zoom join request is already running.",
                    details: nil
                )
            )
            return
        }

        pendingMeeting = (
            meetingNumber,
            meetingPassword,
            userName,
            jwt
        )

        pendingResult = result

        initializeZoom(jwt: jwt)
    }

    // MARK: - Validation

    private func validateInput(
        meetingNumber: String,
        meetingPassword: String,
        userName: String,
        jwt: String
    ) -> String? {

        if meetingNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Meeting ID is missing."
        }

        if meetingPassword.isEmpty {
            return "Meeting password is missing."
        }

        if userName.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Username is missing."
        }

        if jwt.isEmpty {
            return "Authentication token is missing."
        }

        return nil
    }

    // MARK: - Initialize Zoom

    private func initializeZoom(jwt: String) {

        let sdk = MobileRTC.shared()

        if !isSDKInitialized {

            let context = MobileRTCSDKInitContext()
            context.domain = "https://zoom.us"
            context.enableLog = true

            let initialized = sdk.initialize(context)

            guard initialized else {
                finishWithError(
                    code: "ZOOM_INITIALIZATION_FAILED",
                    message: "Could not initialize Zoom SDK."
                )
                return
            }

            isSDKInitialized = true
        }

        guard let authService = sdk.getAuthService() else {
            finishWithError(
                code: "ZOOM_AUTH_SERVICE_ERROR",
                message: "Zoom authentication service unavailable."
            )
            return
        }

        if isAuthorized {
            joinMeetingNative()
            return
        }

        authService.delegate = self
        authService.jwtToken = jwt
        authService.sdkAuth()
    }

    // MARK: - Join Native Meeting

    private func joinMeetingNative() {

        guard let meeting = pendingMeeting else {
            finishWithError(
                code: "MEETING_DATA_ERROR",
                message: "Meeting details are unavailable."
            )
            return
        }

        guard let meetingService =
            MobileRTC.shared().getMeetingService() else {

            finishWithError(
                code: "MEETING_SERVICE_ERROR",
                message: "Zoom meeting service unavailable."
            )
            return
        }

        meetingService.delegate = self

        let params = MobileRTCMeetingJoinParam()

        params.meetingNumber = meeting.meetingNumber
        params.password = meeting.meetingPassword
        params.userName = meeting.userName

        let joinError = meetingService.joinMeeting(with: params)

        if joinError == .success {
            // The join request was accepted by the SDK.
            // This does not guarantee that the participant is connected.
            finishWithSuccess()
        } else {
            finishWithError(
                code: "ZOOM_JOIN_FAILED",
                message: "Zoom rejected the join request: \(joinError)"
            )
        }
    }

    // MARK: - Result Handling

    private func finishWithSuccess() {
        DispatchQueue.main.async {
            self.pendingResult?(true)
            self.clearPendingRequest()
        }
    }

    private func finishWithError(
        code: String,
        message: String
    ) {
        DispatchQueue.main.async {
            self.pendingResult?(
                FlutterError(
                    code: code,
                    message: message,
                    details: nil
                )
            )
            self.clearPendingRequest()
        }
    }

    private func clearPendingRequest() {
        pendingResult = nil
        pendingMeeting = nil
    }
}

// MARK: - Zoom Authentication Delegate

extension ZoomMeetingManager: MobileRTCAuthDelegate {

    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {

        switch returnValue {

        case .success:
            isAuthorized = true
            joinMeetingNative()

        default:
            finishWithError(
                code: "ZOOM_AUTH_FAILED",
                message: "Zoom authentication failed: \(returnValue)"
            )
        }
    }
}

// MARK: - Zoom Meeting Delegate

extension ZoomMeetingManager: MobileRTCMeetingServiceDelegate {

    func onMeetingError(
        _ error: MobileRTCMeetError,
        message: String?
    ) {
        print(
            "Zoom meeting error: \(error), \(message ?? "")"
        )
    }

    func onJoinMeetingConfirmed() {
        print("Zoom meeting joined successfully.")
    }

    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        print("Zoom meeting state: \(state)")
    }
}
