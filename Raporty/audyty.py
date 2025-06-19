import streamlit as st
import psycopg2
import pandas as pd
from psycopg2.extras import RealDictCursor
import time
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database connection parameters
db_params = {
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT")
}

# Initialize session state for error messages
if 'update_errors' not in st.session_state:
    st.session_state.update_errors = []

if 'update_success' not in st.session_state:
    st.session_state.update_success = None
    
if 'update_logs' not in st.session_state:
    st.session_state.update_logs = []

# Initialize session state for data tracking
if 'edited_df_audyty' not in st.session_state:
    st.session_state.edited_df_audyty = None

if 'original_df_audyty' not in st.session_state:
    st.session_state.original_df_audyty = None

if 'previous_edited_rows_audyty' not in st.session_state:
    st.session_state.previous_edited_rows_audyty = {}

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

# Function to get audyty data with related tables
def get_audyty_data():
    conn = connect_to_db()
    if conn:
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            # Query for Audyty
            query = """
            SELECT 
                a.id AS id__audyt,
                a.data AS data__audyt,
                sta.nazwa AS typ__audyt,
                a.zakres AS zakres__audyt,
                a.uwagi AS uwagi__audyt,
                op.id AS id__opis_problemu,
                op.opis AS opis__opis_problemu,
                op.przyczyna_bezposrednia AS przyczyna_bezposrednia__opis_problemu,
                a.termin_wyslania_odpowiedzi AS termin_wyslania_odpowiedzi__audyt,
                a.termin_zakonczenia_dzialan AS termin_zakonczenia_dzialan__audyt,
                dk.id AS id__dzialanie_korekcyjne,
                dk.opis_dzialania AS opis_dzialania__dzialanie___dzialanie_korekcyjne,
                p1.id AS id__pracownik_1,
                p1.imie || ' ' || p1.nazwisko AS imie_nazwisko__pracownik___dzialanie_korekcyjne,
                dk.data_planowana AS data_planowana__dzialanie___dzialanie_korekcyjne,
                dk.data_rzeczywista AS data_rzeczywista__dzialanie___dzialanie_korekcyjne,
                dkg.id AS id__dzialanie_korygujace,
                dkg.opis_dzialania AS opis_dzialania__dzialanie___dzialanie_korygujace,
                p2.id AS id__pracownik_2,
                p2.imie || ' ' || p2.nazwisko AS imie_nazwisko__pracownik___dzialanie_korygujace,
                dkg.data_planowana AS data_planowana__dzialanie___dzialanie_korygujace,
                dkg.data_rzeczywista AS data_rzeczywista__dzialanie___dzialanie_korygujace,
                zd.id AS id__zatwierdzenie_dzialan,
                p3.id AS id__pracownik_3,
                p3.imie || ' ' || p3.nazwisko AS imie_nazwisko__pracownik___zatwierdzenie_dzialan,
                zd.data AS data__sprawdzanie_dzialan___zatwierdzenie_dzialan,
                CASE WHEN zd.status = true THEN 'Zakończone' ELSE 'W trakcie' END AS status__sprawdzanie_dzialan___zatwierdzenie_dzialan,
                zd.uwagi AS uwagi__sprawdzanie_dzialan___zatwierdzenie_dzialan,
                sd.id AS id__skutecznosc_dzialan,
                p4.id AS id__pracownik_4,
                p4.imie || ' ' || p4.nazwisko AS imie_nazwisko__pracownik___sprawdzenie_dzialan,
                sd.data AS data__sprawdzanie_dzialan___skutecznosc_dzialan,
                CASE WHEN sd.status = true THEN 'Zakończone' ELSE 'W trakcie' END AS status__sprawdzanie_dzialan___skutecznosc_dzialan,
                sd.uwagi AS uwagi__sprawdzanie_dzialan___skutecznosc_dzialan
            FROM 
                public.audyt a
            LEFT JOIN 
                public.slownik_typ_audytu sta ON a.typ_id = sta.id
            LEFT JOIN 
                public.opis_problemu_audyt opa ON a.id = opa.audyt_id
            LEFT JOIN 
                public.opis_problemu op ON opa.opis_problemu_id = op.id
            LEFT JOIN 
                public.dzialanie_opis_problemu dop_k ON op.id = dop_k.opis_problemu_id
            LEFT JOIN 
                public.dzialanie dk ON dop_k.dzialanie_id = dk.id AND dk.typ_id = 1
            LEFT JOIN 
                public.dzialanie_pracownik dp1 ON dk.id = dp1.dzialanie_id
            LEFT JOIN 
                public.pracownik p1 ON dp1.pracownik_id = p1.id
            LEFT JOIN 
                public.dzialanie_opis_problemu dop_kg ON op.id = dop_kg.opis_problemu_id
            LEFT JOIN 
                public.dzialanie dkg ON dop_kg.dzialanie_id = dkg.id AND dkg.typ_id = 2
            LEFT JOIN 
                public.dzialanie_pracownik dp2 ON dkg.id = dp2.dzialanie_id
            LEFT JOIN 
                public.pracownik p2 ON dp2.pracownik_id = p2.id
            LEFT JOIN 
                public.sprawdzanie_dzialan_opis_problemu sdop_z ON op.id = sdop_z.opis_problemu_id
            LEFT JOIN 
                public.sprawdzanie_dzialan zd ON sdop_z.sprawdzanie_dzialan_id = zd.id AND zd.typ_id = 1
            LEFT JOIN 
                public.sprawdzanie_dzialan_pracownik sdp3 ON zd.id = sdp3.sprawdzanie_dzialan_id
            LEFT JOIN 
                public.pracownik p3 ON sdp3.pracownik_id = p3.id
            LEFT JOIN 
                public.sprawdzanie_dzialan_opis_problemu sdop_s ON op.id = sdop_s.opis_problemu_id
            LEFT JOIN 
                public.sprawdzanie_dzialan sd ON sdop_s.sprawdzanie_dzialan_id = sd.id AND sd.typ_id = 2
            LEFT JOIN 
                public.sprawdzanie_dzialan_pracownik sdp4 ON sd.id = sdp4.sprawdzanie_dzialan_id
            LEFT JOIN 
                public.pracownik p4 ON sdp4.pracownik_id = p4.id
            ORDER BY a.id DESC
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
    
    if st.session_state.original_df_audyty.empty:
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
        if row_idx not in st.session_state.original_df_audyty.index:
            st.session_state.update_errors.append(f"Row index {row_idx} not found in original data.")
            return False
            
        original_row = st.session_state.original_df_audyty.loc[row_idx]
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
        
        # Handle audit type changes
        if column_name == "typ__audyt":
            # Get the audyt ID
            audyt_id = int(original_row["id__audyt"])
            
            # Map the audit type name to ID
            audit_type_map = {"wewnętrzny": 1, "zewnętrzny": 2}
            if new_value in audit_type_map:
                new_audit_type_id = audit_type_map[new_value]
                
                # Update the typ_id in the audyt table
                sql = "UPDATE public.audyt SET typ_id = %s WHERE id = %s"
                cursor.execute(sql, [new_audit_type_id, audyt_id])
                
                # Log the update
                log_entry = {
                    "table": "audyt",
                    "id": audyt_id,
                    "changes": [{
                        "field": "typ_id",
                        "value": new_audit_type_id,
                        "original": original_value
                    }],
                    "success": True
                }
                st.session_state.update_logs.append(log_entry)
                
                # Commit the change
                conn.commit()
                
                # Set success message
                st.session_state.update_success = f"Updated audyt.typ_id to {new_audit_type_id}"
                
                # Update the original dataframe with the new value
                st.session_state.original_df_audyty.at[row_idx, column_name] = new_value
                
                cursor.close()
                conn.close()
                return True
            else:
                st.session_state.update_errors.append(f"Audit type '{new_value}' not found.")
                cursor.close()
                conn.close()
                return False
        
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
            if "dzialanie_korekcyjne" in column_name:
                id_col = "id__pracownik_1"
            elif "dzialanie_korygujace" in column_name:
                id_col = "id__pracownik_2"
            elif "zatwierdzenie_dzialan" in column_name:
                id_col = "id__pracownik_3"
            elif "sprawdzenie_dzialan" in column_name:
                id_col = "id__pracownik_4"
        
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
            st.session_state.original_df_audyty.at[row_idx, column_name] = new_value
            
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

def main():
    st.title("Audyty")
    
    # Get data
    if 'original_df_audyty' not in st.session_state or st.session_state.original_df_audyty is None:
        with st.spinner("Ładowanie danych..."):
            st.session_state.original_df_audyty = get_audyty_data()
    
    # Make a copy for editing
    if 'edited_df_audyty' not in st.session_state or st.session_state.edited_df_audyty is None:
        st.session_state.edited_df_audyty = st.session_state.original_df_audyty.copy()
    
    if 'original_df_audyty' in st.session_state and not st.session_state.original_df_audyty.empty:
        # Display data editor with the specified column order
        column_order = [
            'data__audyt', 'typ__audyt', 'zakres__audyt', 'uwagi__audyt', 'opis__opis_problemu', 
            'przyczyna_bezposrednia__opis_problemu', 'termin_wyslania_odpowiedzi__audyt', 'termin_zakonczenia_dzialan__audyt',
            'opis_dzialania__dzialanie___dzialanie_korekcyjne', 'imie_nazwisko__pracownik___dzialanie_korekcyjne',
            'data_planowana__dzialanie___dzialanie_korekcyjne', 'data_rzeczywista__dzialanie___dzialanie_korekcyjne',
            'opis_dzialania__dzialanie___dzialanie_korygujace', 'imie_nazwisko__pracownik___dzialanie_korygujace',
            'data_planowana__dzialanie___dzialanie_korygujace', 'data_rzeczywista__dzialanie___dzialanie_korygujace',
            'imie_nazwisko__pracownik___zatwierdzenie_dzialan', 'data__sprawdzanie_dzialan___zatwierdzenie_dzialan',
            'status__sprawdzanie_dzialan___zatwierdzenie_dzialan', 'uwagi__sprawdzanie_dzialan___zatwierdzenie_dzialan',
            'imie_nazwisko__pracownik___sprawdzenie_dzialan', 'data__sprawdzanie_dzialan___skutecznosc_dzialan',
            'status__sprawdzanie_dzialan___skutecznosc_dzialan', 'uwagi__sprawdzanie_dzialan___skutecznosc_dzialan'
        ]
        
        # Filter column_order to only include columns that exist in the dataframe
        visible_columns = [col for col in column_order if col in st.session_state.original_df_audyty.columns]
        
        # Add filters in sidebar
        st.sidebar.header("Filtry")
        
        # Initialize filtered dataframe
        filtered_df = st.session_state.original_df_audyty.copy()
        
        # Add filters for each visible column
        for col in visible_columns:
            if col in filtered_df.columns:
                # Get unique values for the column (excluding NaN)
                unique_values = filtered_df[col].dropna().unique()
                
                if len(unique_values) > 0:
                    # For date columns, use date range filter
                    if "data" in col or "termin" in col:
                        try:
                            # Convert to datetime if not already
                            date_series = pd.to_datetime(filtered_df[col], errors='coerce')
                            min_date = date_series.min()
                            max_date = date_series.max()
                            
                            if pd.notna(min_date) and pd.notna(max_date):
                                date_range = st.sidebar.date_input(
                                    f"Zakres dat - {col}",
                                    value=[],
                                    min_value=min_date.date(),
                                    max_value=max_date.date(),
                                    key=f"date_filter_{col}"
                                )
                                
                                if len(date_range) == 2:
                                    start_date, end_date = date_range
                                    mask = (date_series.dt.date >= start_date) & (date_series.dt.date <= end_date)
                                    filtered_df = filtered_df[mask | date_series.isna()]
                        except:
                            pass
                    
                    # For text columns, use multiselect filter
                    else:
                        # Limit to reasonable number of unique values for multiselect
                        if len(unique_values) <= 50:
                            selected_values = st.sidebar.multiselect(
                                f"Filtruj - {col}",
                                options=sorted([str(val) for val in unique_values]),
                                default=[],
                                key=f"text_filter_{col}"
                            )
                            
                            if selected_values:
                                mask = filtered_df[col].astype(str).isin(selected_values) | filtered_df[col].isna()
                                filtered_df = filtered_df[mask]
                        else:
                            # For columns with too many unique values, use text input filter
                            search_term = st.sidebar.text_input(
                                f"Szukaj w {col}",
                                key=f"search_filter_{col}"
                            )
                            
                            if search_term:
                                mask = filtered_df[col].astype(str).str.contains(search_term, case=False, na=False)
                                filtered_df = filtered_df[mask]
        
        # Update edited dataframe with filtered data
        st.session_state.edited_df_audyty = filtered_df.copy()
        
        # Define column configurations
        column_config = {}
        
        # Create column config for different data types
        for col_name in st.session_state.original_df_audyty.columns:
            if "data" in col_name or "termin" in col_name:
                column_config[col_name] = st.column_config.DateColumn(col_name)
            elif "status" in col_name:
                column_config[col_name] = st.column_config.SelectboxColumn(
                    col_name,
                    options=["W trakcie", "Zakończone"]
                )
            elif "typ__audyt" in col_name:
                column_config[col_name] = st.column_config.SelectboxColumn(
                    col_name,
                    options=["wewnętrzny", "zewnętrzny"]
                )
            else:
                column_config[col_name] = st.column_config.Column(col_name)
        
        # Add a container for the data editor
        with st.container():
            # Make the data editor editable
            edited_df = st.data_editor(
                st.session_state.edited_df_audyty[visible_columns],
                column_config=column_config,
                hide_index=True,
                key="data_editor_audyty",
                use_container_width=True,
                num_rows="fixed"
            )
            
            # Check for changes and update database
            if "edited_rows" in st.session_state.data_editor_audyty:
                current_edited_rows = st.session_state.data_editor_audyty["edited_rows"]
                
                # Find new edits by comparing with previous edited rows
                for idx, changed_values in current_edited_rows.items():
                    row_idx = int(idx)
                    
                    # Check if this row was previously edited
                    if idx in st.session_state.previous_edited_rows_audyty:
                        prev_changes = st.session_state.previous_edited_rows_audyty[idx]
                        
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
                st.session_state.previous_edited_rows_audyty = current_edited_rows.copy()
        
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
        if st.button("Odśwież dane", key="refresh_audyty"):
            st.session_state.original_df_audyty = get_audyty_data()
            st.session_state.edited_df_audyty = st.session_state.original_df_audyty.copy()
            st.session_state.update_errors = []
            st.session_state.update_success = "Dane odświeżone"
            st.session_state.update_logs = []
            st.session_state.previous_edited_rows_audyty = {}
            st.rerun()
    else:
        st.warning("Brak danych do wyświetlenia.")

if __name__ == "__main__":
    main() 