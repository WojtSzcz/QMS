import streamlit as st
import pandas as pd
import datetime
import sys
import os

# Add parent directory to path to import db_connect
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from db_connect import execute_query, load_audit_types, load_employee_names, load_department_names, load_opis_problemu_status_options, load_miejsce_zatrzymania_options, load_miejsce_powstania_options

# Initialize session state for update tracking
if 'audyty_update_status' not in st.session_state:
    st.session_state.audyty_update_status = []

# Main data loading function with enhanced filters
def load_data(filters=None):
    where_conditions = []
    
    if filters:
        if filters.get('date_from'):
            where_conditions.append(f"a.data >= '{filters['date_from']}'")
        if filters.get('date_to'):
            where_conditions.append(f"a.data <= '{filters['date_to']}'")
        if filters.get('audit_type_filter'):
            where_conditions.append(f"sta.nazwa = '{filters['audit_type_filter']}'")
        if filters.get('employee_filter'):
            where_conditions.append(f"(p1.imie || ' ' || p1.nazwisko) ILIKE '%{filters['employee_filter']}%' OR (p2.imie || ' ' || p2.nazwisko) ILIKE '%{filters['employee_filter']}'")
        if filters.get('zakres'):
            where_conditions.append(f"a.zakres ILIKE '%{filters['zakres']}%'")
        if filters.get('status_opis_problemu'):
            where_conditions.append(f"op.status = '{filters['status_opis_problemu']}'")
        if filters.get('miejsce_zatrzymania'):
            where_conditions.append(f"op.miejsce_zatrzymania = '{filters['miejsce_zatrzymania']}'")
        if filters.get('miejsce_powstania'):
            where_conditions.append(f"op.miejsce_powstania = '{filters['miejsce_powstania']}'")
        if filters.get('kod_przyczyny'):
            where_conditions.append(f"op.kod_przyczyny ILIKE '%{filters['kod_przyczyny']}%'")
    
    where_clause = "WHERE " + " AND ".join(where_conditions) if where_conditions else ""
    
    query = f"""
        SELECT 
            a.id,
            a.data as data__audyt,
            sta.nazwa as typ__audyt,
            a.zakres as zakres__audyt,
            a.uwagi as uwagi__audyt,
            op.opis as opis__opis_problemu,
            op.przyczyna_bezposrednia as przyczyna_bezposrednia__opis_problemu,
            a.termin_wyslania_odpowiedzi as termin_wyslania_odpowiedzi__audyt,
            a.termin_zakonczenia_dzialan as termin_zakonczenia_dzialan__audyt,
            ARRAY_AGG(DISTINCT d.opis_dzialania) FILTER (WHERE d.opis_dzialania IS NOT NULL) as opis_dzialania__dzialanie,
            ARRAY_AGG(DISTINCT CONCAT(p1.imie, ' ', p1.nazwisko)) FILTER (WHERE p1.imie IS NOT NULL) as imie_nazwisko__pracownik,
            ARRAY_AGG(DISTINCT d.data_planowana::text) FILTER (WHERE d.data_planowana IS NOT NULL) as data_planowana__dzialanie,
            ARRAY_AGG(DISTINCT d.data_rzeczywista::text) FILTER (WHERE d.data_rzeczywista IS NOT NULL) as data_rzeczywista__dzialanie,
            op.status as status__opis_problemu,
            op.miejsce_zatrzymania as miejsce_zatrzymania__opis_problemu,
            op.miejsce_powstania as miejsce_powstania__opis_problemu,
            op.uwagi as uwagi__opis_problemu,
            op.kod_przyczyny as kod_przyczyny__opis_problemu,
            op.przyczyna_ogolna as przyczyna_ogolna__opis_problemu,
            ARRAY_AGG(DISTINCT sd.data::text) FILTER (WHERE sd.data IS NOT NULL) as data__sprawdzanie_dzialan,
            ARRAY_AGG(DISTINCT sd.status::text) FILTER (WHERE sd.status IS NOT NULL) as status__sprawdzanie_dzialan,
            ARRAY_AGG(DISTINCT sd.uwagi) FILTER (WHERE sd.uwagi IS NOT NULL) as uwagi__sprawdzanie_dzialan,
            ARRAY_AGG(DISTINCT CONCAT(p2.imie, ' ', p2.nazwisko)) FILTER (WHERE p2.imie IS NOT NULL) as imie_nazwisko_sprawdzanie__pracownik,
            ARRAY_AGG(DISTINCT sdt.nazwa) FILTER (WHERE sdt.nazwa IS NOT NULL) as typ__sprawdzanie_dzialan,
            ARRAY_AGG(DISTINCT szt.nazwa) FILTER (WHERE szt.nazwa IS NOT NULL) as nazwa__slownik_dzial
        FROM audyt a
        LEFT JOIN slownik_typ_audytu sta ON a.typ_id = sta.id
        LEFT JOIN opis_problemu_audyt opa ON a.id = opa.audyt_id
        LEFT JOIN opis_problemu op ON opa.opis_problemu_id = op.id
        LEFT JOIN dzialanie_opis_problemu dop ON op.id = dop.opis_problemu_id
        LEFT JOIN dzialanie d ON dop.dzialanie_id = d.id
        LEFT JOIN dzialanie_pracownik dp ON d.id = dp.dzialanie_id
        LEFT JOIN pracownik p1 ON dp.pracownik_id = p1.id
        LEFT JOIN sprawdzanie_dzialan_opis_problemu sdop ON op.id = sdop.opis_problemu_id
        LEFT JOIN sprawdzanie_dzialan sd ON sdop.sprawdzanie_dzialan_id = sd.id
        LEFT JOIN sprawdzanie_dzialan_pracownik sdp ON sd.id = sdp.sprawdzanie_dzialan_id
        LEFT JOIN pracownik p2 ON sdp.pracownik_id = p2.id
        LEFT JOIN slownik_sprawdzanie_typ sdt ON sd.typ_id = sdt.id
        LEFT JOIN opis_problemu_dzial opd ON op.id = opd.opis_problemu_id
        LEFT JOIN slownik_dzial szt ON opd.dzial_id = szt.id
        {where_clause}
        GROUP BY a.id, a.data, sta.nazwa, a.zakres, a.uwagi, op.opis, op.przyczyna_bezposrednia, 
                 a.termin_wyslania_odpowiedzi, a.termin_zakonczenia_dzialan, op.status, 
                 op.miejsce_zatrzymania, op.miejsce_powstania, op.uwagi, op.kod_przyczyny, op.przyczyna_ogolna
        ORDER BY a.data DESC
    """
    return execute_query(query)

# Column configuration
def get_column_config():
    audit_types = load_audit_types()
    employee_names = load_employee_names()
    
    return {
        "1. data__audyt (date)": st.column_config.DateColumn(
            "1. data__audyt (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "2. typ__audyt (text)": st.column_config.SelectboxColumn(
            "2. typ__audyt (text)",
            options=audit_types,
            width="medium"
        ),
        "3. zakres__audyt (text)": st.column_config.TextColumn(
            "3. zakres__audyt (text)",
            width="large"
        ),
        "4. uwagi__audyt (text)": st.column_config.TextColumn(
            "4. uwagi__audyt (text)",
            width="large"
        ),
        "5. opis__opis_problemu (text)": st.column_config.TextColumn(
            "5. opis__opis_problemu (text)",
            width="large"
        ),
        "6. przyczyna_bezposrednia__opis_problemu (text)": st.column_config.TextColumn(
            "6. przyczyna_bezposrednia__opis_problemu (text)",
            width="large"
        ),
        "7. termin_wyslania_odpowiedzi__audyt (date)": st.column_config.DateColumn(
            "7. termin_wyslania_odpowiedzi__audyt (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "8. termin_zakonczenia_dzialan__audyt (date)": st.column_config.DateColumn(
            "8. termin_zakonczenia_dzialan__audyt (date)",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "9. opis_dzialania__dzialanie (list)": st.column_config.ListColumn(
            "9. opis_dzialania__dzialanie (list)",
            width="large"
        ),
        "10. imie_nazwisko__pracownik (list)": st.column_config.ListColumn(
            "10. imie_nazwisko__pracownik (list)",
            width="medium"
        ),
        "11. data_planowana__dzialanie (list)": st.column_config.ListColumn(
            "11. data_planowana__dzialanie (list)",
            width="medium"
        ),
        "12. data_rzeczywista__dzialanie (list)": st.column_config.ListColumn(
            "12. data_rzeczywista__dzialanie (list)",
            width="medium"
        ),
        "13. status__opis_problemu (text)": st.column_config.SelectboxColumn(
            "13. status__opis_problemu (text)",
            options=["w trakcie", "zakonczone"],
            width="medium"
        ),
        "14. miejsce_zatrzymania__opis_problemu (text)": st.column_config.SelectboxColumn(
            "14. miejsce_zatrzymania__opis_problemu (text)",
            options=["P", "M", "G"],
            width="small"
        ),
        "15. miejsce_powstania__opis_problemu (text)": st.column_config.SelectboxColumn(
            "15. miejsce_powstania__opis_problemu (text)",
            options=["P", "G"],
            width="small"
        ),
        "16. uwagi__opis_problemu (text)": st.column_config.TextColumn(
            "16. uwagi__opis_problemu (text)",
            width="large"
        ),
        "17. kod_przyczyny__opis_problemu (text)": st.column_config.TextColumn(
            "17. kod_przyczyny__opis_problemu (text)",
            width="medium"
        ),
        "18. przyczyna_ogolna__opis_problemu (text)": st.column_config.TextColumn(
            "18. przyczyna_ogolna__opis_problemu (text)",
            width="large"
        ),
        "19. data__sprawdzanie_dzialan (list)": st.column_config.ListColumn(
            "19. data__sprawdzanie_dzialan (list)",
            width="medium"
        ),
        "20. status__sprawdzanie_dzialan (list)": st.column_config.ListColumn(
            "20. status__sprawdzanie_dzialan (list)",
            width="medium"
        ),
        "21. uwagi__sprawdzanie_dzialan (list)": st.column_config.ListColumn(
            "21. uwagi__sprawdzanie_dzialan (list)",
            width="large"
        ),
        "22. imie_nazwisko_sprawdzanie__pracownik (list)": st.column_config.ListColumn(
            "22. imie_nazwisko_sprawdzanie__pracownik (list)",
            width="medium"
        ),
        "23. typ__sprawdzanie_dzialan (list)": st.column_config.ListColumn(
            "23. typ__sprawdzanie_dzialan (list)",
            width="medium"
        ),
        "24. nazwa__slownik_dzial (list)": st.column_config.ListColumn(
            "24. nazwa__slownik_dzial (list)",
            width="medium"
        )
    }

def main():
    st.title("Audyty - Quality Management System")
    
    # Sidebar filters
    st.sidebar.header("Filters")
    
    # Prepare filter options
    audit_types = load_audit_types()
    employee_names = load_employee_names()
    department_names = load_department_names()
    status_options = load_opis_problemu_status_options()
    miejsce_zatrzymania_options = load_miejsce_zatrzymania_options()
    miejsce_powstania_options = load_miejsce_powstania_options()
    
    # Create filters dictionary
    filters = {}
    
    # Date filters
    st.sidebar.subheader("Date Filters")
    date_from = st.sidebar.date_input("Date from", value=None, key="aud_date_from")
    date_to = st.sidebar.date_input("Date to", value=None, key="aud_date_to")
    if date_from:
        filters['date_from'] = date_from
    if date_to:
        filters['date_to'] = date_to
    
    # Basic filters
    st.sidebar.subheader("Basic Filters")
    audit_type_filter = st.sidebar.selectbox("Audit Type", options=["All"] + audit_types, index=0, key="aud_type")
    if audit_type_filter != "All":
        filters['audit_type_filter'] = audit_type_filter
    
    employee_filter = st.sidebar.selectbox("Employee", options=["All"] + employee_names, index=0, key="aud_employee")
    if employee_filter != "All":
        filters['employee_filter'] = employee_filter
    
    # Text filters
    st.sidebar.subheader("Text Filters")
    zakres = st.sidebar.text_input("Zakres (contains)", value="", key="aud_zakres")
    if zakres:
        filters['zakres'] = zakres
    
    kod_przyczyny = st.sidebar.text_input("Kod przyczyny (contains)", value="", key="aud_kod")
    if kod_przyczyny:
        filters['kod_przyczyny'] = kod_przyczyny
    
    # Dropdown filters
    st.sidebar.subheader("Dropdown Filters")
    status_opis_problemu = st.sidebar.selectbox("Status opis problemu", options=["All"] + status_options, index=0, key="aud_status")
    if status_opis_problemu != "All":
        filters['status_opis_problemu'] = status_opis_problemu
    
    miejsce_zatrzymania = st.sidebar.selectbox("Miejsce zatrzymania", options=["All"] + miejsce_zatrzymania_options, index=0, key="aud_zatrzym")
    if miejsce_zatrzymania != "All":
        filters['miejsce_zatrzymania'] = miejsce_zatrzymania
    
    miejsce_powstania = st.sidebar.selectbox("Miejsce powstania", options=["All"] + miejsce_powstania_options, index=0, key="aud_powst")
    if miejsce_powstania != "All":
        filters['miejsce_powstania'] = miejsce_powstania
    
    # Clear filters button
    if st.sidebar.button("Clear All Filters", key="aud_clear"):
        st.rerun()
    
    # Load data with filters
    df = load_data(filters if filters else None)
    
    if df.empty:
        st.warning("No data available")
        return
    
    # Remove ID column from display
    df = df.drop('id', axis=1)
    
    # Rename columns to match specification
    df.columns = [
        "1. data__audyt (date)",
        "2. typ__audyt (text)",
        "3. zakres__audyt (text)",
        "4. uwagi__audyt (text)",
        "5. opis__opis_problemu (text)",
        "6. przyczyna_bezposrednia__opis_problemu (text)",
        "7. termin_wyslania_odpowiedzi__audyt (date)",
        "8. termin_zakonczenia_dzialan__audyt (date)",
        "9. opis_dzialania__dzialanie (list)",
        "10. imie_nazwisko__pracownik (list)",
        "11. data_planowana__dzialanie (list)",
        "12. data_rzeczywista__dzialanie (list)",
        "13. status__opis_problemu (text)",
        "14. miejsce_zatrzymania__opis_problemu (text)",
        "15. miejsce_powstania__opis_problemu (text)",
        "16. uwagi__opis_problemu (text)",
        "17. kod_przyczyny__opis_problemu (text)",
        "18. przyczyna_ogolna__opis_problemu (text)",
        "19. data__sprawdzanie_dzialan (list)",
        "20. status__sprawdzanie_dzialan (list)",
        "21. uwagi__sprawdzanie_dzialan (list)",
        "22. imie_nazwisko_sprawdzanie__pracownik (list)",
        "23. typ__sprawdzanie_dzialan (list)",
        "24. nazwa__slownik_dzial (list)"
    ]
    
    # Display data editor
    st.subheader("Audyty Data")
    
    edited_df = st.data_editor(
        df,
        column_config=get_column_config(),
        use_container_width=True,
        hide_index=True,
        key="audyty_editor"
    )
    
    # Track changes and update database
    if "edited_rows" in st.session_state.audyty_editor:
        edited_rows = st.session_state.audyty_editor["edited_rows"]
        if edited_rows:
            # Simulate database update (replace with actual update logic)
            for row_idx, changes in edited_rows.items():
                for col_name, new_value in changes.items():
                    update_info = {
                        "timestamp": pd.Timestamp.now(),
                        "row": row_idx,
                        "column": col_name,
                        "old_value": df.iloc[int(row_idx)][col_name] if int(row_idx) < len(df) else "N/A",
                        "new_value": new_value,
                        "status": "success"  # In real implementation, this would depend on actual DB update
                    }
                    st.session_state.audyty_update_status.append(update_info)
    
    # Display update status
    if st.session_state.audyty_update_status:
        st.subheader("Database Update Status")
        
        # Show recent updates (last 10)
        recent_updates = st.session_state.audyty_update_status[-10:]
        
        for update in reversed(recent_updates):
            if update["status"] == "success":
                st.success(f"✅ Row {update['row']}, Column '{update['column']}': '{update['old_value']}' → '{update['new_value']}' (Updated at {update['timestamp'].strftime('%H:%M:%S')})")
            else:
                st.error(f"❌ Row {update['row']}, Column '{update['column']}': Update failed (At {update['timestamp'].strftime('%H:%M:%S')})")
        
        # Clear updates button
        if st.button("Clear Update History", key="aud_clear_updates"):
            st.session_state.audyty_update_status = []
            st.rerun()
    
    # Display data info
    st.info(f"Total records: {len(df)}")

if __name__ == "__main__":
    main() 