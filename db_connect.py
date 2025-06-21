import psycopg2
from psycopg2.extras import RealDictCursor
import streamlit as st
import pandas as pd
import numpy as np
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database connection parameters
DB_PARAMS = {
    "host": os.getenv("DB_HOST", "localhost"),
    "database": os.getenv("DB_NAME", "zehs_db_full"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD"),
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

# Database update function
def update_database_cell(table_name, field_name, record_id, new_value):
    """Generic function to update a single cell in the database"""
    conn = get_db_connection()
    if not conn:
        return False, "Failed to connect to database"
    
    try:
        with conn.cursor() as cursor:
            # Handle special value types and convert numpy types to Python native types
            if pd.isna(new_value) or new_value == '' or new_value is None:
                param_value = None
            elif hasattr(new_value, 'date'):  # pandas Timestamp
                param_value = new_value.date()
            elif isinstance(new_value, (np.integer, np.floating, np.bool_)):  # numpy scalar types
                param_value = new_value.item()  # Convert to Python native type
            elif hasattr(new_value, 'item') and hasattr(new_value, 'dtype'):  # other numpy types
                param_value = new_value.item()
            else:
                param_value = new_value
            
            # Also convert record_id if it's a numpy type
            if isinstance(record_id, (np.integer, np.floating)):
                record_id = record_id.item()
            elif hasattr(record_id, 'item') and hasattr(record_id, 'dtype'):
                record_id = record_id.item()
            
            # Create and execute SQL statement
            sql = f"UPDATE public.{table_name} SET {field_name} = %s WHERE id = %s"
            cursor.execute(sql, [param_value, record_id])
            conn.commit()
            
            return True, f"Successfully updated {table_name}.{field_name}"
            
    except Exception as e:
        conn.rollback()
        return False, f"Error updating {table_name}.{field_name}: {str(e)}"
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