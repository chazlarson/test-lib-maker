"""
Custom exception classes for the test library maker.

Defines specific exceptions for various error conditions encountered during
media file creation and processing.
"""


class ComponentNotFoundException(Exception):
    pass

class DuplicateTargetException(Exception):
    pass

class InvalidLanguageException(Exception):
    pass

class Failed(Exception):
    pass
