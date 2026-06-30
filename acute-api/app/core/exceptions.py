class MSG91UnavailableError(Exception):
    """MSG91 was unreachable (transport/connection failure)."""


class MSG91RequestError(Exception):
    """MSG91 returned type=error for send/resend (e.g. invalid template_id)."""


class OTPVerificationError(Exception):
    """MSG91 returned type=error for verify (wrong or expired OTP)."""
