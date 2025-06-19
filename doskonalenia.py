import streamlit as st
import psycopg2
import pandas as pd
from psycopg2.extras import RealDictCursor
import time

# Database connection parameters
db_params = {
    "dbname": "zehs_db_full",
    "user": "postgres",
    "password": "NoisePattern5123",
    "host": "localhost",
    "port": "5432"
}

# Initialize session state for error messages
if 'update_errors' not in st.session_state:
    st.session_state.update_errors = []

if 'update_success' not in st.session_state:
    st.session_state.update_success = None
    
if 'update_logs' not in st.session_state:
    st.session_state.update_logs = []

# Initialize session state for data tracking
if 'edited_df_doskonalenia' not in st.session_state:
    st.session_state.edited_df_doskonalenia = None

if 'original_df_doskonalenia' not in st.session_state:
    st.session_state.original_df_doskonalenia = None

if 'previous_edited_rows_doskonalenia' not in st.session_state:
    st.session_state.previous_edited_rows_doskonalenia = {}

if 'company_names' not in st.session_state:
    st.session_state.company_names = []

if 'company_id_map' not in st.session_state:
    st.session_state.company_id_map = {}

# Function to connect to the database
def connect_to_db():
    try:
        conn = psycopg2.connect(**db_params)
        return conn
    except Exception as e:
        error_msg = f"Error connecting to database: {e}"
        st.session_state.update_errors.append(error_msg)
        st.error(error_msg)
        return None

# Function to get all company names from the database
def get_company_names():
    if st.session_state.company_names and st.session_state.company_id_map:
        return st.session_state.company_names
    
    conn = connect_to_db()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT id, nazwa FROM public.firma ORDER BY nazwa")
            results = cursor.fetchall()
            company_names = [row[1] for row in results]
            
            # Create a mapping of company name to ID
            company_id_map = {row[1]: row[0] for row in results}
            
            cursor.close()
            conn.close()
            
            st.session_state.company_names = company_names
            st.session_state.company_id_map = company_id_map
            
            return company_names
        except Exception as e:
            error_msg = f"Error fetching company names: {e}"
            st.session_state.update_errors.append(error_msg)
            st.error(error_msg)
            if conn:
                conn.close()
            return []
    return []

# Function to get column data types
def get_column_data_types():
    conn = connect_to_db()
    if conn:
        try:
            cursor = conn.cursor()
            
            # Get data types for relevant tables
            tables = ['reklamacja', 'firma', 'detal', 'opis_problemu', 'dzialanie', 'pracownik', 
                      'sprawdzanie_dzialan', 'slownik_dzial']
            
            column_data_types = {}
            
            for table in tables:
                cursor.execute(f"""
                    SELECT column_name, data_type 
                    FROM information_schema.columns 
                    WHERE table_name = '{table}' AND table_schema = 'public'
                """)
                column_data_types[table] = {row[0]: row[1] for row in cursor.fetchall()}
            
            cursor.close()
            conn.close()
            
            return column_data_types
        except Exception as e:
            error_msg = f"Error fetching column data types: {e}"
            st.session_state.update_errors.append(error_msg)
            st.error(error_msg)
            if conn:
                conn.close()
            return {}
    return {}

# Function to get doskonalenia data with related tables
def get_doskonalenia_data():
    conn = connect_to_db()
    if conn:
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # Optimized single query with LIMIT to avoid loading too much data at once
            query = """
            SELECT 
                r.id AS id__reklamacja,
                r.data_otwarcia AS data_otwarcia__reklamacja,
                r.zlecenie AS zlecenie__reklamacja,
                f.id AS id__firma,
                f.nazwa AS nazwa__firma,
                d.id AS id__detal,
                d.kod AS kod__detal,
                d.nazwa_wyrobu AS nazwa_wyrobu__detal,
                d.oznaczenie AS oznaczenie__detal,
                d.ilosc_zlecenie AS ilosc_zlecenie__detal,
                d.ilosc_niezgodna AS ilosc_niezgodna__detal,
                op.id AS id__opis_problemu,
                op.status AS status__opis_problemu,
                op.miejsce_zatrzymania AS miejsce_zatrzymania__opis_problemu,
                op.miejsce_powstania AS miejsce_powstania__opis_problemu,
                op.opis AS opis__opis_problemu,
                op.przyczyna_bezposrednia AS przyczyna_bezposrednia__opis_problemu,
                dk.id AS id__dzialanie_korekcyjne,
                dk.data_planowana AS data_planowana__dzialanie___dzialanie_korekcyjne,
                dk.opis_dzialania AS opis_dzialania__dzialanie___dzialanie_korekcyjne,
                dk.uwagi AS uwagi__dzialanie___dzialanie_korekcyjne,
                dkg.id AS id__dzialanie_korygujace,
                p1.id AS id__pracownik_1,
                p1.imie || ' ' || p1.nazwisko AS imie_nazwisko__pracownik___dzialanie_korygujace,
                dkg.data_planowana AS data_planowana__dzialanie___dzialanie_korygujace,
                dkg.uwagi AS uwagi__dzialanie___dzialanie_korygujace,
                dkg.data_rzeczywista AS data_rzeczywista__dzialanie___dzialanie_korygujace,
                zd.id AS id__zatwierdzenie_dzialan,
                p2.id AS id__pracownik_2,
                p2.imie || ' ' || p2.nazwisko AS imie_nazwisko__pracownik___zatwierdzenie_dzialan,
                zd.data AS data__sprawdzenie_dzialan___zatwierdzenie_dzialan,
                CASE WHEN zd.status = true THEN 'Zakończone' ELSE 'W trakcie' END AS status__sprawdzenie_dzialan___zatwierdzenie_dzialan,
                zd.uwagi AS uwagi__sprawdzenie_dzialan___zatwierdzenie_dzialan,
                sd.id AS id__skutecznosc_dzialan,
                p3.id AS id__pracownik_3,
                p3.imie || ' ' || p3.nazwisko AS imie_nazwisko__pracownik___skutecznosc_dzialan,
                sd.data AS data__sprawdzenie_dzialan___skutecznosc_dzialan,
                CASE WHEN sd.status = true THEN 'Zakończone' ELSE 'W trakcie' END AS status__sprawdzenie_dzialan___skutecznosc_dzialan,
                sd.uwagi AS uwagi__sprawdzenie_dzialan___skutecznosc_dzialan,
                dz.id AS id__slownik_dzial,
                dz.nazwa AS nazwa__slownik_dzial
            FROM 
                public.reklamacja r
            LEFT JOIN 
                public.firma f ON r.firma_id = f.id
            LEFT JOIN 
                public.reklamacja_detal rd ON r.id = rd.reklamacja_id
            LEFT JOIN 
                public.detal d ON rd.detal_id = d.id
            LEFT JOIN 
                public.opis_problemu_reklamacja opr ON r.id = opr.reklamacja_id
            LEFT JOIN 
                public.opis_problemu op ON opr.opis_problemu_id = op.id
            LEFT JOIN 
                public.dzialanie_opis_problemu dop_k ON op.id = dop_k.opis_problemu_id
            LEFT JOIN 
                public.dzialanie dk ON dop_k.dzialanie_id = dk.id AND dk.typ_id = 1
            LEFT JOIN 
                public.dzialanie_opis_problemu dop_kg ON op.id = dop_kg.opis_problemu_id
            LEFT JOIN 
                public.dzialanie dkg ON dop_kg.dzialanie_id = dkg.id AND dkg.typ_id = 2
            LEFT JOIN 
                public.dzialanie_pracownik dp1 ON dkg.id = dp1.dzialanie_id
            LEFT JOIN 
                public.pracownik p1 ON dp1.pracownik_id = p1.id
            LEFT JOIN 
                public.sprawdzanie_dzialan_opis_problemu sdop_z ON op.id = sdop_z.opis_problemu_id
            LEFT JOIN 
                public.sprawdzanie_dzialan zd ON sdop_z.sprawdzanie_dzialan_id = zd.id AND zd.typ_id = 1
            LEFT JOIN 
                public.sprawdzanie_dzialan_pracownik sdp2 ON zd.id = sdp2.sprawdzanie_dzialan_id
            LEFT JOIN 
                public.pracownik p2 ON sdp2.pracownik_id = p2.id
            LEFT JOIN 
                public.sprawdzanie_dzialan_opis_problemu sdop_s ON op.id = sdop_s.opis_problemu_id
            LEFT JOIN 
                public.sprawdzanie_dzialan sd ON sdop_s.sprawdzanie_dzialan_id = sd.id AND sd.typ_id = 2
            LEFT JOIN 
                public.sprawdzanie_dzialan_pracownik sdp3 ON sd.id = sdp3.sprawdzanie_dzialan_id
            LEFT JOIN 
                public.pracownik p3 ON sdp3.pracownik_id = p3.id
            LEFT JOIN 
                public.slownik_dzial dz ON COALESCE(p1.dzial_id, p2.dzial_id, p3.dzial_id) = dz.id
            WHERE 
                r.typ_id = 1
            ORDER BY r.id DESC
            """
            
            cursor.execute(query)
            data = cursor.fetchall()
            df = pd.DataFrame(data)
            cursor.close()
            conn.close()
            return df
        except Exception as e:
            error_msg = f"Error fetching data: {e}"
            st.session_state.update_errors.append(error_msg)
            st.error(error_msg)
            if conn:
                conn.close()
            return pd.DataFrame()
    return pd.DataFrame()

# Function to update a single cell in the database
def update_cell_in_database(row_idx, column_name, new_value):
    """Update a single cell in the database."""
    # Clear previous errors and success messages
    st.session_state.update_errors = []
    st.session_state.update_success = None
    st.session_state.update_logs = []
    
    if st.session_state.original_df_doskonalenia.empty:
        st.session_state.update_errors.append("No data to update.")
        return False
    
    # Connect to the database
    conn = connect_to_db()
    if not conn:
        st.session_state.update_errors.append("Failed to connect to database for update.")
        return False
    
    try:
        # Create cursor
        cursor = conn.cursor()
        
        # Get the original row data
        if row_idx not in st.session_state.original_df_doskonalenia.index:
            st.session_state.update_errors.append(f"Row index {row_idx} not found in original data.")
            return False
            
        original_row = st.session_state.original_df_doskonalenia.loc[row_idx]
        original_value = original_row[column_name]
        
        # Simple string comparison to detect any changes
        if str(new_value) == str(original_value):
            # No change detected
            return False
        
        # Parse the column name to get table and field
        if "__" not in column_name:
            st.session_state.update_errors.append(f"Invalid column format: {column_name}")
            return False
            
        field_name, table_name = column_name.split("__")
        
        # Handle special case for nested table names (e.g., dzialanie___dzialanie_korekcyjne)
        if "___" in table_name:
            parts = table_name.split("___")
            table_name = parts[-1]  # Use the last part as the actual table name
            # Map the special table names to actual table names
            if table_name == "dzialanie_korekcyjne" or table_name == "dzialanie_korygujace":
                table_name = "dzialanie"
            elif table_name == "zatwierdzenie_dzialan" or table_name == "skutecznosc_dzialan":
                table_name = "sprawdzanie_dzialan"
        
        # Special case for company name changes
        if column_name == "nazwa__firma":
            # Get the reklamacja ID
            reklamacja_id = int(original_row["id__reklamacja"])
            
            # Get the company ID for the selected company name
            if new_value in st.session_state.company_id_map:
                new_company_id = st.session_state.company_id_map[new_value]
                
                # Update the firma_id in the reklamacja table
                sql = "UPDATE public.reklamacja SET firma_id = %s WHERE id = %s"
                cursor.execute(sql, [new_company_id, reklamacja_id])
                
                # Log the update
                log_entry = {
                    "table": "reklamacja",
                    "id": reklamacja_id,
                    "changes": [{
                        "field": "firma_id",
                        "value": new_company_id,
                        "original": original_row["id__firma"]
                    }],
                    "success": True
                }
                st.session_state.update_logs.append(log_entry)
                
                # Commit the change
                conn.commit()
                
                # Set success message
                st.session_state.update_success = f"Updated reklamacja.firma_id to {new_company_id}"
                
                # Update the original dataframe with the new value
                st.session_state.original_df_doskonalenia.at[row_idx, column_name] = new_value
                st.session_state.original_df_doskonalenia.at[row_idx, "id__firma"] = new_company_id
                
                cursor.close()
                conn.close()
                return True
            else:
                st.session_state.update_errors.append(f"Company name '{new_value}' not found in database.")
                cursor.close()
                conn.close()
                return False
        
        # Handle special cases for column names that differ between display and database
        if field_name == "data_produkcji" and table_name == "reklamacja":
            field_name = "data_produkcji_silownika"
        
        # Handle status fields for sprawdzanie_dzialan
        if field_name == "status" and table_name == "sprawdzanie_dzialan":
            # Convert text status back to boolean
            if new_value == "Zakończone":
                new_value = True
            elif new_value == "W trakcie":
                new_value = False
        
        # Get the record ID
        id_col = f"id__{table_name}"
        
        # Handle special case for dzialanie table with different types
        if table_name == "dzialanie":
            if "dzialanie_korekcyjne" in column_name:
                id_col = "id__dzialanie_korekcyjne"
            elif "dzialanie_korygujace" in column_name:
                id_col = "id__dzialanie_korygujace"
        
        # Handle special case for sprawdzanie_dzialan table with different types
        if table_name == "sprawdzanie_dzialan":
            if "zatwierdzenie_dzialan" in column_name:
                id_col = "id__zatwierdzenie_dzialan"
            elif "skutecznosc_dzialan" in column_name:
                id_col = "id__skutecznosc_dzialan"
        
        # Handle special case for pracownik tables with multiple instances
        if table_name == "pracownik":
            if "dzialanie_korygujace" in column_name:
                id_col = "id__pracownik_1"
            elif "zatwierdzenie_dzialan" in column_name:
                id_col = "id__pracownik_2"
            elif "skutecznosc_dzialan" in column_name:
                id_col = "id__pracownik_3"
        
        if id_col not in original_row or pd.isna(original_row[id_col]):
            st.session_state.update_errors.append(f"No ID found for {table_name} (column: {id_col})")
            return False
            
        record_id = int(original_row[id_col])
        
        # Handle special value types
        if pd.isna(new_value):
            param_value = None
        elif isinstance(new_value, pd.Timestamp):
            param_value = new_value.date()
        else:
            param_value = new_value
        
        # Create and execute SQL statement
        sql = f"UPDATE public.{table_name} SET {field_name} = %s WHERE id = %s"
        
        try:
            # Execute the update
            cursor.execute(sql, [param_value, record_id])
            
            # Log the update
            log_entry = {
                "table": table_name,
                "id": record_id,
                "changes": [{
                    "field": field_name,
                    "value": new_value,
                    "original": original_value
                }],
                "success": True
            }
            st.session_state.update_logs.append(log_entry)
            
            # Commit the change
            conn.commit()
            
            # Set success message
            st.session_state.update_success = f"Updated {table_name}.{field_name}"
            
            # Update the original dataframe with the new value
            st.session_state.original_df_doskonalenia.at[row_idx, column_name] = new_value
            
            return True
            
        except Exception as e:
            # Log the error
            error_msg = f"Error updating {table_name} (ID: {record_id}): {e}"
            st.session_state.update_errors.append(error_msg)
            
            log_entry = {
                "table": table_name,
                "id": record_id,
                "changes": [{
                    "field": field_name,
                    "value": new_value,
                    "original": original_value
                }],
                "success": False,
                "error": str(e)
            }
            st.session_state.update_logs.append(log_entry)
            
            # Rollback on error
            conn.rollback()
            return False
            
    except Exception as e:
        # Handle any unexpected errors
        if conn:
            conn.rollback()
        error_msg = f"Error updating database: {e}"
        st.session_state.update_errors.append(error_msg)
        return False
    finally:
        # Always close cursor and connection
        if 'cursor' in locals() and cursor:
            cursor.close()
        if conn:
            conn.close()

# Main app
def main():
    st.title("Doskonalenia")
    
    # Get data
    if 'original_df_doskonalenia' not in st.session_state or st.session_state.original_df_doskonalenia is None:
        with st.spinner("Ładowanie danych..."):
            st.session_state.original_df_doskonalenia = get_doskonalenia_data()
    
    # Make a copy for editing
    if 'edited_df_doskonalenia' not in st.session_state or st.session_state.edited_df_doskonalenia is None:
        st.session_state.edited_df_doskonalenia = st.session_state.original_df_doskonalenia.copy()
    
    # Get column data types (cache in session state)
    if 'column_data_types_doskonalenia' not in st.session_state:
        with st.spinner("Ładowanie typów kolumn..."):
            st.session_state.column_data_types_doskonalenia = get_column_data_types()
    column_data_types = st.session_state.column_data_types_doskonalenia
    
    # Get company names for dropdown (cache in session state)
    if 'company_names_doskonalenia' not in st.session_state:
        with st.spinner("Ładowanie firm..."):
            st.session_state.company_names_doskonalenia = get_company_names()
    company_names = st.session_state.company_names_doskonalenia
    
    if 'original_df_doskonalenia' in st.session_state and not st.session_state.original_df_doskonalenia.empty:
        # Define column configurations with enhanced headers
        column_config = {}
        
        # Column name mapping for display
        column_display_names = {
            "data_otwarcia__reklamacja": {"table": "reklamacja", "column": "data_otwarcia"},
            "nazwa__firma": {"table": "firma", "column": "nazwa"},
            "kod__detal": {"table": "detal", "column": "kod"},
            "zlecenie__reklamacja": {"table": "reklamacja", "column": "zlecenie"},
            "nazwa_wyrobu__detal": {"table": "detal", "column": "nazwa_wyrobu"},
            "oznaczenie__detal": {"table": "detal", "column": "oznaczenie"},
            "ilosc_zlecenie__detal": {"table": "detal", "column": "ilosc_zlecenie"},
            "ilosc_niezgodna__detal": {"table": "detal", "column": "ilosc_niezgodna"},
            "status__opis_problemu": {"table": "opis_problemu", "column": "status"},
            "miejsce_zatrzymania__opis_problemu": {"table": "opis_problemu", "column": "miejsce_zatrzymania"},
            "miejsce_powstania__opis_problemu": {"table": "opis_problemu", "column": "miejsce_powstania"},
            "opis__opis_problemu": {"table": "opis_problemu", "column": "opis"},
            "przyczyna_bezposrednia__opis_problemu": {"table": "opis_problemu", "column": "przyczyna_bezposrednia"},
            "data_planowana__dzialanie___dzialanie_korekcyjne": {"table": "dzialanie", "column": "data_planowana"},
            "opis_dzialania__dzialanie___dzialanie_korekcyjne": {"table": "dzialanie", "column": "opis_dzialania"},
            "uwagi__dzialanie___dzialanie_korekcyjne": {"table": "dzialanie", "column": "uwagi"},
            "imie_nazwisko__pracownik___dzialanie_korygujace": {"table": "pracownik", "column": "imie_nazwisko"},
            "data_planowana__dzialanie___dzialanie_korygujace": {"table": "dzialanie", "column": "data_planowana"},
            "uwagi__dzialanie___dzialanie_korygujace": {"table": "dzialanie", "column": "uwagi"},
            "data_rzeczywista__dzialanie___dzialanie_korygujace": {"table": "dzialanie", "column": "data_rzeczywista"},
            "imie_nazwisko__pracownik___zatwierdzenie_dzialan": {"table": "pracownik", "column": "imie_nazwisko"},
            "data__sprawdzenie_dzialan___zatwierdzenie_dzialan": {"table": "sprawdzanie_dzialan", "column": "data"},
            "status__sprawdzenie_dzialan___zatwierdzenie_dzialan": {"table": "sprawdzanie_dzialan", "column": "status"},
            "uwagi__sprawdzenie_dzialan___zatwierdzenie_dzialan": {"table": "sprawdzanie_dzialan", "column": "uwagi"},
            "imie_nazwisko__pracownik___skutecznosc_dzialan": {"table": "pracownik", "column": "imie_nazwisko"},
            "data__sprawdzenie_dzialan___skutecznosc_dzialan": {"table": "sprawdzanie_dzialan", "column": "data"},
            "status__sprawdzenie_dzialan___skutecznosc_dzialan": {"table": "sprawdzanie_dzialan", "column": "status"},
            "uwagi__sprawdzenie_dzialan___skutecznosc_dzialan": {"table": "sprawdzanie_dzialan", "column": "uwagi"},
            "nazwa__slownik_dzial": {"table": "slownik_dzial", "column": "nazwa"}
        }
        
        # Create column config with enhanced headers
        for col_name in st.session_state.original_df_doskonalenia.columns:
            if col_name in column_display_names:
                table_name = column_display_names[col_name]["table"]
                column_name = column_display_names[col_name]["column"]
                
                # Get data type if available
                data_type = "unknown"
                if table_name in column_data_types and column_name in column_data_types[table_name]:
                    data_type = column_data_types[table_name][column_name]
                
                # Create header with table, column name and data type
                header = f"{table_name}.{column_name} ({data_type})"
                
                # Determine the column type based on data
                if col_name == "nazwa__firma":
                    column_config[col_name] = st.column_config.SelectboxColumn(
                        header,
                        options=company_names
                    )
                elif "data" in col_name or "data_" in col_name:
                    column_config[col_name] = st.column_config.DateColumn(header)
                elif "ilosc" in col_name:
                    column_config[col_name] = st.column_config.NumberColumn(header)
                elif "status" in col_name:
                    column_config[col_name] = st.column_config.SelectboxColumn(
                        header,
                        options=["Otwarte", "W trakcie", "Zakończone"]
                    )
                else:
                    column_config[col_name] = st.column_config.Column(header)
        
        # Display data editor with the specified column order
        column_order = [
            'data_otwarcia__reklamacja', 'nazwa__firma', 'kod__detal', 'zlecenie__reklamacja',
            'nazwa_wyrobu__detal', 'oznaczenie__detal', 'ilosc_zlecenie__detal', 'ilosc_niezgodna__detal',
            'status__opis_problemu', 'miejsce_zatrzymania__opis_problemu', 'miejsce_powstania__opis_problemu',
            'opis__opis_problemu', 'przyczyna_bezposrednia__opis_problemu',
            'data_planowana__dzialanie___dzialanie_korekcyjne', 'opis_dzialania__dzialanie___dzialanie_korekcyjne',
            'uwagi__dzialanie___dzialanie_korekcyjne', 'imie_nazwisko__pracownik___dzialanie_korygujace',
            'data_planowana__dzialanie___dzialanie_korygujace', 'uwagi__dzialanie___dzialanie_korygujace',
            'data_rzeczywista__dzialanie___dzialanie_korygujace', 'imie_nazwisko__pracownik___zatwierdzenie_dzialan',
            'data__sprawdzenie_dzialan___zatwierdzenie_dzialan', 'status__sprawdzenie_dzialan___zatwierdzenie_dzialan',
            'uwagi__sprawdzenie_dzialan___zatwierdzenie_dzialan', 'imie_nazwisko__pracownik___skutecznosc_dzialan',
            'data__sprawdzenie_dzialan___skutecznosc_dzialan', 'status__sprawdzenie_dzialan___skutecznosc_dzialan',
            'uwagi__sprawdzenie_dzialan___skutecznosc_dzialan', 'nazwa__slownik_dzial'
        ]
        
        # Filter column_order to only include columns that exist in the dataframe
        visible_columns = [col for col in column_order if col in st.session_state.original_df_doskonalenia.columns]
        
        # Hide ID columns from display but keep them for updates
        id_columns = [col for col in st.session_state.original_df_doskonalenia.columns if col.startswith("id__")]
        
        # Add a container for the data editor
        with st.container():
            # Make the data editor editable
            edited_df = st.data_editor(
                st.session_state.edited_df_doskonalenia[visible_columns],
                column_config=column_config,
                hide_index=True,
                key="data_editor_doskonalenia",
                use_container_width=True,
                num_rows="fixed"
            )
            
            # Check for changes and update database
            if "edited_rows" in st.session_state.data_editor_doskonalenia:
                current_edited_rows = st.session_state.data_editor_doskonalenia["edited_rows"]
                
                # Find new edits by comparing with previous edited rows
                for idx, changed_values in current_edited_rows.items():
                    row_idx = int(idx)
                    
                    # Check if this row was previously edited
                    if idx in st.session_state.previous_edited_rows_doskonalenia:
                        prev_changes = st.session_state.previous_edited_rows_doskonalenia[idx]
                        
                        # Find new changes in this row
                        for col_name, new_value in changed_values.items():
                            if col_name not in prev_changes or prev_changes[col_name] != new_value:
                                # This is a new change, update the database
                                update_cell_in_database(row_idx, col_name, new_value)
                    else:
                        # This entire row is newly edited
                        for col_name, new_value in changed_values.items():
                            update_cell_in_database(row_idx, col_name, new_value)
                
                # Save current edited rows for next comparison
                st.session_state.previous_edited_rows_doskonalenia = current_edited_rows.copy()
        
        # Display update information below the table
        st.write("---")
        st.write("### Status aktualizacji")
        
        # Display any errors
        for error in st.session_state.update_errors:
            st.error(error)
        
        # Display success message if any
        if st.session_state.update_success:
            st.success(st.session_state.update_success)
            
            # Show detailed logs in an expander if we have logs
            if st.session_state.update_logs:
                with st.expander("Szczegóły aktualizacji"):
                    for log in st.session_state.update_logs:
                        if log["success"]:
                            st.write(f"✅ Zaktualizowano {log['table']} (ID: {log['id']})")
                            for change in log["changes"]:
                                st.write(f"  - {change['field']}: '{change['original']}' → '{change['value']}'")
                        else:
                            st.error(f"❌ Nie udało się zaktualizować {log['table']} (ID: {log['id']})")
                            st.write(f"  - Błąd: {log['error']}")
            
        # Add a refresh button
        if st.button("Odśwież dane", key="refresh_doskonalenia"):
            # Clear cached data
            if 'column_data_types_doskonalenia' in st.session_state:
                del st.session_state.column_data_types_doskonalenia
            if 'company_names_doskonalenia' in st.session_state:
                del st.session_state.company_names_doskonalenia
            
            st.session_state.original_df_doskonalenia = get_doskonalenia_data()
            st.session_state.edited_df_doskonalenia = st.session_state.original_df_doskonalenia.copy()
            st.session_state.update_errors = []
            st.session_state.update_success = "Dane odświeżone"
            st.session_state.update_logs = []
            st.session_state.previous_edited_rows_doskonalenia = {}
            st.rerun()
    else:
        st.warning("Brak danych do wyświetlenia.") 