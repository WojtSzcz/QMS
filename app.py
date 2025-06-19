import streamlit as st
import psycopg2
import pandas as pd
from psycopg2.extras import RealDictCursor
import time
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

from Raporty import reklamacje
from Raporty import doskonalenia
from Raporty import raporty_8d
from Raporty import audyty

# Database connection parameters
db_params = {
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT")
}

# Page configuration
st.set_page_config(page_title="Zehs - System jakości", layout="wide")

# Create sidebar navigation
st.sidebar.title("Nawigacja")
page = st.sidebar.radio("Wybierz stronę:", ["Reklamacje", "Doskonalenia", "Raporty 8D", "Audyty"])

# Initialize session state for error messages
if 'update_errors' not in st.session_state:
    st.session_state.update_errors = []

if 'update_success' not in st.session_state:
    st.session_state.update_success = None
    
if 'update_logs' not in st.session_state:
    st.session_state.update_logs = []

# Initialize session state for data tracking
if 'edited_df' not in st.session_state:
    st.session_state.edited_df = None

if 'original_df' not in st.session_state:
    st.session_state.original_df = None

if 'previous_edited_rows' not in st.session_state:
    st.session_state.previous_edited_rows = {}

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
            
            # Get data types for reklamacja table
            cursor.execute("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'reklamacja' AND table_schema = 'public'
            """)
            reklamacja_columns = {row[0]: row[1] for row in cursor.fetchall()}
            
            # Get data types for firma table
            cursor.execute("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'firma' AND table_schema = 'public'
            """)
            firma_columns = {row[0]: row[1] for row in cursor.fetchall()}
            
            # Get data types for detal table
            cursor.execute("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'detal' AND table_schema = 'public'
            """)
            detal_columns = {row[0]: row[1] for row in cursor.fetchall()}
            
            # Get data types for opis_problemu table
            cursor.execute("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'opis_problemu' AND table_schema = 'public'
            """)
            opis_problemu_columns = {row[0]: row[1] for row in cursor.fetchall()}
            
            cursor.close()
            conn.close()
            
            # Combine all data types into a single dictionary
            column_data_types = {
                "reklamacja": reklamacja_columns,
                "firma": firma_columns,
                "detal": detal_columns,
                "opis_problemu": opis_problemu_columns
            }
            
            return column_data_types
        except Exception as e:
            error_msg = f"Error fetching column data types: {e}"
            st.session_state.update_errors.append(error_msg)
            st.error(error_msg)
            if conn:
                conn.close()
            return {}
    return {}

# Function to get reklamacje data with related tables
def get_reklamacje_data():
    conn = connect_to_db()
    if conn:
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            query = """
            SELECT 
                r.id AS id__reklamacja,
                f.id AS id__firma,
                d.id AS id__detal,
                op.id AS id__opis_problemu,
                f.kod AS kod__firma, 
                f.nazwa AS nazwa__firma,
                r.nr_reklamacji AS nr_reklamacji__reklamacja,
                r.nr_protokolu AS nr_protokolu__reklamacja,
                r.zlecenie AS zlecenie__reklamacja,
                r.data_otwarcia AS data_otwarcia__reklamacja,
                d.kod AS kod__detal,
                r.typ_cylindra AS typ_cylindra__reklamacja,
                d.oznaczenie AS oznaczenie__detal,
                f.oznaczenie_klienta AS oznaczenie_klienta__firma,
                d.ilosc_niezgodna AS ilosc_niezgodna__detal,
                r.data_weryfikacji AS data_weryfikacji__reklamacja,
                r.analiza_terminowosci_weryfikacji AS analiza_terminowosci_weryfikacji__reklamacja,
                r.data_produkcji_silownika AS data_produkcji__reklamacja,
                op.kod_przyczyny AS kod_przyczyny__opis_problemu,
                op.przyczyna_ogolna AS przyczyna_ogolna__opis_problemu,
                op.przyczyna_bezposrednia AS przyczyna_bezposrednia__opis_problemu,
                op.uwagi AS uwagi__opis_problemu,
                d.ilosc_uznanych AS ilosc_uznanych__detal,
                d.ilosc_nieuznanych AS ilosc_nieuznanych__detal,
                d.ilosc_nowych_uznanych AS ilosc_nowych_uznanych__detal,
                d.ilosc_nowych_nieuznanych AS ilosc_nowych_nieuznanych__detal,
                d.ilosc_rozliczona AS ilosc_rozliczona__detal,
                d.ilosc_nieuznanych_naprawionych AS ilosc_nieuznanych_naprawionych__detal,
                r.dokument_rozliczeniowy AS dokument_rozliczeniowy__reklamacja,
                r.nr_dokumentu AS nr_dokumentu__reklamacja,
                r.data_dokumentu AS data_dokumentu__reklamacja,
                r.nr_magazynu AS nr_magazynu__reklamacja,
                r.nr_listu_przewozowego AS nr_listu_przewozowego__reklamacja,
                r.przewoznik AS przewoznik__reklamacja,
                r.analiza_terminowosci_realizacji AS analiza_terminowosci_realizacji__reklamacja
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
            WHERE 
                r.typ_id = 1
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
    
    if st.session_state.original_df.empty:
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
        if row_idx not in st.session_state.original_df.index:
            st.session_state.update_errors.append(f"Row index {row_idx} not found in original data.")
            return False
            
        original_row = st.session_state.original_df.loc[row_idx]
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
                st.session_state.original_df.at[row_idx, column_name] = new_value
                st.session_state.original_df.at[row_idx, "id__firma"] = new_company_id
                
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
        
        # Get the record ID
        id_col = f"id__{table_name}"
        if id_col not in original_row or pd.isna(original_row[id_col]):
            st.session_state.update_errors.append(f"No ID found for {table_name}")
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
            st.session_state.original_df.at[row_idx, column_name] = new_value
            
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
    st.title("Reklamacje")
    
    # Get data
    if st.session_state.original_df is None:
        st.session_state.original_df = get_reklamacje_data()
    
    # Make a copy for editing
    if st.session_state.edited_df is None:
        st.session_state.edited_df = st.session_state.original_df.copy()
    
    # Get column data types
    column_data_types = get_column_data_types()
    
    # Get company names for dropdown
    company_names = get_company_names()
    
    if not st.session_state.original_df.empty:
        # Define column configurations with enhanced headers
        column_config = {}
        
        # Column name mapping for display
        column_display_names = {
            "kod__firma": {"table": "firma", "column": "kod"},
            "nazwa__firma": {"table": "firma", "column": "nazwa"},
            "nr_reklamacji__reklamacja": {"table": "reklamacja", "column": "nr_reklamacji"},
            "nr_protokolu__reklamacja": {"table": "reklamacja", "column": "nr_protokolu"},
            "zlecenie__reklamacja": {"table": "reklamacja", "column": "zlecenie"},
            "data_otwarcia__reklamacja": {"table": "reklamacja", "column": "data_otwarcia"},
            "kod__detal": {"table": "detal", "column": "kod"},
            "typ_cylindra__reklamacja": {"table": "reklamacja", "column": "typ_cylindra"},
            "oznaczenie__detal": {"table": "detal", "column": "oznaczenie"},
            "oznaczenie_klienta__firma": {"table": "firma", "column": "oznaczenie_klienta"},
            "ilosc_niezgodna__detal": {"table": "detal", "column": "ilosc_niezgodna"},
            "data_weryfikacji__reklamacja": {"table": "reklamacja", "column": "data_weryfikacji"},
            "analiza_terminowosci_weryfikacji__reklamacja": {"table": "reklamacja", "column": "analiza_terminowosci_weryfikacji"},
            "data_produkcji__reklamacja": {"table": "reklamacja", "column": "data_produkcji_silownika"},
            "kod_przyczyny__opis_problemu": {"table": "opis_problemu", "column": "kod_przyczyny"},
            "przyczyna_ogolna__opis_problemu": {"table": "opis_problemu", "column": "przyczyna_ogolna"},
            "przyczyna_bezposrednia__opis_problemu": {"table": "opis_problemu", "column": "przyczyna_bezposrednia"},
            "uwagi__opis_problemu": {"table": "opis_problemu", "column": "uwagi"},
            "ilosc_uznanych__detal": {"table": "detal", "column": "ilosc_uznanych"},
            "ilosc_nieuznanych__detal": {"table": "detal", "column": "ilosc_nieuznanych"},
            "ilosc_nowych_uznanych__detal": {"table": "detal", "column": "ilosc_nowych_uznanych"},
            "ilosc_nowych_nieuznanych__detal": {"table": "detal", "column": "ilosc_nowych_nieuznanych"},
            "ilosc_rozliczona__detal": {"table": "detal", "column": "ilosc_rozliczona"},
            "ilosc_nieuznanych_naprawionych__detal": {"table": "detal", "column": "ilosc_nieuznanych_naprawionych"},
            "dokument_rozliczeniowy__reklamacja": {"table": "reklamacja", "column": "dokument_rozliczeniowy"},
            "nr_dokumentu__reklamacja": {"table": "reklamacja", "column": "nr_dokumentu"},
            "data_dokumentu__reklamacja": {"table": "reklamacja", "column": "data_dokumentu"},
            "nr_magazynu__reklamacja": {"table": "reklamacja", "column": "nr_magazynu"},
            "nr_listu_przewozowego__reklamacja": {"table": "reklamacja", "column": "nr_listu_przewozowego"},
            "przewoznik__reklamacja": {"table": "reklamacja", "column": "przewoznik"},
            "analiza_terminowosci_realizacji__reklamacja": {"table": "reklamacja", "column": "analiza_terminowosci_realizacji"}
        }
        
        # Create column config with enhanced headers
        for col_name in st.session_state.original_df.columns:
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
                elif "ilosc" in col_name or "analiza" in col_name:
                    column_config[col_name] = st.column_config.NumberColumn(header)
                elif col_name == "dokument_rozliczeniowy__reklamacja":
                    column_config[col_name] = st.column_config.SelectboxColumn(
                        header,
                        options=["korekta", "WZ", "złom", "ZW", "ZW złom"]
                    )
                else:
                    column_config[col_name] = st.column_config.Column(header)
        
        # Display data editor with the specified column order
        column_order = [
            "kod__firma", "nazwa__firma", "nr_reklamacji__reklamacja",
            "nr_protokolu__reklamacja", "zlecenie__reklamacja",
            "data_otwarcia__reklamacja", "kod__detal", "typ_cylindra__reklamacja",
            "oznaczenie__detal", "oznaczenie_klienta__firma",
            "ilosc_niezgodna__detal", "data_weryfikacji__reklamacja",
            "analiza_terminowosci_weryfikacji__reklamacja",
            "data_produkcji__reklamacja", "kod_przyczyny__opis_problemu",
            "przyczyna_ogolna__opis_problemu",
            "przyczyna_bezposrednia__opis_problemu", "uwagi__opis_problemu",
            "ilosc_uznanych__detal", "ilosc_nieuznanych__detal",
            "ilosc_nowych_uznanych__detal", "ilosc_nowych_nieuznanych__detal",
            "ilosc_rozliczona__detal", "ilosc_nieuznanych_naprawionych__detal",
            "dokument_rozliczeniowy__reklamacja", "nr_dokumentu__reklamacja",
            "data_dokumentu__reklamacja", "nr_magazynu__reklamacja",
            "nr_listu_przewozowego__reklamacja", "przewoznik__reklamacja",
            "analiza_terminowosci_realizacji__reklamacja"
        ]
        
        # Hide ID columns from display but keep them for updates
        visible_columns = [col for col in column_order if col in st.session_state.original_df.columns]
        id_columns = [col for col in st.session_state.original_df.columns if col.startswith("id__")]
        
        # Add a container for the data editor
        with st.container():
            # Make the data editor editable
            edited_df = st.data_editor(
                st.session_state.edited_df[visible_columns],
                column_config=column_config,
                hide_index=True,
                key="data_editor",
                use_container_width=True,
                num_rows="fixed"
            )
            
            # Check for changes and update database
            if "edited_rows" in st.session_state.data_editor:
                current_edited_rows = st.session_state.data_editor["edited_rows"]
                
                # Find new edits by comparing with previous edited rows
                for idx, changed_values in current_edited_rows.items():
                    row_idx = int(idx)
                    
                    # Check if this row was previously edited
                    if idx in st.session_state.previous_edited_rows:
                        prev_changes = st.session_state.previous_edited_rows[idx]
                        
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
                st.session_state.previous_edited_rows = current_edited_rows.copy()
        
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
        if st.button("Odśwież dane"):
            st.session_state.original_df = get_reklamacje_data()
            st.session_state.edited_df = st.session_state.original_df.copy()
            st.session_state.update_errors = []
            st.session_state.update_success = "Dane odświeżone"
            st.session_state.update_logs = []
            st.session_state.previous_edited_rows = {}
            st.rerun()
    else:
        st.warning("Brak danych do wyświetlenia.")

# Display selected page
if page == "Reklamacje":
    reklamacje.main()
elif page == "Doskonalenia":
    doskonalenia.main()
elif page == "Raporty 8D":
    raporty_8d.main()
elif page == "Audyty":
    audyty.main()

if __name__ == "__main__":
    pass
