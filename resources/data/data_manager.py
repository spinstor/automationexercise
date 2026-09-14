"""Test-data factory exposed to Robot Framework as a keyword library.

Centralises all RANDOMISED / UNIQUE data generation so tests are repeatable
(no hard-coded emails/passwords), isolated (each run gets fresh values) and
free of test data managed by hand.

Import from Robot (placing the file inside a resource keeps it available to
every suite that imports that resource):

    Library    ../data/data_manager.py

NOTE: when a library is imported by file path, Robot Framework requires the
library CLASS name to equal the MODULE (file) name. The class below is
therefore deliberately called `data_manager`.
"""

import random
import string
from datetime import datetime

FIRST_NAMES = [
    "Amelia", "Liam", "Olivia", "Noah", "Ava", "Ethan",
    "Isabella", "Lucas", "Mia", "Mason", "Charlotte", "Logan",
    "Sofia", "Jack", "Aria", "Oliver", "Chloe", "Elijah",
]

LAST_NAMES = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia",
    "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez",
]


class data_manager:
    """Keywords for creating unique, throw-away test data."""

    ROBOT_LIBRARY_SCOPE = "SUITE"

    def get_unique_email(self, prefix="qa.user", domain=None):
        """Returns a unique email address for the current execution.

        Example (Robot):
            ${email}=    Get Unique Email    prefix=registration
        """
        domain = domain or "example.com"
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S%f")
        return f"{prefix}.{timestamp}@{domain}"

    def get_unique_name(self):
        """Returns a random but human-readable first name."""
        return random.choice(FIRST_NAMES)

    def get_unique_full_name(self, separator=" "):
        """Returns a random first + last name for a freshly created user."""
        return random.choice(FIRST_NAMES) + separator + random.choice(LAST_NAMES)

    def get_card_number(self):
        """Returns a valid Visa test card number (as a string)."""
        return "4242424242424242"

    def get_cvc(self):
        """Returns a random 3-digit CVC code."""
        return "".join(random.choices(string.digits, k=3))

    def get_random_comment(self):
        """Returns an arbitrary order comment used on the checkout page."""
        return "Automated order comment - please ignore."