import streamlit as st
import pandas as pd
import datetime
import sys
import os

# Add parent directory to path to import db_connect
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from db_connect import execute_query, load_employee_names, load_firma_names, load_dokument_rozliczeniowy_options, update_database_cell

# Session state initialization moved to main() function

def update_raporty_8d_database(row_idx, column_name, new_value, original_df):
    """Handle database updates for raporty_8d - primarily reklamacja table"""
    try:
        # Get the reklamacja ID for this row
        reklamacja_id_query = f"""
            SELECT r.id as reklamacja_id
            FROM reklamacja r
            LEFT JOIN firma f ON r.firma_id = f.id
            LEFT JOIN slownik_typ_reklamacji str ON r.typ_id = str.id
            ORDER BY r.data_otwarcia DESC
            LIMIT 1 OFFSET {row_idx}
        """
        
        id_result = execute_query(reklamacja_id_query)
        if id_result.empty:
            return False, "Could not find reklamacja record to update"
        
        reklamacja_id = id_result.iloc[0]['reklamacja_id']
        
        # Parse column name to determine field
        column_parts = column_name.split('. ', 1)[1]  # Remove number prefix
        
        # Most columns are in reklamacja table
        if 'reklamacja' in column_parts:
            table_name = 'reklamacja'
            record_id = reklamacja_id
            
            # Map column names to database fields
            if 'data_otwarcia__reklamacja' in column_parts:
                field_name = 'data_otwarcia'
            elif 'nr_reklamacji__reklamacja' in column_parts:
                field_name = 'nr_reklamacji'
            elif 'data_weryfikacji__reklamacja' in column_parts:
                field_name = 'data_weryfikacji'
            elif 'data_zakonczenia__reklamacja' in column_parts:
                field_name = 'data_zakończenia'
            elif 'data_produkcji_silownika__reklamacja' in column_parts:
                field_name = 'data_produkcji_silownika'
            elif 'typ_cylindra__reklamacja' in column_parts:
                field_name = 'typ_cylindra'
            elif 'zlecenie__reklamacja' in column_parts:
                field_name = 'zlecenie'
            elif 'status__reklamacja' in column_parts:
                field_name = 'status'
            elif 'nr_protokolu__reklamacja' in column_parts:
                field_name = 'nr_protokolu'
            elif 'analiza_terminowosci_weryfikacji__reklamacja' in column_parts:
                field_name = 'analiza_terminowosci_weryfikacji'
            elif 'dokument_rozliczeniowy__reklamacja' in column_parts:
                field_name = 'dokument_rozliczeniowy'
            elif 'nr_dokumentu__reklamacja' in column_parts:
                field_name = 'nr_dokumentu'
            elif 'data_dokumentu__reklamacja' in column_parts:
                field_name = 'data_dokumentu'
            elif 'nr_magazynu__reklamacja' in column_parts:
                field_name = 'nr_magazynu'
            elif 'nr_listu_przewozowego__reklamacja' in column_parts:
                field_name = 'nr_listu_przewozowego'
            elif 'przewoznik__reklamacja' in column_parts:
                field_name = 'przewoznik'
            elif 'analiza_terminowosci_realizacji__reklamacja' in column_parts:
                field_name = 'analiza_terminowosci_realizacji'
            else:
                return False, f"Unknown reklamacja field: {column_parts}"
        else:
            # For other tables like firma, we can't easily update without more complex logic
            return False, f"Updates to {column_parts} not supported (complex relationships)"
        
        # Perform the database update
        success, message = update_database_cell(table_name, field_name, record_id, new_value)
        return success, message
        
    except Exception as e:
        return False, f"Error in update_raporty_8d_database: {str(e)}"

# Main data loading function with enhanced filters
def load_data(filters=None):
    where_conditions = []
    
    if filters:
        if filters.get('date_from'):
            where_conditions.append(f"r.data_otwarcia >= '{filters['date_from']}'")
        if filters.get('date_to'):
            where_conditions.append(f"r.data_otwarcia <= '{filters['date_to']}'")
        if filters.get('employee_filter'):
            where_conditions.append(f"(p1.imie || ' ' || p1.nazwisko) ILIKE '%{filters['employee_filter']}%' OR (p2.imie || ' ' || p2.nazwisko) ILIKE '%{filters['employee_filter']}%'")
        if filters.get('status_filter') is not None:
            where_conditions.append(f"r.status = {filters['status_filter']}")
        if filters.get('company_filter'):
            where_conditions.append(f"f.nazwa = '{filters['company_filter']}'")
        if filters.get('nr_reklamacji'):
            where_conditions.append(f"r.nr_reklamacji ILIKE '%{filters['nr_reklamacji']}%'")
        if filters.get('typ_cylindra'):
            where_conditions.append(f"r.typ_cylindra ILIKE '%{filters['typ_cylindra']}%'")
        if filters.get('zlecenie'):
            where_conditions.append(f"r.zlecenie ILIKE '%{filters['zlecenie']}%'")
        if filters.get('dokument_rozliczeniowy'):
            where_conditions.append(f"r.dokument_rozliczeniowy = '{filters['dokument_rozliczeniowy']}'")
    
    where_clause = "WHERE " + " AND ".join(where_conditions) if where_conditions else ""
    
    query = f"""
        SELECT 
            r.id,
            r.data_otwarcia as data_otwarcia__reklamacja,
            f.nazwa as nazwa__firma,
            r.nr_reklamacji as nr_reklamacji__reklamacja,
            str.nazwa as typ__slownik_typ_reklamacji,
            r.data_weryfikacji as data_weryfikacji__reklamacja,
            r."data_zakończenia" as data_zakonczenia__reklamacja,
            r.data_produkcji_silownika as data_produkcji_silownika__reklamacja,
            r.typ_cylindra as typ_cylindra__reklamacja,
            r.zlecenie as zlecenie__reklamacja,
            r.status as status__reklamacja,
            r.nr_protokolu as nr_protokolu__reklamacja,
            r.analiza_terminowosci_weryfikacji as analiza_terminowosci_weryfikacji__reklamacja,
            r.dokument_rozliczeniowy as dokument_rozliczeniowy__reklamacja,
            r.nr_dokumentu as nr_dokumentu__reklamacja,
            r.data_dokumentu as data_dokumentu__reklamacja,
            r.nr_magazynu as nr_magazynu__reklamacja,
            r.nr_listu_przewozowego as nr_listu_przewozowego__reklamacja,
            r.przewoznik as przewoznik__reklamacja,
            r.analiza_terminowosci_realizacji as analiza_terminowosci_realizacji__reklamacja,
            ARRAY_AGG(DISTINCT d.opis_dzialania) FILTER (WHERE d.opis_dzialania IS NOT NULL) as opis_dzialania__dzialanie,
            ARRAY_AGG(DISTINCT CONCAT(p1.imie, ' ', p1.nazwisko)) FILTER (WHERE p1.imie IS NOT NULL) as imie_nazwisko__pracownik,
            ARRAY_AGG(DISTINCT sd.uwagi) FILTER (WHERE sd.uwagi IS NOT NULL) as uwagi__sprawdzanie_dzialan
        FROM reklamacja r
        LEFT JOIN firma f ON r.firma_id = f.id
        LEFT JOIN slownik_typ_reklamacji str ON r.typ_id = str.id
        LEFT JOIN opis_problemu_reklamacja opr ON r.id = opr.reklamacja_id
        LEFT JOIN opis_problemu op ON opr.opis_problemu_id = op.id
        LEFT JOIN dzialanie_opis_problemu dop ON op.id = dop.opis_problemu_id
        LEFT JOIN dzialanie d ON dop.dzialanie_id = d.id
        LEFT JOIN dzialanie_pracownik dp ON d.id = dp.dzialanie_id
        LEFT JOIN pracownik p1 ON dp.pracownik_id = p1.id
        LEFT JOIN sprawdzanie_dzialan_opis_problemu sdop ON op.id = sdop.opis_problemu_id
        LEFT JOIN sprawdzanie_dzialan sd ON sdop.sprawdzanie_dzialan_id = sd.id
        LEFT JOIN sprawdzanie_dzialan_pracownik sdp ON sd.id = sdp.sprawdzanie_dzialan_id
        LEFT JOIN pracownik p2 ON sdp.pracownik_id = p2.id
        {where_clause}
        GROUP BY r.id, r.data_otwarcia, f.nazwa, r.nr_reklamacji, str.nazwa, r.data_weryfikacji,
                 r."data_zakończenia", r.data_produkcji_silownika, r.typ_cylindra, r.zlecenie, r.status,
                 r.nr_protokolu, r.analiza_terminowosci_weryfikacji, r.dokument_rozliczeniowy,
                 r.nr_dokumentu, r.data_dokumentu, r.nr_magazynu, r.nr_listu_przewozowego,
                 r.przewoznik, r.analiza_terminowosci_realizacji
        ORDER BY r.data_otwarcia DESC
    """
    return execute_query(query)

# Column configuration
def get_column_config():
    employee_names = load_employee_names()
    
    return {
        "1. data_otwarcia__reklamacja (date)": st.column_config.DateColumn(
            "1. data_otwarcia__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "2. nazwa__firma (text)": st.column_config.TextColumn(
            "2. nazwa__firma (text)",
            width="medium"
        ),
        "3. nr_reklamacji__reklamacja (text)": st.column_config.TextColumn(
            "3. nr_reklamacji__reklamacja (text)",
            width="medium"
        ),
        "4. typ__slownik_typ_reklamacji (text)": st.column_config.TextColumn(
            "4. typ__slownik_typ_reklamacji (text)",
            width="medium"
        ),
        "5. data_weryfikacji__reklamacja (date)": st.column_config.DateColumn(
            "5. data_weryfikacji__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "6. data_zakonczenia__reklamacja (date)": st.column_config.DateColumn(
            "6. data_zakonczenia__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "7. data_produkcji_silownika__reklamacja (date)": st.column_config.DateColumn(
            "7. data_produkcji_silownika__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "8. typ_cylindra__reklamacja (text)": st.column_config.TextColumn(
            "8. typ_cylindra__reklamacja (text)",
            width="medium"
        ),
        "9. zlecenie__reklamacja (text)": st.column_config.TextColumn(
            "9. zlecenie__reklamacja (text)",
            width="medium"
        ),
        "10. status__reklamacja (checkbox)": st.column_config.CheckboxColumn(
            "10. status__reklamacja (checkbox)",
            width="small"
        ),
        "11. nr_protokolu__reklamacja (text)": st.column_config.TextColumn(
            "11. nr_protokolu__reklamacja (text)",
            width="medium"
        ),
        "12. analiza_terminowosci_weryfikacji__reklamacja (number)": st.column_config.NumberColumn(
            "12. analiza_terminowosci_weryfikacji__reklamacja (number)",
            width="medium"
        ),
        "13. dokument_rozliczeniowy__reklamacja (text)": st.column_config.SelectboxColumn(
            "13. dokument_rozliczeniowy__reklamacja (text)",
            options=["nota_korygujaca", "nota_obciazeniowa", "zwrot_towaru"],
            width="medium"
        ),
        "14. nr_dokumentu__reklamacja (text)": st.column_config.TextColumn(
            "14. nr_dokumentu__reklamacja (text)",
            width="medium"
        ),
        "15. data_dokumentu__reklamacja (date)": st.column_config.DateColumn(
            "15. data_dokumentu__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "16. nr_magazynu__reklamacja (text)": st.column_config.TextColumn(
            "16. nr_magazynu__reklamacja (text)",
            width="medium"
        ),
        "17. nr_listu_przewozowego__reklamacja (text)": st.column_config.TextColumn(
            "17. nr_listu_przewozowego__reklamacja (text)",
            width="medium"
        ),
        "18. przewoznik__reklamacja (text)": st.column_config.TextColumn(
            "18. przewoznik__reklamacja (text)",
            width="medium"
        ),
        "19. analiza_terminowosci_realizacji__reklamacja (number)": st.column_config.NumberColumn(
            "19. analiza_terminowosci_realizacji__reklamacja (number)",
            width="medium"
        ),
        "20. opis_dzialania__dzialanie (list)": st.column_config.ListColumn(
            "20. opis_dzialania__dzialanie (list)",
            width="large"
        ),
        "21. imie_nazwisko__pracownik (list)": st.column_config.ListColumn(
            "21. imie_nazwisko__pracownik (list)",
            width="medium"
        ),
        "22. uwagi__sprawdzanie_dzialan (list)": st.column_config.ListColumn(
            "22. uwagi__sprawdzanie_dzialan (list)",
            width="large"
        )
    }

def main():
    st.title("Raporty 8D - Quality Management System")
    
    # Initialize session state for update tracking
    if 'raporty_8d_update_status' not in st.session_state:
        st.session_state.raporty_8d_update_status = []
    
    if 'raporty_8d_original_df' not in st.session_state:
        st.session_state.raporty_8d_original_df = None
    
    # Sidebar filters
    st.sidebar.header("Filters")
    
    # Prepare filter options
    employee_names = load_employee_names()
    firma_names = load_firma_names()
    dokument_options = load_dokument_rozliczeniowy_options()
    
    # Create filters dictionary
    filters = {}
    
    # Date filters
    st.sidebar.subheader("Date Filters")
    date_from = st.sidebar.date_input("Date from", value=None, key="8d_date_from")
    date_to = st.sidebar.date_input("Date to", value=None, key="8d_date_to")
    if date_from:
        filters['date_from'] = date_from
    if date_to:
        filters['date_to'] = date_to
    
    # Basic filters
    st.sidebar.subheader("Basic Filters")
    company_filter = st.sidebar.selectbox("Company", options=["All"] + firma_names, index=0, key="8d_company")
    if company_filter != "All":
        filters['company_filter'] = company_filter
    
    employee_filter = st.sidebar.selectbox("Employee", options=["All"] + employee_names, index=0, key="8d_employee")
    if employee_filter != "All":
        filters['employee_filter'] = employee_filter
    
    status_filter = st.sidebar.selectbox("Status", options=["All", "Open", "Closed"], index=0, key="8d_status")
    if status_filter == "Open":
        filters['status_filter'] = False
    elif status_filter == "Closed":
        filters['status_filter'] = True
    
    # Text filters
    st.sidebar.subheader("Text Filters")
    nr_reklamacji = st.sidebar.text_input("Nr reklamacji (contains)", value="", key="8d_nr")
    if nr_reklamacji:
        filters['nr_reklamacji'] = nr_reklamacji
    
    typ_cylindra = st.sidebar.text_input("Typ cylindra (contains)", value="", key="8d_cyl")
    if typ_cylindra:
        filters['typ_cylindra'] = typ_cylindra
    
    zlecenie = st.sidebar.text_input("Zlecenie (contains)", value="", key="8d_zlec")
    if zlecenie:
        filters['zlecenie'] = zlecenie
    
    # Dropdown filters
    st.sidebar.subheader("Dropdown Filters")
    dokument_rozliczeniowy = st.sidebar.selectbox("Dokument rozliczeniowy", options=["All"] + dokument_options, index=0, key="8d_dok")
    if dokument_rozliczeniowy != "All":
        filters['dokument_rozliczeniowy'] = dokument_rozliczeniowy
    
    # Clear filters button
    if st.sidebar.button("Clear All Filters", key="8d_clear"):
        # Reset filter-related session state to clear filters
        for key in list(st.session_state.keys()):
            if key.startswith("8d_") and key != "8d_clear":
                del st.session_state[key]
        st.session_state.raporty_8d_filters_changed = True
        st.rerun()
    
    # Initialize session state for data management
    if 'raporty_8d_data_loaded' not in st.session_state:
        st.session_state.raporty_8d_data_loaded = False
    if 'raporty_8d_current_df' not in st.session_state:
        st.session_state.raporty_8d_current_df = None
    if 'raporty_8d_filters_changed' not in st.session_state:
        st.session_state.raporty_8d_filters_changed = False
    
    # Check if filters have changed
    current_filters = str(filters if filters else {})
    if 'raporty_8d_last_filters' not in st.session_state:
        st.session_state.raporty_8d_last_filters = ""
    
    if current_filters != st.session_state.raporty_8d_last_filters:
        st.session_state.raporty_8d_filters_changed = True
        st.session_state.raporty_8d_last_filters = current_filters
    
    # Load data only if not loaded yet or filters changed
    if not st.session_state.raporty_8d_data_loaded or st.session_state.raporty_8d_filters_changed:
        df = load_data(filters if filters else None)
        
        if df.empty:
            st.warning("No data available")
            return
        
        # Remove ID column from display
        df = df.drop('id', axis=1)
        
        # Rename columns to match specification
        df.columns = [
            "1. data_otwarcia__reklamacja (date)",
            "2. nazwa__firma (text)",
            "3. nr_reklamacji__reklamacja (text)",
            "4. typ__slownik_typ_reklamacji (text)",
            "5. data_weryfikacji__reklamacja (date)",
            "6. data_zakonczenia__reklamacja (date)",
            "7. data_produkcji_silownika__reklamacja (date)",
            "8. typ_cylindra__reklamacja (text)",
            "9. zlecenie__reklamacja (text)",
            "10. status__reklamacja (checkbox)",
            "11. nr_protokolu__reklamacja (text)",
            "12. analiza_terminowosci_weryfikacji__reklamacja (number)",
            "13. dokument_rozliczeniowy__reklamacja (text)",
            "14. nr_dokumentu__reklamacja (text)",
            "15. data_dokumentu__reklamacja (date)",
            "16. nr_magazynu__reklamacja (text)",
            "17. nr_listu_przewozowego__reklamacja (text)",
            "18. przewoznik__reklamacja (text)",
            "19. analiza_terminowosci_realizacji__reklamacja (number)",
            "20. opis_dzialania__dzialanie (list)",
            "21. imie_nazwisko__pracownik (list)",
            "22. uwagi__sprawdzanie_dzialan (list)"
        ]
        
        # Store data in session state
        st.session_state.raporty_8d_current_df = df.copy()
        st.session_state.raporty_8d_data_loaded = True
        st.session_state.raporty_8d_filters_changed = False
        
        # Store original data for comparison
        if 'raporty_8d_original_df' not in st.session_state:
            st.session_state.raporty_8d_original_df = None
        if st.session_state.raporty_8d_original_df is None:
            st.session_state.raporty_8d_original_df = df.copy()
    else:
        # Use cached data
        df = st.session_state.raporty_8d_current_df.copy()
    
    # Display data editor
    st.subheader("Raporty 8D Data")
    
    # Always use the current cached data for display to reflect any updates
    display_df = st.session_state.raporty_8d_current_df.copy() if st.session_state.raporty_8d_current_df is not None else df
    
    edited_df = st.data_editor(
        display_df,
        column_config=get_column_config(),
        use_container_width=True,
        hide_index=True,
        key="raporty_8d_editor"
    )
    
    # Track changes and update database (REAL)
    if "edited_rows" in st.session_state.raporty_8d_editor:
        edited_rows = st.session_state.raporty_8d_editor["edited_rows"]
        if edited_rows:
            for row_idx, changes in edited_rows.items():
                for col_name, new_value in changes.items():
                    # Get original value for comparison
                    if int(row_idx) < len(st.session_state.raporty_8d_original_df):
                        original_value = st.session_state.raporty_8d_original_df.iloc[int(row_idx)][col_name]
                        
                        # Only update if value actually changed
                        if str(new_value) != str(original_value):
                            success, message = update_raporty_8d_database(
                                int(row_idx), col_name, new_value, st.session_state.raporty_8d_original_df
                            )
                            
                            update_info = {
                                "timestamp": pd.Timestamp.now(),
                                "row": row_idx,
                                "column": col_name,
                                "old_value": original_value,
                                "new_value": new_value,
                                "status": "success" if success else "error",
                                "message": message
                            }
                            st.session_state.raporty_8d_update_status.append(update_info)
                            
                            if success:
                                # Update both original and current df to reflect the change
                                st.session_state.raporty_8d_original_df.iloc[int(row_idx), 
                                    st.session_state.raporty_8d_original_df.columns.get_loc(col_name)] = new_value
                                st.session_state.raporty_8d_current_df.iloc[int(row_idx), 
                                    st.session_state.raporty_8d_current_df.columns.get_loc(col_name)] = new_value
    
    # Display update status
    if st.session_state.raporty_8d_update_status:
        st.subheader("Database Update Status")
        
        # Show recent updates (last 10)
        recent_updates = st.session_state.raporty_8d_update_status[-10:]
        
        for update in reversed(recent_updates):
            if update["status"] == "success":
                st.success(f"✅ Row {update['row']}, Column '{update['column']}': '{update['old_value']}' → '{update['new_value']}' (Updated at {update['timestamp'].strftime('%H:%M:%S')})")
            else:
                st.error(f"❌ Row {update['row']}, Column '{update['column']}': {update.get('message', 'Update failed')} (At {update['timestamp'].strftime('%H:%M:%S')})")
        
        # Clear updates button
        if st.button("Clear Update History", key="8d_clear_updates"):
            st.session_state.raporty_8d_update_status = []
    
    # Manual refresh button
    col1, col2 = st.columns([1, 4])
    with col1:
        if st.button("🔄 Refresh Data", key="8d_refresh"):
            # Force data refresh by reloading from database
            fresh_df = load_data(filters if filters else None)
            if not fresh_df.empty:
                # Remove ID column and rename columns
                fresh_df = fresh_df.drop('id', axis=1)
                fresh_df.columns = [
                    "1. data_otwarcia__reklamacja (date)", "2. nazwa__firma (text)", "3. nr_reklamacji__reklamacja (text)",
                    "4. typ__slownik_typ_reklamacji (text)", "5. data_weryfikacji__reklamacja (date)", "6. data_zakonczenia__reklamacja (date)",
                    "7. data_produkcji_silownika__reklamacja (date)", "8. typ_cylindra__reklamacja (text)", "9. zlecenie__reklamacja (text)",
                    "10. status__reklamacja (checkbox)", "11. nr_protokolu__reklamacja (text)", "12. analiza_terminowosci_weryfikacji__reklamacja (number)",
                    "13. dokument_rozliczeniowy__reklamacja (text)", "14. nr_dokumentu__reklamacja (text)", "15. data_dokumentu__reklamacja (date)",
                    "16. nr_magazynu__reklamacja (text)", "17. nr_listu_przewozowego__reklamacja (text)", "18. przewoznik__reklamacja (text)",
                    "19. analiza_terminowosci_realizacji__reklamacja (number)", "20. opis_dzialania__dzialanie (list)", "21. imie_nazwisko__pracownik (list)",
                    "22. uwagi__sprawdzanie_dzialan (list)"
                ]
                # Update cached data
                st.session_state.raporty_8d_current_df = fresh_df.copy()
                st.session_state.raporty_8d_original_df = fresh_df.copy()
                st.success("Data refreshed successfully!")
            else:
                st.warning("No data available after refresh")
    
    # Display data info
    st.info(f"Total records: {len(display_df)}")

if __name__ == "__main__":
    main() 