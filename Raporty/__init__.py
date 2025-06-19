# Raporty package
# Contains modules for different types of reports in the quality management system

__version__ = "1.0.0"
__author__ = "Quality Management System"

# Import all modules for easier access
from . import reklamacje
from . import doskonalenia
from . import raporty_8d
from . import audyty

__all__ = ["reklamacje", "doskonalenia", "raporty_8d", "audyty"] 