import psycopg2
from psycopg2.extras import RealDictCursor
import streamlit as st
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database connection parameters
DB_PARAMS = {
    "host": os.getenv("DB_HOST", "localhost"),
    "database": os.getenv("DB_NAME", "zehs_db_full"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", "NoisePattern5123"),
    "port": os.getenv("DB_PORT", "5432")
}

def get_db_connection():
    """Get database connection with error handling"""
    try:
        return psycopg2.connect(**DB_PARAMS)
    except Exception as e:
        st.error(f"Database connection failed: {e}")
        return None

# Dictionary data loading functions
@st.cache_data
def load_firma_names():
    """Load company names from firma table"""
    conn = get_db_connection()
    if not conn:
        return []
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT nazwa FROM firma ORDER BY nazwa")
            return [row['nazwa'] for row in cursor.fetchall()]
    except Exception as e:
        st.error(f"Error loading company names: {e}")
        return []
    finally:
        conn.close()

@st.cache_data
def load_audit_types():
    """Load audit types from slownik_typ_audytu table"""
    conn = get_db_connection()
    if not conn:
        return []
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT nazwa FROM slownik_typ_audytu ORDER BY nazwa")
            return [row['nazwa'] for row in cursor.fetchall()]
    except Exception as e:
        st.error(f"Error loading audit types: {e}")
        return []
    finally:
        conn.close()

@st.cache_data
def load_employee_names():
    """Load employee names from pracownik table"""
    conn = get_db_connection()
    if not conn:
        return []
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT CONCAT(imie, ' ', nazwisko) as imie_nazwisko FROM pracownik ORDER BY nazwisko, imie")
            return [row['imie_nazwisko'] for row in cursor.fetchall()]
    except Exception as e:
        st.error(f"Error loading employee names: {e}")
        return []
    finally:
        conn.close()

@st.cache_data
def load_department_names():
    """Load department names from slownik_dzial table"""
    conn = get_db_connection()
    if not conn:
        return []
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT nazwa FROM slownik_dzial ORDER BY nazwa")
            return [row['nazwa'] for row in cursor.fetchall()]
    except Exception as e:
        st.error(f"Error loading department names: {e}")
        return []
    finally:
        conn.close()

@st.cache_data
def load_dokument_rozliczeniowy_options():
    """Load document settlement options from enum"""
    return ['korekta', 'WZ', 'złom', 'ZW', 'ZW złom']

@st.cache_data
def load_opis_problemu_status_options():
    """Load problem status options from enum"""
    return ["w trakcie", "zakonczone"]

@st.cache_data
def load_miejsce_zatrzymania_options():
    """Load stop location options from enum"""
    return ["P", "M", "G"]

@st.cache_data
def load_miejsce_powstania_options():
    """Load origin location options from enum"""
    return ["P", "G"]

# Utility function to execute queries safely
def execute_query(query, params=None):
    """Execute a query and return results as DataFrame"""
    import pandas as pd
    
    conn = get_db_connection()
    if not conn:
        return pd.DataFrame()
    
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(query, params)
            return pd.DataFrame(cursor.fetchall())
    except Exception as e:
        st.error(f"Error executing query: {e}")
        return pd.DataFrame()
    finally:
        conn.close()

# Clear cache function for data refresh
def clear_cache():
    """Clear all cached data"""
    load_firma_names.clear()
    load_audit_types.clear()
    load_employee_names.clear()
    load_department_names.clear()
    st.success("Cache cleared successfully!") 