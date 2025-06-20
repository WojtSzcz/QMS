import streamlit as st
import pandas as pd
import datetime
import sys
import os

# Add parent directory to path to import db_connect
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from db_connect import execute_query, load_firma_names, load_dokument_rozliczeniowy_options, load_opis_problemu_status_options, load_miejsce_zatrzymania_options, load_miejsce_powstania_options, update_database_cell

# Initialize session state for update tracking
if 'reklamacje_update_status' not in st.session_state:
    st.session_state.reklamacje_update_status = []

if 'reklamacje_original_df' not in st.session_state:
    st.session_state.reklamacje_original_df = None

def update_reklamacje_database(row_idx, column_name, new_value, original_df):
    """Handle database updates for reklamacje with complex relationships"""
    try:
        # Get original row data (with ID still included)
        original_row_with_id = execute_query(f"""
            SELECT r.id as reklamacja_id, dt.id as detal_id, op.id as opis_problemu_id, f.id as firma_id
            FROM reklamacja r
            LEFT JOIN firma f ON r.firma_id = f.id
            LEFT JOIN reklamacja_detal rd ON r.id = rd.reklamacja_id
            LEFT JOIN detal dt ON rd.detal_id = dt.id
            LEFT JOIN opis_problemu_reklamacja opr ON r.id = opr.reklamacja_id
            LEFT JOIN opis_problemu op ON opr.opis_problemu_id = op.id
            ORDER BY r.data_otwarcia DESC
            LIMIT 1 OFFSET {row_idx}
        """)
        
        if original_row_with_id.empty:
            return False, "Could not find record to update"
        
        row_data = original_row_with_id.iloc[0]
        
        # Parse column name to determine target table and field
        column_parts = column_name.split('. ', 1)[1]  # Remove number prefix
        
        # Map column to table and field
        if 'firma' in column_parts:
            # Special handling for company name changes - update firma_id in reklamacja table
            if 'nazwa_firma' in column_parts:
                # Get the company ID for the selected company name
                company_id_query = f"SELECT id FROM firma WHERE nazwa = '{new_value}'"
                company_result = execute_query(company_id_query)
                if company_result.empty:
                    return False, f"Company '{new_value}' not found in database"
                
                new_firma_id = company_result.iloc[0]['id']
                
                # Update the firma_id in reklamacja table
                table_name = 'reklamacja'
                record_id = row_data['reklamacja_id']
                field_name = 'firma_id'
                new_value = new_firma_id  # Use the company ID instead of the name
            else:
                # For other firma fields, update the firma table directly
                table_name = 'firma'
                record_id = row_data['firma_id']
                if 'kod_firma' in column_parts:
                    field_name = 'kod'
                elif 'oznaczenie_klienta_firma' in column_parts:
                    field_name = 'oznaczenie_klienta'
                else:
                    return False, f"Unknown firma field: {column_parts}"
                
        elif 'reklamacja' in column_parts:
            table_name = 'reklamacja'
            record_id = row_data['reklamacja_id']
            if 'nr_reklamacji_reklamacja' in column_parts:
                field_name = 'nr_reklamacji'
            elif 'nr_protokolu_reklamacja' in column_parts:
                field_name = 'nr_protokolu'
            elif 'zlecenie_reklamacja' in column_parts:
                field_name = 'zlecenie'
            elif 'data_otwarcia_reklamacja' in column_parts:
                field_name = 'data_otwarcia'
            elif 'typ_cylindra_reklamacja' in column_parts:
                field_name = 'typ_cylindra'
            elif 'data_weryfikacji_reklamacja' in column_parts:
                field_name = 'data_weryfikacji'
            elif 'analiza_terminowosci_weryfikacji' in column_parts:
                field_name = 'analiza_terminowosci_weryfikacji'
            elif 'data_produkcji_reklamacja' in column_parts:
                field_name = 'data_produkcji_silownika'
            elif 'dokument_rozliczeniowy_reklamacja' in column_parts:
                field_name = 'dokument_rozliczeniowy'
            elif 'nr_dokumentu_reklamacja' in column_parts:
                field_name = 'nr_dokumentu'
            elif 'data_dokumentu_reklamacja' in column_parts:
                field_name = 'data_dokumentu'
            elif 'nr_magazynu_reklamacja' in column_parts:
                field_name = 'nr_magazynu'
            elif 'nr_listu_przewozowego_reklamacja' in column_parts:
                field_name = 'nr_listu_przewozowego'
            elif 'przewoznik_reklamacja' in column_parts:
                field_name = 'przewoznik'
            elif 'analiza_terminowosci_realizacji' in column_parts:
                field_name = 'analiza_terminowosci_realizacji'
            else:
                return False, f"Unknown reklamacja field: {column_parts}"
                
        elif 'detal' in column_parts:
            table_name = 'detal'
            record_id = row_data['detal_id']
            if pd.isna(record_id):
                return False, "No detal record found for this reklamacja"
            if 'kod_detal' in column_parts:
                field_name = 'kod'
            elif 'oznaczenie_detal' in column_parts:
                field_name = 'oznaczenie'
            elif 'ilosc_niezgodna_detal' in column_parts:
                field_name = 'ilosc_niezgodna'
            elif 'ilosc_uznanych_detal' in column_parts:
                field_name = 'ilosc_uznanych'
            elif 'ilosc_nieuznanych_detal' in column_parts:
                field_name = 'ilosc_nieuznanych'
            elif 'ilosc_nowych_uznanych_detal' in column_parts:
                field_name = 'ilosc_nowych_uznanych'
            elif 'ilosc_nowych_nieuznanych_detal' in column_parts:
                field_name = 'ilosc_nowych_nieuznanych'
            elif 'ilosc_rozliczona_detal' in column_parts:
                field_name = 'ilosc_rozliczona'
            elif 'ilosc_nieuznanych_naprawionych_detal' in column_parts:
                field_name = 'ilosc_nieuznanych_naprawionych'
            else:
                return False, f"Unknown detal field: {column_parts}"
                
        elif 'opis_problemu' in column_parts:
            table_name = 'opis_problemu'
            record_id = row_data['opis_problemu_id']
            if pd.isna(record_id):
                return False, "No opis_problemu record found for this reklamacja"
            if 'kod_przyczyny_opis_problemu' in column_parts:
                field_name = 'kod_przyczyny'
            elif 'przyczyna_ogolna_opis_problemu' in column_parts:
                field_name = 'przyczyna_ogolna'
            elif 'przyczyna_bezposrednia_opis_problemu' in column_parts:
                field_name = 'przyczyna_bezposrednia'
            elif 'uwagi_opis_problemu' in column_parts:
                field_name = 'uwagi'
            else:
                return False, f"Unknown opis_problemu field: {column_parts}"
        else:
            return False, f"Unknown table for column: {column_parts}"
        
        # Perform the database update
        success, message = update_database_cell(table_name, field_name, record_id, new_value)
        return success, message
        
    except Exception as e:
        return False, f"Error in update_reklamacje_database: {str(e)}"

# Main data loading function with enhanced filters
def load_data(filters=None):
    where_conditions = []
    
    if filters:
        if filters.get('date_from'):
            where_conditions.append(f"r.data_otwarcia >= '{filters['date_from']}'")
        if filters.get('date_to'):
            where_conditions.append(f"r.data_otwarcia <= '{filters['date_to']}'")
        if filters.get('company_filter'):
            where_conditions.append(f"f.nazwa = '{filters['company_filter']}'")
        if filters.get('status_filter') is not None:
            where_conditions.append(f"r.status = {filters['status_filter']}")
        if filters.get('typ_reklamacji'):
            where_conditions.append(f"str.nazwa ILIKE '%{filters['typ_reklamacji']}%'")
        if filters.get('nr_reklamacji'):
            where_conditions.append(f"r.nr_reklamacji ILIKE '%{filters['nr_reklamacji']}%'")
        if filters.get('typ_cylindra'):
            where_conditions.append(f"r.typ_cylindra ILIKE '%{filters['typ_cylindra']}%'")
        if filters.get('zlecenie'):
            where_conditions.append(f"r.zlecenie ILIKE '%{filters['zlecenie']}%'")
        if filters.get('nr_protokolu'):
            where_conditions.append(f"r.nr_protokolu ILIKE '%{filters['nr_protokolu']}%'")
        if filters.get('dokument_rozliczeniowy'):
            where_conditions.append(f"r.dokument_rozliczeniowy = '{filters['dokument_rozliczeniowy']}'")
        if filters.get('przewoznik'):
            where_conditions.append(f"r.przewoznik ILIKE '%{filters['przewoznik']}%'")
    
    where_clause = "WHERE " + " AND ".join(where_conditions) if where_conditions else ""
    
    query = f"""
        SELECT 
            r.id,
            f.kod as kod_firma,
            f.nazwa as nazwa_firma,
            r.nr_reklamacji as nr_reklamacji_reklamacja,
            r.nr_protokolu as nr_protokolu_reklamacja,
            r.zlecenie as zlecenie_reklamacja,
            r.data_otwarcia as data_otwarcia_reklamacja,
            dt.kod as kod_detal,
            r.typ_cylindra as typ_cylindra_reklamacja,
            dt.oznaczenie as oznaczenie_detal,
            f.oznaczenie_klienta as oznaczenie_klienta_firma,
            dt.ilosc_niezgodna as ilosc_niezgodna_detal,
            r.data_weryfikacji as data_weryfikacji_reklamacja,
            r.analiza_terminowosci_weryfikacji as analiza_terminowosci_weryfikacji,
            r.data_produkcji_silownika as data_produkcji_reklamacja,
            op.kod_przyczyny as kod_przyczyny_opis_problemu,
            op.przyczyna_ogolna as przyczyna_ogolna_opis_problemu,
            op.przyczyna_bezposrednia as przyczyna_bezposrednia_opis_problemu,
            op.uwagi as uwagi_opis_problemu,
            dt.ilosc_uznanych as ilosc_uznanych_detal,
            dt.ilosc_nieuznanych as ilosc_nieuznanych_detal,
            dt.ilosc_nowych_uznanych as ilosc_nowych_uznanych_detal,
            dt.ilosc_nowych_nieuznanych as ilosc_nowych_nieuznanych_detal,
            dt.ilosc_rozliczona as ilosc_rozliczona_detal,
            dt.ilosc_nieuznanych_naprawionych as ilosc_nieuznanych_naprawionych_detal,
            r.dokument_rozliczeniowy as dokument_rozliczeniowy_reklamacja,
            r.nr_dokumentu as nr_dokumentu_reklamacja,
            r.data_dokumentu as data_dokumentu_reklamacja,
            r.nr_magazynu as nr_magazynu_reklamacja,
            r.nr_listu_przewozowego as nr_listu_przewozowego_reklamacja,
            r.przewoznik as przewoznik_reklamacja,
            r.analiza_terminowosci_realizacji as analiza_terminowosci_realizacji
        FROM reklamacja r
        LEFT JOIN firma f ON r.firma_id = f.id
        LEFT JOIN reklamacja_detal rd ON r.id = rd.reklamacja_id
        LEFT JOIN detal dt ON rd.detal_id = dt.id
        LEFT JOIN opis_problemu_reklamacja opr ON r.id = opr.reklamacja_id
        LEFT JOIN opis_problemu op ON opr.opis_problemu_id = op.id
        {where_clause}
        ORDER BY r.data_otwarcia DESC
    """
    return execute_query(query)

# Column configuration
def get_column_config():
    firma_names = load_firma_names()
    dokument_options = load_dokument_rozliczeniowy_options()
    
    return {
        "1. kod_firma": st.column_config.TextColumn(
            "1. kod_firma",
            width="small"
        ),
        "2. nazwa_firma": st.column_config.SelectboxColumn(
            "2. nazwa_firma",
            options=firma_names,
            width="medium"
        ),
        "3. nr_reklamacji_reklamacja": st.column_config.TextColumn(
            "3. nr_reklamacji_reklamacja",
            width="medium"
        ),
        "4. nr_protokolu_reklamacja": st.column_config.TextColumn(
            "4. nr_protokolu_reklamacja",
            width="medium"
        ),
        "5. zlecenie_reklamacja": st.column_config.TextColumn(
            "5. zlecenie_reklamacja",
            width="medium"
        ),
        "6. data_otwarcia_reklamacja": st.column_config.DateColumn(
            "6. data_otwarcia_reklamacja",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "7. kod_detal": st.column_config.TextColumn(
            "7. kod_detal",
            width="medium"
        ),
        "8. typ_cylindra_reklamacja": st.column_config.TextColumn(
            "8. typ_cylindra_reklamacja",
            width="medium"
        ),
        "9. oznaczenie_detal": st.column_config.TextColumn(
            "9. oznaczenie_detal",
            width="medium"
        ),
        "10. oznaczenie_klienta_firma": st.column_config.TextColumn(
            "10. oznaczenie_klienta_firma",
            width="medium"
        ),
        "11. ilosc_niezgodna_detal": st.column_config.NumberColumn(
            "11. ilosc_niezgodna_detal",
            width="small"
        ),
        "12. data_weryfikacji_reklamacja": st.column_config.DateColumn(
            "12. data_weryfikacji_reklamacja",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "13. analiza_terminowosci_weryfikacji": st.column_config.NumberColumn(
            "13. analiza_terminowosci_weryfikacji",
            width="medium"
        ),
        "14. data_produkcji_reklamacja": st.column_config.DateColumn(
            "14. data_produkcji_reklamacja",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "15. kod_przyczyny_opis_problemu": st.column_config.TextColumn(
            "15. kod_przyczyny_opis_problemu",
            width="medium"
        ),
        "16. przyczyna_ogolna_opis_problemu": st.column_config.TextColumn(
            "16. przyczyna_ogolna_opis_problemu",
            width="large"
        ),
        "17. przyczyna_bezposrednia_opis_problemu": st.column_config.TextColumn(
            "17. przyczyna_bezposrednia_opis_problemu",
            width="large"
        ),
        "18. uwagi_opis_problemu": st.column_config.TextColumn(
            "18. uwagi_opis_problemu",
            width="large"
        ),
        "19. ilosc_uznanych_detal": st.column_config.NumberColumn(
            "19. ilosc_uznanych_detal",
            width="small"
        ),
        "20. ilosc_nieuznanych_detal": st.column_config.NumberColumn(
            "20. ilosc_nieuznanych_detal",
            width="small"
        ),
        "21. ilosc_nowych_uznanych_detal": st.column_config.NumberColumn(
            "21. ilosc_nowych_uznanych_detal",
            width="small"
        ),
        "22. ilosc_nowych_nieuznanych_detal": st.column_config.NumberColumn(
            "22. ilosc_nowych_nieuznanych_detal",
            width="small"
        ),
        "23. ilosc_rozliczona_detal": st.column_config.NumberColumn(
            "23. ilosc_rozliczona_detal",
            width="small"
        ),
        "24. ilosc_nieuznanych_naprawionych_detal": st.column_config.NumberColumn(
            "24. ilosc_nieuznanych_naprawionych_detal",
            width="small"
        ),
        "25. dokument_rozliczeniowy_reklamacja": st.column_config.SelectboxColumn(
            "25. dokument_rozliczeniowy_reklamacja",
            options=dokument_options,
            width="medium"
        ),
        "26. nr_dokumentu_reklamacja": st.column_config.TextColumn(
            "26. nr_dokumentu_reklamacja",
            width="medium"
        ),
        "27. data_dokumentu_reklamacja": st.column_config.DateColumn(
            "27. data_dokumentu_reklamacja",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "28. nr_magazynu_reklamacja": st.column_config.TextColumn(
            "28. nr_magazynu_reklamacja",
            width="medium"
        ),
        "29. nr_listu_przewozowego_reklamacja": st.column_config.TextColumn(
            "29. nr_listu_przewozowego_reklamacja",
            width="medium"
        ),
        "30. przewoznik_reklamacja": st.column_config.TextColumn(
            "30. przewoznik_reklamacja",
            width="medium"
        ),
        "31. analiza_terminowosci_realizacji": st.column_config.NumberColumn(
            "31. analiza_terminowosci_realizacji",
            width="medium"
        )
    }

def main():
    st.title("Reklamacje - Quality Management System")
    
    # Sidebar filters
    st.sidebar.header("Filters")
    
    # Prepare filter options
    firma_names = load_firma_names()
    dokument_options = load_dokument_rozliczeniowy_options()
    
    # Create filters dictionary
    filters = {}
    
    # Date filters
    st.sidebar.subheader("Date Filters")
    date_from = st.sidebar.date_input("Date from", value=None, key="rek_date_from")
    date_to = st.sidebar.date_input("Date to", value=None, key="rek_date_to")
    if date_from:
        filters['date_from'] = date_from
    if date_to:
        filters['date_to'] = date_to
    
    # Company and basic filters
    st.sidebar.subheader("Basic Filters")
    company_filter = st.sidebar.selectbox("Company", options=["All"] + firma_names, index=0, key="rek_company")
    if company_filter != "All":
        filters['company_filter'] = company_filter
    
    status_filter = st.sidebar.selectbox("Status", options=["All", "Open", "Closed"], index=0, key="rek_status")
    if status_filter == "Open":
        filters['status_filter'] = False
    elif status_filter == "Closed":
        filters['status_filter'] = True
    
    # Text filters
    st.sidebar.subheader("Text Filters")
    typ_reklamacji = st.sidebar.text_input("Typ reklamacji (contains)", value="", key="rek_typ")
    if typ_reklamacji:
        filters['typ_reklamacji'] = typ_reklamacji
    
    nr_reklamacji = st.sidebar.text_input("Nr reklamacji (contains)", value="", key="rek_nr")
    if nr_reklamacji:
        filters['nr_reklamacji'] = nr_reklamacji
    
    typ_cylindra = st.sidebar.text_input("Typ cylindra (contains)", value="", key="rek_cyl")
    if typ_cylindra:
        filters['typ_cylindra'] = typ_cylindra
    
    zlecenie = st.sidebar.text_input("Zlecenie (contains)", value="", key="rek_zlec")
    if zlecenie:
        filters['zlecenie'] = zlecenie
    
    nr_protokolu = st.sidebar.text_input("Nr protokolu (contains)", value="", key="rek_prot")
    if nr_protokolu:
        filters['nr_protokolu'] = nr_protokolu
    
    przewoznik = st.sidebar.text_input("Przewoznik (contains)", value="", key="rek_przewoz")
    if przewoznik:
        filters['przewoznik'] = przewoznik
    
    # Dropdown filters
    st.sidebar.subheader("Dropdown Filters")
    dokument_rozliczeniowy = st.sidebar.selectbox("Dokument rozliczeniowy", options=["All"] + dokument_options, index=0, key="rek_dok")
    if dokument_rozliczeniowy != "All":
        filters['dokument_rozliczeniowy'] = dokument_rozliczeniowy
    
    # Clear filters button
    if st.sidebar.button("Clear All Filters", key="rek_clear"):
        # Reset filter-related session state to clear filters
        for key in list(st.session_state.keys()):
            if key.startswith("rek_") and key != "rek_clear":
                del st.session_state[key]
        st.session_state.reklamacje_filters_changed = True
        st.rerun()
    
    # Initialize session state for data management
    if 'reklamacje_data_loaded' not in st.session_state:
        st.session_state.reklamacje_data_loaded = False
    if 'reklamacje_current_df' not in st.session_state:
        st.session_state.reklamacje_current_df = None
    if 'reklamacje_filters_changed' not in st.session_state:
        st.session_state.reklamacje_filters_changed = False
    if 'reklamacje_update_status' not in st.session_state:
        st.session_state.reklamacje_update_status = []
    
    # Check if filters have changed
    current_filters = str(filters if filters else {})
    if 'reklamacje_last_filters' not in st.session_state:
        st.session_state.reklamacje_last_filters = ""
    
    if current_filters != st.session_state.reklamacje_last_filters:
        st.session_state.reklamacje_filters_changed = True
        st.session_state.reklamacje_last_filters = current_filters
    
    # Load data only if not loaded yet or filters changed
    if not st.session_state.reklamacje_data_loaded or st.session_state.reklamacje_filters_changed:
        df = load_data(filters if filters else None)
        
        if df.empty:
            st.warning("No data available")
            return
        
        # Remove ID column from display
        df = df.drop('id', axis=1)
        
        # Rename columns to match specification
        df.columns = [
            "1. kod_firma",
            "2. nazwa_firma",
            "3. nr_reklamacji_reklamacja",
            "4. nr_protokolu_reklamacja",
            "5. zlecenie_reklamacja",
            "6. data_otwarcia_reklamacja",
            "7. kod_detal",
            "8. typ_cylindra_reklamacja",
            "9. oznaczenie_detal",
            "10. oznaczenie_klienta_firma",
            "11. ilosc_niezgodna_detal",
            "12. data_weryfikacji_reklamacja",
            "13. analiza_terminowosci_weryfikacji",
            "14. data_produkcji_reklamacja",
            "15. kod_przyczyny_opis_problemu",
            "16. przyczyna_ogolna_opis_problemu",
            "17. przyczyna_bezposrednia_opis_problemu",
            "18. uwagi_opis_problemu",
            "19. ilosc_uznanych_detal",
            "20. ilosc_nieuznanych_detal",
            "21. ilosc_nowych_uznanych_detal",
            "22. ilosc_nowych_nieuznanych_detal",
            "23. ilosc_rozliczona_detal",
            "24. ilosc_nieuznanych_naprawionych_detal",
            "25. dokument_rozliczeniowy_reklamacja",
            "26. nr_dokumentu_reklamacja",
            "27. data_dokumentu_reklamacja",
            "28. nr_magazynu_reklamacja",
            "29. nr_listu_przewozowego_reklamacja",
            "30. przewoznik_reklamacja",
            "31. analiza_terminowosci_realizacji"
        ]
        
        # Store data in session state
        st.session_state.reklamacje_current_df = df.copy()
        st.session_state.reklamacje_data_loaded = True
        st.session_state.reklamacje_filters_changed = False
        
        # Store original data for comparison
        if 'reklamacje_original_df' not in st.session_state:
            st.session_state.reklamacje_original_df = None
        if st.session_state.reklamacje_original_df is None:
            st.session_state.reklamacje_original_df = df.copy()
    else:
        # Use cached data
        df = st.session_state.reklamacje_current_df.copy()
    
    # Display data editor
    st.subheader("Reklamacje Data")
    
    # Always use the current cached data for display to reflect any updates
    display_df = st.session_state.reklamacje_current_df.copy() if st.session_state.reklamacje_current_df is not None else df
    
    edited_df = st.data_editor(
        display_df,
        column_config=get_column_config(),
        use_container_width=True,
        hide_index=True,
        key="reklamacje_editor"
    )
    
    # Track changes and update database (REAL)
    if "edited_rows" in st.session_state.reklamacje_editor:
        edited_rows = st.session_state.reklamacje_editor["edited_rows"]
        if edited_rows:
            for row_idx, changes in edited_rows.items():
                for col_name, new_value in changes.items():
                    # Get original value for comparison
                    if int(row_idx) < len(st.session_state.reklamacje_original_df):
                        original_value = st.session_state.reklamacje_original_df.iloc[int(row_idx)][col_name]
                        
                        # Only update if value actually changed
                        if str(new_value) != str(original_value):
                            success, message = update_reklamacje_database(
                                int(row_idx), col_name, new_value, st.session_state.reklamacje_original_df
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
                            st.session_state.reklamacje_update_status.append(update_info)
                            
                            if success:
                                # Update both original and current df to reflect the change
                                st.session_state.reklamacje_original_df.iloc[int(row_idx), 
                                    st.session_state.reklamacje_original_df.columns.get_loc(col_name)] = new_value
                                st.session_state.reklamacje_current_df.iloc[int(row_idx), 
                                    st.session_state.reklamacje_current_df.columns.get_loc(col_name)] = new_value
    
    # Display update status
    if st.session_state.reklamacje_update_status:
        st.subheader("Database Update Status")
        
        # Show recent updates (last 10)
        recent_updates = st.session_state.reklamacje_update_status[-10:]
        
        for update in reversed(recent_updates):
            if update["status"] == "success":
                st.success(f"✅ Row {update['row']}, Column '{update['column']}': '{update['old_value']}' → '{update['new_value']}' (Updated at {update['timestamp'].strftime('%H:%M:%S')})")
            else:
                st.error(f"❌ Row {update['row']}, Column '{update['column']}': {update.get('message', 'Update failed')} (At {update['timestamp'].strftime('%H:%M:%S')})")
        
        # Clear updates button
        if st.button("Clear Update History", key="rek_clear_updates"):
            st.session_state.reklamacje_update_status = []
    
    # Manual refresh button
    col1, col2 = st.columns([1, 4])
    with col1:
        if st.button("🔄 Refresh Data", key="rek_refresh"):
            # Force data refresh by reloading from database
            fresh_df = load_data(filters if filters else None)
            if not fresh_df.empty:
                # Remove ID column and rename columns
                fresh_df = fresh_df.drop('id', axis=1)
                fresh_df.columns = [
                    "1. kod_firma", "2. nazwa_firma", "3. nr_reklamacji_reklamacja",
                    "4. nr_protokolu_reklamacja", "5. zlecenie_reklamacja", "6. data_otwarcia_reklamacja",
                    "7. kod_detal", "8. typ_cylindra_reklamacja", "9. oznaczenie_detal",
                    "10. oznaczenie_klienta_firma", "11. ilosc_niezgodna_detal", "12. data_weryfikacji_reklamacja",
                    "13. analiza_terminowosci_weryfikacji", "14. data_produkcji_reklamacja", "15. kod_przyczyny_opis_problemu",
                    "16. przyczyna_ogolna_opis_problemu", "17. przyczyna_bezposrednia_opis_problemu", "18. uwagi_opis_problemu",
                    "19. ilosc_uznanych_detal", "20. ilosc_nieuznanych_detal", "21. ilosc_nowych_uznanych_detal",
                    "22. ilosc_nowych_nieuznanych_detal", "23. ilosc_rozliczona_detal", "24. ilosc_nieuznanych_naprawionych_detal",
                    "25. dokument_rozliczeniowy_reklamacja", "26. nr_dokumentu_reklamacja", "27. data_dokumentu_reklamacja",
                    "28. nr_magazynu_reklamacja", "29. nr_listu_przewozowego_reklamacja", "30. przewoznik_reklamacja",
                    "31. analiza_terminowosci_realizacji"
                ]
                # Update cached data
                st.session_state.reklamacje_current_df = fresh_df.copy()
                st.session_state.reklamacje_original_df = fresh_df.copy()
                st.success("Data refreshed successfully!")
            else:
                st.warning("No data available after refresh")
    
    # Display data info
    st.info(f"Total records: {len(display_df)}")

if __name__ == "__main__":
    main() 