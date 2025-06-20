import streamlit as st
import pandas as pd
import datetime
import sys
import os

# Add parent directory to path to import db_connect
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from db_connect import execute_query, load_employee_names, load_department_names, update_database_cell, load_opis_problemu_status_options, load_miejsce_zatrzymania_options, load_miejsce_powstania_options, load_firma_names, load_dokument_rozliczeniowy_options

# Session state initialization moved to main() function

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
                
        elif 'dzialanie' in column_parts:
            # Handle dzialanie table updates
            if pd.isna(opis_problemu_id):
                return False, "No opis_problemu record found for this reklamacja"
            
            # Determine which dzialanie record to update (1st or 2nd)
            dzialanie_order = 1
            if any(x in column_parts for x in ['data_planowana__dzialanie2', 'uwagi__dzialanie2', 'data_rzeczywista__dzialanie']):
                dzialanie_order = 2
            
            # Get the dzialanie ID
            dzialanie_query = f"""
                SELECT d.id as dzialanie_id
                FROM dzialanie_opis_problemu dop
                LEFT JOIN dzialanie d ON dop.dzialanie_id = d.id
                WHERE dop.opis_problemu_id = {opis_problemu_id}
                ORDER BY d.id
                LIMIT 1 OFFSET {dzialanie_order - 1}
            """
            
            dzialanie_result = execute_query(dzialanie_query)
            if dzialanie_result.empty:
                return False, f"No dzialanie record #{dzialanie_order} found for this opis_problemu"
            
            table_name = 'dzialanie'
            record_id = dzialanie_result.iloc[0]['dzialanie_id']
            
            if 'data_planowana__dzialanie' in column_parts:
                field_name = 'data_planowana'
            elif 'opis_dzialania__dzialanie' in column_parts:
                field_name = 'opis_dzialania'
            elif 'uwagi__dzialanie' in column_parts:
                field_name = 'uwagi'
            elif 'data_rzeczywista__dzialanie' in column_parts:
                field_name = 'data_rzeczywista'
            else:
                return False, f"Unknown dzialanie field: {column_parts}"
                
        elif 'sprawdzenie_dzialan' in column_parts:
            # Handle sprawdzenie_dzialan table updates
            if pd.isna(opis_problemu_id):
                return False, "No opis_problemu record found for this reklamacja"
            
            # Determine which sprawdzenie record to update (1st or 2nd)
            sprawdzenie_order = 1
            if any(x in column_parts for x in ['data__sprawdzenie_dzialan2', 'status__sprawdzenie_dzialan2', 'uwagi__sprawdzenie_dzialan2']):
                sprawdzenie_order = 2
            
            # Get the sprawdzenie_dzialan ID
            sprawdzenie_query = f"""
                SELECT sd.id as sprawdzenie_id
                FROM sprawdzanie_dzialan_opis_problemu sdop
                LEFT JOIN sprawdzanie_dzialan sd ON sdop.sprawdzanie_dzialan_id = sd.id
                WHERE sdop.opis_problemu_id = {opis_problemu_id}
                ORDER BY sd.id
                LIMIT 1 OFFSET {sprawdzenie_order - 1}
            """
            
            sprawdzenie_result = execute_query(sprawdzenie_query)
            if sprawdzenie_result.empty:
                return False, f"No sprawdzenie_dzialan record #{sprawdzenie_order} found for this opis_problemu"
            
            table_name = 'sprawdzanie_dzialan'
            record_id = sprawdzenie_result.iloc[0]['sprawdzenie_id']
            
            if 'data__sprawdzenie_dzialan' in column_parts:
                field_name = 'data'
            elif 'status__sprawdzenie_dzialan' in column_parts:
                field_name = 'status'
                # Convert text status back to boolean for database
                if new_value == 'wykonane':
                    new_value = True
                elif new_value == 'niewykonane':
                    new_value = False
                else:  # 'w trakcie' or any other value
                    new_value = None
            elif 'uwagi__sprawdzenie_dzialan' in column_parts:
                field_name = 'uwagi'
            else:
                return False, f"Unknown sprawdzenie_dzialan field: {column_parts}"
                
        elif 'detal' in column_parts:
            # Handle detal table updates
            detal_query = f"""
                SELECT dt.id as detal_id
                FROM reklamacja_detal rd
                LEFT JOIN detal dt ON rd.detal_id = dt.id
                WHERE rd.reklamacja_id = {reklamacja_id}
                ORDER BY dt.id
                LIMIT 1
            """
            
            detal_result = execute_query(detal_query)
            if detal_result.empty:
                return False, "No detal record found for this reklamacja"
            
            table_name = 'detal'
            record_id = detal_result.iloc[0]['detal_id']
            
            if 'kod__detal' in column_parts:
                field_name = 'kod'
            elif 'nazwa_wyrobu__detal' in column_parts:
                field_name = 'nazwa_wyrobu'
            elif 'oznaczenie__detal' in column_parts:
                field_name = 'oznaczenie'
            elif 'ilosc_zlecenie__detal' in column_parts:
                field_name = 'ilosc_zlecenie'
            elif 'ilosc_niezgodna__detal' in column_parts:
                field_name = 'ilosc_niezgodna'
            else:
                return False, f"Unknown detal field: {column_parts}"
                
        else:
            # For other tables like firma, slownik_dzial, pracownik, we can't easily update
            return False, f"Updates to {column_parts} not supported (read-only or complex relationships)"
        
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
            where_conditions.append(f"sdzial.nazwa = '{filters['department_filter']}'")
        if filters.get('employee_filter'):
            where_conditions.append(f"(p1.imie || ' ' || p1.nazwisko) ILIKE '%{filters['employee_filter']}%' OR (p2.imie || ' ' || p2.nazwisko) ILIKE '%{filters['employee_filter']}%' OR (p3.imie || ' ' || p3.nazwisko) ILIKE '%{filters['employee_filter']}%'")
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
    
    # Optimized query with subqueries for better performance
    query = f"""
        WITH base_data AS (
            SELECT DISTINCT
                r.id,
                r.data_otwarcia,
                f.nazwa as firma_nazwa,
                dt.kod as detal_kod,
                r.zlecenie,
                dt.nazwa_wyrobu,
                dt.oznaczenie as detal_oznaczenie,
                dt.ilosc_zlecenie,
                dt.ilosc_niezgodna,
                op.id as opis_problemu_id,
                op.status as op_status,
                op.miejsce_zatrzymania,
                op.miejsce_powstania,
                op.opis,
                op.przyczyna_bezposrednia,
                sdzial.nazwa as dzial_nazwa
            FROM reklamacja r
            LEFT JOIN firma f ON r.firma_id = f.id
            LEFT JOIN reklamacja_detal rd ON r.id = rd.reklamacja_id
            LEFT JOIN detal dt ON rd.detal_id = dt.id
            LEFT JOIN opis_problemu_reklamacja opr ON r.id = opr.reklamacja_id
            LEFT JOIN opis_problemu op ON opr.opis_problemu_id = op.id
            LEFT JOIN opis_problemu_dzial opd ON op.id = opd.opis_problemu_id
            LEFT JOIN slownik_dzial sdzial ON opd.dzial_id = sdzial.id
            {where_clause}
        ),
        dzialanie_data AS (
            SELECT 
                op_id,
                MAX(CASE WHEN rn = 1 THEN data_planowana END) as data_planowana_1,
                MAX(CASE WHEN rn = 1 THEN opis_dzialania END) as opis_dzialania_1,
                MAX(CASE WHEN rn = 1 THEN uwagi END) as uwagi_1,
                MAX(CASE WHEN rn = 1 THEN pracownik_name END) as pracownik_1,
                MAX(CASE WHEN rn = 2 THEN data_planowana END) as data_planowana_2,
                MAX(CASE WHEN rn = 2 THEN uwagi END) as uwagi_2,
                MAX(CASE WHEN rn = 2 THEN data_rzeczywista END) as data_rzeczywista_2,
                MAX(CASE WHEN rn = 2 THEN pracownik_name END) as pracownik_2
            FROM (
                SELECT 
                    op.id as op_id,
                    d.data_planowana,
                    d.opis_dzialania,
                    d.uwagi,
                    d.data_rzeczywista,
                    COALESCE(p.imie || ' ' || p.nazwisko, '') as pracownik_name,
                    ROW_NUMBER() OVER (PARTITION BY op.id ORDER BY d.id) as rn
                FROM opis_problemu op
                LEFT JOIN dzialanie_opis_problemu dop ON op.id = dop.opis_problemu_id
                LEFT JOIN dzialanie d ON dop.dzialanie_id = d.id
                LEFT JOIN dzialanie_pracownik dp ON d.id = dp.dzialanie_id
                LEFT JOIN pracownik p ON dp.pracownik_id = p.id
            ) ranked_dzialanie
            GROUP BY op_id
        ),
        sprawdzenie_data AS (
            SELECT 
                op_id,
                MAX(CASE WHEN rn = 1 THEN data END) as data_sprawdzenie_1,
                MAX(CASE WHEN rn = 1 THEN 
                    CASE 
                        WHEN status = true THEN 'wykonane'
                        WHEN status = false THEN 'niewykonane'
                        ELSE 'w trakcie'
                    END 
                END) as status_sprawdzenie_1,
                MAX(CASE WHEN rn = 1 THEN uwagi END) as uwagi_sprawdzenie_1,
                MAX(CASE WHEN rn = 1 THEN pracownik_name END) as pracownik_sprawdzenie_1,
                MAX(CASE WHEN rn = 2 THEN data END) as data_sprawdzenie_2,
                MAX(CASE WHEN rn = 2 THEN 
                    CASE 
                        WHEN status = true THEN 'wykonane'
                        WHEN status = false THEN 'niewykonane'
                        ELSE 'w trakcie'
                    END 
                END) as status_sprawdzenie_2,
                MAX(CASE WHEN rn = 2 THEN uwagi END) as uwagi_sprawdzenie_2
            FROM (
                SELECT 
                    op.id as op_id,
                    sd.data,
                    sd.status,
                    sd.uwagi,
                    COALESCE(p.imie || ' ' || p.nazwisko, '') as pracownik_name,
                    ROW_NUMBER() OVER (PARTITION BY op.id ORDER BY sd.id) as rn
                FROM opis_problemu op
                LEFT JOIN sprawdzanie_dzialan_opis_problemu sdop ON op.id = sdop.opis_problemu_id
                LEFT JOIN sprawdzanie_dzialan sd ON sdop.sprawdzanie_dzialan_id = sd.id
                LEFT JOIN sprawdzanie_dzialan_pracownik sdp ON sd.id = sdp.sprawdzanie_dzialan_id
                LEFT JOIN pracownik p ON sdp.pracownik_id = p.id
            ) ranked_sprawdzenie
            GROUP BY op_id
        )
        SELECT 
            bd.id,
            bd.data_otwarcia as data_otwarcia__reklamacja,
            bd.firma_nazwa as nazwa__firma,
            bd.detal_kod as kod__detal,
            bd.zlecenie as zlecenie__reklamacja,
            bd.nazwa_wyrobu as nazwa_wyrobu__detal,
            bd.detal_oznaczenie as oznaczenie__detal,
            bd.ilosc_zlecenie as ilosc_zlecenie__detal,
            bd.ilosc_niezgodna as ilosc_niezgodna__detal,
            bd.op_status as status__opis_problemu,
            bd.miejsce_zatrzymania as miejsce_zatrzymania__opis_problemu,
            bd.miejsce_powstania as miejsce_powstania__opis_problemu,
            bd.opis as opis__opis_problemu,
            bd.przyczyna_bezposrednia as przyczyna_bezposrednia__opis_problemu,
            dd.data_planowana_1 as data_planowana__dzialanie,
            dd.opis_dzialania_1 as opis_dzialania__dzialanie,
            dd.uwagi_1 as uwagi__dzialanie,
            dd.pracownik_1 as imie_nazwisko__pracownik,
            dd.data_planowana_2 as data_planowana__dzialanie2,
            dd.uwagi_2 as uwagi__dzialanie2,
            dd.data_rzeczywista_2 as data_rzeczywista__dzialanie,
            dd.pracownik_2 as imie_nazwisko__pracownik2,
            sd.data_sprawdzenie_1 as data__sprawdzenie_dzialan,
            sd.status_sprawdzenie_1 as status__sprawdzenie_dzialan,
            sd.uwagi_sprawdzenie_1 as uwagi__sprawdzenie_dzialan,
            sd.pracownik_sprawdzenie_1 as imie_nazwisko__pracownik3,
            sd.data_sprawdzenie_2 as data__sprawdzenie_dzialan2,
            sd.status_sprawdzenie_2 as status__sprawdzenie_dzialan2,
            sd.uwagi_sprawdzenie_2 as uwagi__sprawdzenie_dzialan2,
            bd.dzial_nazwa as nazwa__slownik_dzial
        FROM base_data bd
        LEFT JOIN dzialanie_data dd ON bd.opis_problemu_id = dd.op_id
        LEFT JOIN sprawdzenie_data sd ON bd.opis_problemu_id = sd.op_id
        ORDER BY bd.data_otwarcia DESC
    """
    return execute_query(query)

# Column configuration
def get_column_config():
    employee_names = load_employee_names()
    department_names = load_department_names()
    
    return {
        "1. data_otwarcia__reklamacja": st.column_config.DateColumn(
            "1. data_otwarcia__reklamacja",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "2. nazwa__firma": st.column_config.TextColumn(
            "2. nazwa__firma",
            width="medium"
        ),
        "3. kod__detal": st.column_config.TextColumn(
            "3. kod__detal",
            width="medium"
        ),
        "4. zlecenie__reklamacja": st.column_config.TextColumn(
            "4. zlecenie__reklamacja",
            width="medium"
        ),
        "5. nazwa_wyrobu__detal": st.column_config.TextColumn(
            "5. nazwa_wyrobu__detal",
            width="large"
        ),
        "6. oznaczenie__detal": st.column_config.TextColumn(
            "6. oznaczenie__detal",
            width="medium"
        ),
        "7. ilosc_zlecenie__detal": st.column_config.NumberColumn(
            "7. ilosc_zlecenie__detal",
            width="small"
        ),
        "8. ilosc_niezgodna__detal": st.column_config.NumberColumn(
            "8. ilosc_niezgodna__detal",
            width="small"
        ),
        "9. status__opis_problemu": st.column_config.SelectboxColumn(
            "9. status__opis_problemu",
            options=["w trakcie", "zakonczone"],
            width="medium"
        ),
        "10. miejsce_zatrzymania__opis_problemu": st.column_config.SelectboxColumn(
            "10. miejsce_zatrzymania__opis_problemu",
            options=["P", "M", "G"],
            width="small"
        ),
        "11. miejsce_powstania__opis_problemu": st.column_config.SelectboxColumn(
            "11. miejsce_powstania__opis_problemu",
            options=["P", "G"],
            width="small"
        ),
        "12. opis__opis_problemu": st.column_config.TextColumn(
            "12. opis__opis_problemu",
            width="large"
        ),
        "13. przyczyna_bezposrednia__opis_problemu": st.column_config.TextColumn(
            "13. przyczyna_bezposrednia__opis_problemu",
            width="large"
        ),
        "14. data_planowana__dzialanie": st.column_config.DateColumn(
            "14. data_planowana__dzialanie",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "15. opis_dzialania__dzialanie": st.column_config.TextColumn(
            "15. opis_dzialania__dzialanie",
            width="large"
        ),
        "16. uwagi__dzialanie": st.column_config.TextColumn(
            "16. uwagi__dzialanie",
            width="large"
        ),
        "17. imie_nazwisko__pracownik": st.column_config.TextColumn(
            "17. imie_nazwisko__pracownik",
            width="medium"
        ),
        "18. data_planowana__dzialanie": st.column_config.DateColumn(
            "18. data_planowana__dzialanie",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "19. uwagi__dzialanie": st.column_config.TextColumn(
            "19. uwagi__dzialanie",
            width="large"
        ),
        "20. data_rzeczywista__dzialanie": st.column_config.DateColumn(
            "20. data_rzeczywista__dzialanie",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "21. imie_nazwisko__pracownik": st.column_config.TextColumn(
            "21. imie_nazwisko__pracownik",
            width="medium"
        ),
        "22. data__sprawdzenie_dzialan": st.column_config.DateColumn(
            "22. data__sprawdzenie_dzialan",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "23. status__sprawdzenie_dzialan": st.column_config.SelectboxColumn(
            "23. status__sprawdzenie_dzialan",
            options=["wykonane", "w trakcie", "niewykonane"],
            width="medium"
        ),
        "24. uwagi__sprawdzenie_dzialan": st.column_config.TextColumn(
            "24. uwagi__sprawdzenie_dzialan",
            width="large"
        ),
        "25. imie_nazwisko__pracownik": st.column_config.TextColumn(
            "25. imie_nazwisko__pracownik",
            width="medium"
        ),
        "26. data__sprawdzenie_dzialan": st.column_config.DateColumn(
            "26. data__sprawdzenie_dzialan",
            format="YYYY-MM-DD",
            width="medium"
        ),
        "27. status__sprawdzenie_dzialan": st.column_config.SelectboxColumn(
            "27. status__sprawdzenie_dzialan",
            options=["wykonane", "w trakcie", "niewykonane"],
            width="medium"
        ),
        "28. uwagi__sprawdzenie_dzialan": st.column_config.TextColumn(
            "28. uwagi__sprawdzenie_dzialan",
            width="large"
        ),
        "29. nazwa__slownik_dzial": st.column_config.TextColumn(
            "29. nazwa__slownik_dzial",
            width="medium"
        )
    }

def main():
    st.title("Doskonalenia - Quality Management System")
    
    # Initialize session state for update tracking
    if 'doskonalenia_update_status' not in st.session_state:
        st.session_state.doskonalenia_update_status = []
    
    if 'doskonalenia_original_df' not in st.session_state:
        st.session_state.doskonalenia_original_df = None
    
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
        with st.spinner('Loading data...'):
            df = load_data(filters if filters else None)
        
        if df.empty:
            st.warning("No data available")
            return
        
        # Remove ID column from display
        df = df.drop('id', axis=1)
        
        # Rename columns to match specification
        df.columns = [
            "1. data_otwarcia__reklamacja",
            "2. nazwa__firma",
            "3. kod__detal",
            "4. zlecenie__reklamacja",
            "5. nazwa_wyrobu__detal",
            "6. oznaczenie__detal",
            "7. ilosc_zlecenie__detal",
            "8. ilosc_niezgodna__detal",
            "9. status__opis_problemu",
            "10. miejsce_zatrzymania__opis_problemu",
            "11. miejsce_powstania__opis_problemu",
            "12. opis__opis_problemu",
            "13. przyczyna_bezposrednia__opis_problemu",
            "14. data_planowana__dzialanie",
            "15. opis_dzialania__dzialanie",
            "16. uwagi__dzialanie",
            "17. imie_nazwisko__pracownik",
            "18. data_planowana__dzialanie",
            "19. uwagi__dzialanie",
            "20. data_rzeczywista__dzialanie",
            "21. imie_nazwisko__pracownik",
            "22. data__sprawdzenie_dzialan",
            "23. status__sprawdzenie_dzialan",
            "24. uwagi__sprawdzenie_dzialan",
            "25. imie_nazwisko__pracownik",
            "26. data__sprawdzenie_dzialan",
            "27. status__sprawdzenie_dzialan",
            "28. uwagi__sprawdzenie_dzialan",
            "29. nazwa__slownik_dzial"
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
            with st.spinner('Refreshing data...'):
                fresh_df = load_data(filters if filters else None)
            if not fresh_df.empty:
                # Remove ID column and rename columns
                fresh_df = fresh_df.drop('id', axis=1)
                fresh_df.columns = [
                    "1. data_otwarcia__reklamacja", "2. nazwa__firma", "3. kod__detal", "4. zlecenie__reklamacja",
                    "5. nazwa_wyrobu__detal", "6. oznaczenie__detal", "7. ilosc_zlecenie__detal", "8. ilosc_niezgodna__detal",
                    "9. status__opis_problemu", "10. miejsce_zatrzymania__opis_problemu", "11. miejsce_powstania__opis_problemu", "12. opis__opis_problemu",
                    "13. przyczyna_bezposrednia__opis_problemu", "14. data_planowana__dzialanie", "15. opis_dzialania__dzialanie", "16. uwagi__dzialanie",
                    "17. imie_nazwisko__pracownik", "18. data_planowana__dzialanie", "19. uwagi__dzialanie", "20. data_rzeczywista__dzialanie",
                    "21. imie_nazwisko__pracownik", "22. data__sprawdzenie_dzialan", "23. status__sprawdzenie_dzialan", "24. uwagi__sprawdzenie_dzialan",
                    "25. imie_nazwisko__pracownik", "26. data__sprawdzenie_dzialan", "27. status__sprawdzenie_dzialan", "28. uwagi__sprawdzenie_dzialan",
                    "29. nazwa__slownik_dzial"
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