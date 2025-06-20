import streamlit as st
import pandas as pd
import datetime
import sys
import os

# Add parent directory to path to import db_connect
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from db_connect import execute_query, load_employee_names, load_department_names, update_database_cell, load_opis_problemu_status_options, load_miejsce_zatrzymania_options, load_miejsce_powstania_options, load_firma_names, load_dokument_rozliczeniowy_options

# Initialize session state for update tracking
if 'doskonalenia_update_status' not in st.session_state:
    st.session_state.doskonalenia_update_status = []

if 'doskonalenia_original_df' not in st.session_state:
    st.session_state.doskonalenia_original_df = None

def update_doskonalenia_database(row_idx, column_name, new_value, original_df):
    """Handle database updates for doskonalenia - primarily reklamacja and opis_problemu tables"""
    try:
        # Get the reklamacja ID for this row (doskonalenia is a view of reklamacja data)
        reklamacja_id_query = f"""
            SELECT r.id as reklamacja_id, op.id as opis_problemu_id
            FROM reklamacja r
            LEFT JOIN opis_problemu_reklamacja opr ON r.id = opr.reklamacja_id
            LEFT JOIN opis_problemu op ON opr.opis_problemu_id = op.id
            ORDER BY r.data_otwarcia DESC
            LIMIT 1 OFFSET {row_idx}
        """
        
        id_result = execute_query(reklamacja_id_query)
        if id_result.empty:
            return False, "Could not find reklamacja record to update"
        
        reklamacja_id = id_result.iloc[0]['reklamacja_id']
        opis_problemu_id = id_result.iloc[0]['opis_problemu_id']
        
        # Parse column name to determine field
        column_parts = column_name.split('. ', 1)[1]  # Remove number prefix
        
        # Map columns to database fields
        if 'reklamacja' in column_parts:
            table_name = 'reklamacja'
            record_id = reklamacja_id
            
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
                
        elif 'opis_problemu' in column_parts:
            table_name = 'opis_problemu'
            record_id = opis_problemu_id
            if pd.isna(record_id):
                return False, "No opis_problemu record found for this reklamacja"
                
            if 'status__opis_problemu' in column_parts:
                field_name = 'status'
            elif 'opis__opis_problemu' in column_parts:
                field_name = 'opis'
            elif 'przyczyna_bezposrednia__opis_problemu' in column_parts:
                field_name = 'przyczyna_bezposrednia'
            elif 'miejsce_zatrzymania__opis_problemu' in column_parts:
                field_name = 'miejsce_zatrzymania'
            elif 'miejsce_powstania__opis_problemu' in column_parts:
                field_name = 'miejsce_powstania'
            elif 'uwagi__opis_problemu' in column_parts:
                field_name = 'uwagi'
            elif 'kod_przyczyny__opis_problemu' in column_parts:
                field_name = 'kod_przyczyny'
            elif 'przyczyna_ogolna__opis_problemu' in column_parts:
                field_name = 'przyczyna_ogolna'
            else:
                return False, f"Unknown opis_problemu field: {column_parts}"
        else:
            # For other tables like firma, slownik_typ_reklamacji, we can't easily update
            return False, f"Updates to {column_parts} not supported (complex relationships)"
        
        # Perform the database update
        success, message = update_database_cell(table_name, field_name, record_id, new_value)
        return success, message
        
    except Exception as e:
        return False, f"Error in update_doskonalenia_database: {str(e)}"

# Main data loading function with enhanced filters
def load_data(filters=None):
    where_conditions = []
    
    if filters:
        if filters.get('date_from'):
            where_conditions.append(f"r.data_otwarcia >= '{filters['date_from']}'")
        if filters.get('date_to'):
            where_conditions.append(f"r.data_otwarcia <= '{filters['date_to']}'")
        if filters.get('status_filter'):
            where_conditions.append(f"op.status = '{filters['status_filter']}'")
        if filters.get('department_filter'):
            where_conditions.append(f"sd.nazwa = '{filters['department_filter']}'")
        if filters.get('employee_filter'):
            where_conditions.append(f"(p1.imie || ' ' || p1.nazwisko) ILIKE '%{filters['employee_filter']}%'")
        if filters.get('company_filter'):
            where_conditions.append(f"f.nazwa = '{filters['company_filter']}'")
        if filters.get('nr_reklamacji'):
            where_conditions.append(f"r.nr_reklamacji ILIKE '%{filters['nr_reklamacji']}%'")
        if filters.get('typ_cylindra'):
            where_conditions.append(f"r.typ_cylindra ILIKE '%{filters['typ_cylindra']}%'")
        if filters.get('zlecenie'):
            where_conditions.append(f"r.zlecenie ILIKE '%{filters['zlecenie']}%'")
        if filters.get('kod_przyczyny'):
            where_conditions.append(f"op.kod_przyczyny ILIKE '%{filters['kod_przyczyny']}%'")
        if filters.get('dokument_rozliczeniowy'):
            where_conditions.append(f"r.dokument_rozliczeniowy = '{filters['dokument_rozliczeniowy']}'")
        if filters.get('miejsce_zatrzymania'):
            where_conditions.append(f"op.miejsce_zatrzymania = '{filters['miejsce_zatrzymania']}'")
        if filters.get('miejsce_powstania'):
            where_conditions.append(f"op.miejsce_powstania = '{filters['miejsce_powstania']}'")
    
    where_clause = "WHERE " + " AND ".join(where_conditions) if where_conditions else ""
    
    query = f"""
        SELECT 
            r.id,
            r.data_otwarcia as data_otwarcia__reklamacja,
            op.status as status__opis_problemu,
            op.opis as opis__opis_problemu,
            op.przyczyna_bezposrednia as przyczyna_bezposrednia__opis_problemu,
            op.miejsce_zatrzymania as miejsce_zatrzymania__opis_problemu,
            op.miejsce_powstania as miejsce_powstania__opis_problemu,
            op.uwagi as uwagi__opis_problemu,
            op.kod_przyczyny as kod_przyczyny__opis_problemu,
            op.przyczyna_ogolna as przyczyna_ogolna__opis_problemu,
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
            ARRAY_AGG(DISTINCT CONCAT(p1.imie, ' ', p1.nazwisko)) FILTER (WHERE p1.imie IS NOT NULL) as imie_nazwisko__pracownik,
            ARRAY_AGG(DISTINCT sd.nazwa) FILTER (WHERE sd.nazwa IS NOT NULL) as nazwa__slownik_dzial
        FROM reklamacja r
        LEFT JOIN firma f ON r.firma_id = f.id
        LEFT JOIN slownik_typ_reklamacji str ON r.typ_id = str.id
        LEFT JOIN opis_problemu_reklamacja opr ON r.id = opr.reklamacja_id
        LEFT JOIN opis_problemu op ON opr.opis_problemu_id = op.id
        LEFT JOIN opis_problemu_dzial opd ON op.id = opd.opis_problemu_id
        LEFT JOIN slownik_dzial sd ON opd.dzial_id = sd.id
        LEFT JOIN pracownik p1 ON p1.dzial_id = sd.id
        LEFT JOIN dzialanie_opis_problemu dop1 ON op.id = dop1.opis_problemu_id
        LEFT JOIN dzialanie d1 ON dop1.dzialanie_id = d1.id
        LEFT JOIN dzialanie_pracownik dp1 ON d1.id = dp1.dzialanie_id
        LEFT JOIN sprawdzanie_dzialan_opis_problemu sdop1 ON op.id = sdop1.opis_problemu_id
        LEFT JOIN sprawdzanie_dzialan sd1 ON sdop1.sprawdzanie_dzialan_id = sd1.id
        LEFT JOIN sprawdzanie_dzialan_pracownik sdp1 ON sd1.id = sdp1.sprawdzanie_dzialan_id
        {where_clause}
        GROUP BY r.id, r.data_otwarcia, op.status, op.opis, op.przyczyna_bezposrednia, op.miejsce_zatrzymania,
                 op.miejsce_powstania, op.uwagi, op.kod_przyczyny, op.przyczyna_ogolna, f.nazwa, r.nr_reklamacji,
                 str.nazwa, r.data_weryfikacji, r."data_zakończenia", r.data_produkcji_silownika, r.typ_cylindra,
                 r.zlecenie, r.status, r.nr_protokolu, r.analiza_terminowosci_weryfikacji, r.dokument_rozliczeniowy,
                 r.nr_dokumentu, r.data_dokumentu, r.nr_magazynu, r.nr_listu_przewozowego, r.przewoznik,
                 r.analiza_terminowosci_realizacji
        ORDER BY r.data_otwarcia DESC
    """
    return execute_query(query)

# Column configuration
def get_column_config():
    employee_names = load_employee_names()
    department_names = load_department_names()
    
    return {
        "1. data_otwarcia__reklamacja (date)": st.column_config.DateColumn(
            "1. data_otwarcia__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "2. status__opis_problemu (text)": st.column_config.SelectboxColumn(
            "2. status__opis_problemu (text)",
            options=["w trakcie", "zakonczone"],
            width="medium"
        ),
        "3. opis__opis_problemu (text)": st.column_config.TextColumn(
            "3. opis__opis_problemu (text)",
            width="large"
        ),
        "4. przyczyna_bezposrednia__opis_problemu (text)": st.column_config.TextColumn(
            "4. przyczyna_bezposrednia__opis_problemu (text)",
            width="large"
        ),
        "5. miejsce_zatrzymania__opis_problemu (text)": st.column_config.SelectboxColumn(
            "5. miejsce_zatrzymania__opis_problemu (text)",
            options=["P", "M", "G"],
            width="small"
        ),
        "6. miejsce_powstania__opis_problemu (text)": st.column_config.SelectboxColumn(
            "6. miejsce_powstania__opis_problemu (text)",
            options=["P", "G"],
            width="small"
        ),
        "7. uwagi__opis_problemu (text)": st.column_config.TextColumn(
            "7. uwagi__opis_problemu (text)",
            width="large"
        ),
        "8. kod_przyczyny__opis_problemu (text)": st.column_config.TextColumn(
            "8. kod_przyczyny__opis_problemu (text)",
            width="medium"
        ),
        "9. przyczyna_ogolna__opis_problemu (text)": st.column_config.TextColumn(
            "9. przyczyna_ogolna__opis_problemu (text)",
            width="large"
        ),
        "10. nazwa__firma (text)": st.column_config.TextColumn(
            "10. nazwa__firma (text)",
            width="medium"
        ),
        "11. nr_reklamacji__reklamacja (text)": st.column_config.TextColumn(
            "11. nr_reklamacji__reklamacja (text)",
            width="medium"
        ),
        "12. typ__slownik_typ_reklamacji (text)": st.column_config.TextColumn(
            "12. typ__slownik_typ_reklamacji (text)",
            width="medium"
        ),
        "13. data_weryfikacji__reklamacja (date)": st.column_config.DateColumn(
            "13. data_weryfikacji__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "14. data_zakonczenia__reklamacja (date)": st.column_config.DateColumn(
            "14. data_zakonczenia__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "15. data_produkcji_silownika__reklamacja (date)": st.column_config.DateColumn(
            "15. data_produkcji_silownika__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "16. typ_cylindra__reklamacja (text)": st.column_config.TextColumn(
            "16. typ_cylindra__reklamacja (text)",
            width="medium"
        ),
        "17. zlecenie__reklamacja (text)": st.column_config.TextColumn(
            "17. zlecenie__reklamacja (text)",
            width="medium"
        ),
        "18. status__reklamacja (checkbox)": st.column_config.CheckboxColumn(
            "18. status__reklamacja (checkbox)",
            width="small"
        ),
        "19. nr_protokolu__reklamacja (text)": st.column_config.TextColumn(
            "19. nr_protokolu__reklamacja (text)",
            width="medium"
        ),
        "20. analiza_terminowosci_weryfikacji__reklamacja (number)": st.column_config.NumberColumn(
            "20. analiza_terminowosci_weryfikacji__reklamacja (number)",
            width="medium"
        ),
        "21. dokument_rozliczeniowy__reklamacja (text)": st.column_config.SelectboxColumn(
            "21. dokument_rozliczeniowy__reklamacja (text)",
            options=["nota_korygujaca", "nota_obciazeniowa", "zwrot_towaru"],
            width="medium"
        ),
        "22. nr_dokumentu__reklamacja (text)": st.column_config.TextColumn(
            "22. nr_dokumentu__reklamacja (text)",
            width="medium"
        ),
        "23. data_dokumentu__reklamacja (date)": st.column_config.DateColumn(
            "23. data_dokumentu__reklamacja (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "24. nr_magazynu__reklamacja (text)": st.column_config.TextColumn(
            "24. nr_magazynu__reklamacja (text)",
            width="medium"
        ),
        "25. nr_listu_przewozowego__reklamacja (text)": st.column_config.TextColumn(
            "25. nr_listu_przewozowego__reklamacja (text)",
            width="medium"
        ),
        "26. przewoznik__reklamacja (text)": st.column_config.TextColumn(
            "26. przewoznik__reklamacja (text)",
            width="medium"
        ),
        "27. analiza_terminowosci_realizacji__reklamacja (number)": st.column_config.NumberColumn(
            "27. analiza_terminowosci_realizacji__reklamacja (number)",
            width="medium"
        ),
        "28. imie_nazwisko__pracownik (list)": st.column_config.ListColumn(
            "28. imie_nazwisko__pracownik (list)",
            width="medium"
        ),
        "29. nazwa__slownik_dzial (list)": st.column_config.ListColumn(
            "29. nazwa__slownik_dzial (list)",
            width="medium"
        )
    }

def main():
    st.title("Doskonalenia - Quality Management System")
    
    # Sidebar filters
    st.sidebar.header("Filters")
    
    # Prepare filter options
    department_names = load_department_names()
    employee_names = load_employee_names()
    firma_names = load_firma_names()
    status_options = load_opis_problemu_status_options()
    dokument_options = load_dokument_rozliczeniowy_options()
    miejsce_zatrzymania_options = load_miejsce_zatrzymania_options()
    miejsce_powstania_options = load_miejsce_powstania_options()
    
    # Create filters dictionary
    filters = {}
    
    # Date filters
    st.sidebar.subheader("Date Filters")
    date_from = st.sidebar.date_input("Date from", value=None, key="dosk_date_from")
    date_to = st.sidebar.date_input("Date to", value=None, key="dosk_date_to")
    if date_from:
        filters['date_from'] = date_from
    if date_to:
        filters['date_to'] = date_to
    
    # Basic filters
    st.sidebar.subheader("Basic Filters")
    company_filter = st.sidebar.selectbox("Company", options=["All"] + firma_names, index=0, key="dosk_company")
    if company_filter != "All":
        filters['company_filter'] = company_filter
    
    status_filter = st.sidebar.selectbox("Problem Status", options=["All"] + status_options, index=0, key="dosk_status")
    if status_filter != "All":
        filters['status_filter'] = status_filter
    
    department_filter = st.sidebar.selectbox("Department", options=["All"] + department_names, index=0, key="dosk_dept")
    if department_filter != "All":
        filters['department_filter'] = department_filter
    
    employee_filter = st.sidebar.selectbox("Employee", options=["All"] + employee_names, index=0, key="dosk_employee")
    if employee_filter != "All":
        filters['employee_filter'] = employee_filter
    
    # Text filters
    st.sidebar.subheader("Text Filters")
    nr_reklamacji = st.sidebar.text_input("Nr reklamacji (contains)", value="", key="dosk_nr")
    if nr_reklamacji:
        filters['nr_reklamacji'] = nr_reklamacji
    
    typ_cylindra = st.sidebar.text_input("Typ cylindra (contains)", value="", key="dosk_cyl")
    if typ_cylindra:
        filters['typ_cylindra'] = typ_cylindra
    
    zlecenie = st.sidebar.text_input("Zlecenie (contains)", value="", key="dosk_zlec")
    if zlecenie:
        filters['zlecenie'] = zlecenie
    
    kod_przyczyny = st.sidebar.text_input("Kod przyczyny (contains)", value="", key="dosk_kod")
    if kod_przyczyny:
        filters['kod_przyczyny'] = kod_przyczyny
    
    # Dropdown filters
    st.sidebar.subheader("Dropdown Filters")
    dokument_rozliczeniowy = st.sidebar.selectbox("Dokument rozliczeniowy", options=["All"] + dokument_options, index=0, key="dosk_dok")
    if dokument_rozliczeniowy != "All":
        filters['dokument_rozliczeniowy'] = dokument_rozliczeniowy
    
    miejsce_zatrzymania = st.sidebar.selectbox("Miejsce zatrzymania", options=["All"] + miejsce_zatrzymania_options, index=0, key="dosk_zatrzym")
    if miejsce_zatrzymania != "All":
        filters['miejsce_zatrzymania'] = miejsce_zatrzymania
    
    miejsce_powstania = st.sidebar.selectbox("Miejsce powstania", options=["All"] + miejsce_powstania_options, index=0, key="dosk_powst")
    if miejsce_powstania != "All":
        filters['miejsce_powstania'] = miejsce_powstania
    
    # Clear filters button
    if st.sidebar.button("Clear All Filters", key="dosk_clear"):
        # Reset filter-related session state to clear filters
        for key in list(st.session_state.keys()):
            if key.startswith("dosk_") and key != "dosk_clear":
                del st.session_state[key]
        st.session_state.doskonalenia_filters_changed = True
        st.rerun()
    
    # Initialize session state for data management
    if 'doskonalenia_data_loaded' not in st.session_state:
        st.session_state.doskonalenia_data_loaded = False
    if 'doskonalenia_current_df' not in st.session_state:
        st.session_state.doskonalenia_current_df = None
    if 'doskonalenia_filters_changed' not in st.session_state:
        st.session_state.doskonalenia_filters_changed = False
    
    # Check if filters have changed
    current_filters = str(filters if filters else {})
    if 'doskonalenia_last_filters' not in st.session_state:
        st.session_state.doskonalenia_last_filters = ""
    
    if current_filters != st.session_state.doskonalenia_last_filters:
        st.session_state.doskonalenia_filters_changed = True
        st.session_state.doskonalenia_last_filters = current_filters
    
    # Load data only if not loaded yet or filters changed
    if not st.session_state.doskonalenia_data_loaded or st.session_state.doskonalenia_filters_changed:
        df = load_data(filters if filters else None)
        
        if df.empty:
            st.warning("No data available")
            return
        
        # Remove ID column from display
        df = df.drop('id', axis=1)
        
        # Rename columns to match specification
        df.columns = [
            "1. data_otwarcia__reklamacja (date)",
            "2. status__opis_problemu (text)",
            "3. opis__opis_problemu (text)",
            "4. przyczyna_bezposrednia__opis_problemu (text)",
            "5. miejsce_zatrzymania__opis_problemu (text)",
            "6. miejsce_powstania__opis_problemu (text)",
            "7. uwagi__opis_problemu (text)",
            "8. kod_przyczyny__opis_problemu (text)",
            "9. przyczyna_ogolna__opis_problemu (text)",
            "10. nazwa__firma (text)",
            "11. nr_reklamacji__reklamacja (text)",
            "12. typ__slownik_typ_reklamacji (text)",
            "13. data_weryfikacji__reklamacja (date)",
            "14. data_zakonczenia__reklamacja (date)",
            "15. data_produkcji_silownika__reklamacja (date)",
            "16. typ_cylindra__reklamacja (text)",
            "17. zlecenie__reklamacja (text)",
            "18. status__reklamacja (checkbox)",
            "19. nr_protokolu__reklamacja (text)",
            "20. analiza_terminowosci_weryfikacji__reklamacja (number)",
            "21. dokument_rozliczeniowy__reklamacja (text)",
            "22. nr_dokumentu__reklamacja (text)",
            "23. data_dokumentu__reklamacja (date)",
            "24. nr_magazynu__reklamacja (text)",
            "25. nr_listu_przewozowego__reklamacja (text)",
            "26. przewoznik__reklamacja (text)",
            "27. analiza_terminowosci_realizacji__reklamacja (number)",
            "28. imie_nazwisko__pracownik (list)",
            "29. nazwa__slownik_dzial (list)"
        ]
        
        # Store data in session state with renamed columns
        st.session_state.doskonalenia_current_df = df.copy()
        st.session_state.doskonalenia_data_loaded = True
        st.session_state.doskonalenia_filters_changed = False
    else:
        # Use cached data (already has renamed columns)
        df = st.session_state.doskonalenia_current_df.copy()
    
    # Display data editor
    st.subheader("Doskonalenia Data")
    
    # Always use the current cached data for display to reflect any updates
    display_df = st.session_state.doskonalenia_current_df.copy() if st.session_state.doskonalenia_current_df is not None else df
    
    # Store original data for comparison
    if 'doskonalenia_original_df' not in st.session_state:
        st.session_state.doskonalenia_original_df = None
    if st.session_state.doskonalenia_original_df is None:
        st.session_state.doskonalenia_original_df = display_df.copy()
    
    edited_df = st.data_editor(
        display_df,
        column_config=get_column_config(),
        use_container_width=True,
        hide_index=True,
        key="doskonalenia_editor"
    )
    
    # Track changes and update database (REAL)
    if "edited_rows" in st.session_state.doskonalenia_editor:
        edited_rows = st.session_state.doskonalenia_editor["edited_rows"]
        if edited_rows:
            for row_idx, changes in edited_rows.items():
                for col_name, new_value in changes.items():
                    # Get original value for comparison
                    if int(row_idx) < len(st.session_state.doskonalenia_original_df):
                        original_value = st.session_state.doskonalenia_original_df.iloc[int(row_idx)][col_name]
                        
                        # Only update if value actually changed
                        if str(new_value) != str(original_value):
                            success, message = update_doskonalenia_database(
                                int(row_idx), col_name, new_value, st.session_state.doskonalenia_original_df
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
                            st.session_state.doskonalenia_update_status.append(update_info)
                            
                            if success:
                                # Update both original and current df to reflect the change
                                st.session_state.doskonalenia_original_df.iloc[int(row_idx), 
                                    st.session_state.doskonalenia_original_df.columns.get_loc(col_name)] = new_value
                                st.session_state.doskonalenia_current_df.iloc[int(row_idx), 
                                    st.session_state.doskonalenia_current_df.columns.get_loc(col_name)] = new_value
    
    # Display update status
    if st.session_state.doskonalenia_update_status:
        st.subheader("Database Update Status")
        
        # Show recent updates (last 10)
        recent_updates = st.session_state.doskonalenia_update_status[-10:]
        
        for update in reversed(recent_updates):
            if update["status"] == "success":
                st.success(f"✅ Row {update['row']}, Column '{update['column']}': '{update['old_value']}' → '{update['new_value']}' (Updated at {update['timestamp'].strftime('%H:%M:%S')})")
            else:
                st.error(f"❌ Row {update['row']}, Column '{update['column']}': {update.get('message', 'Update failed')} (At {update['timestamp'].strftime('%H:%M:%S')})")
        
        # Clear updates button
        if st.button("Clear Update History", key="dosk_clear_updates"):
            st.session_state.doskonalenia_update_status = []
    
    # Manual refresh button
    col1, col2 = st.columns([1, 4])
    with col1:
        if st.button("🔄 Refresh Data", key="dosk_refresh"):
            # Force data refresh by reloading from database
            fresh_df = load_data(filters if filters else None)
            if not fresh_df.empty:
                # Remove ID column and rename columns
                fresh_df = fresh_df.drop('id', axis=1)
                fresh_df.columns = [
                    "1. data_otwarcia__reklamacja (date)", "2. status__opis_problemu (text)", "3. opis__opis_problemu (text)",
                    "4. przyczyna_bezposrednia__opis_problemu (text)", "5. miejsce_zatrzymania__opis_problemu (text)", "6. miejsce_powstania__opis_problemu (text)",
                    "7. uwagi__opis_problemu (text)", "8. kod_przyczyny__opis_problemu (text)", "9. przyczyna_ogolna__opis_problemu (text)",
                    "10. nazwa__firma (text)", "11. nr_reklamacji__reklamacja (text)", "12. typ__slownik_typ_reklamacji (text)",
                    "13. data_weryfikacji__reklamacja (date)", "14. data_zakonczenia__reklamacja (date)", "15. data_produkcji_silownika__reklamacja (date)",
                    "16. typ_cylindra__reklamacja (text)", "17. zlecenie__reklamacja (text)", "18. status__reklamacja (checkbox)",
                    "19. nr_protokolu__reklamacja (text)", "20. analiza_terminowosci_weryfikacji__reklamacja (number)", "21. dokument_rozliczeniowy__reklamacja (text)",
                    "22. nr_dokumentu__reklamacja (text)", "23. data_dokumentu__reklamacja (date)", "24. nr_magazynu__reklamacja (text)",
                    "25. nr_listu_przewozowego__reklamacja (text)", "26. przewoznik__reklamacja (text)", "27. analiza_terminowosci_realizacji__reklamacja (number)",
                    "28. imie_nazwisko__pracownik (list)", "29. nazwa__slownik_dzial (list)"
                ]
                # Update cached data
                st.session_state.doskonalenia_current_df = fresh_df.copy()
                st.session_state.doskonalenia_original_df = fresh_df.copy()
                st.success("Data refreshed successfully!")
            else:
                st.warning("No data available after refresh")
    
    # Display data info
    st.info(f"Total records: {len(display_df)}")

if __name__ == "__main__":
    main() 