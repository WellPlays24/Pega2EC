class AppError(Exception):
    """Base application error."""


class ConflictError(AppError):
    """Raised when a unique or business conflict occurs."""


class NotFoundError(AppError):
    """Raised when a requested resource does not exist."""


class IntegrationError(AppError):
    """Raised when an upstream integration fails."""
