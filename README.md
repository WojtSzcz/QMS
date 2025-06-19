# Zehs Quality Management System

A Streamlit-based quality management application for handling complaints, improvements, 8D reports, and audits.

## Project Structure

```
Zehs_Sesja_Kasjan/
├── app.py                 # Main Streamlit application
├── Raporty/              # Reports module package
│   ├── __init__.py       # Package initialization
│   ├── reklamacje.py     # Complaints management
│   ├── doskonalenia.py   # Improvements tracking
│   ├── raporty_8d.py     # 8D Reports handling
│   └── audyty.py         # Audits management
├── .env                  # Database credentials (not in repo)
├── .env.example          # Environment variables template
├── environment.yml       # Conda environment configuration
├── requirements.txt      # Pip dependencies
├── schema_dump_v2.sql    # Database schema
├── README.md            # This file
└── .gitignore           # Git ignore patterns
```

## Setup Instructions

### 1. Environment Setup

#### Option A: Using Conda (Recommended)
```bash
# Create environment from yml file
conda env create -f environment.yml

# Activate the environment
conda activate quality_monitor
```

#### Option B: Using pip
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Database Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` file with your database credentials:
   ```
   DB_NAME=your_database_name
   DB_USER=your_database_user
   DB_PASSWORD=your_database_password
   DB_HOST=your_database_host
   DB_PORT=your_database_port
   ```

### 3. Running the Application

```bash
streamlit run app.py
```

The application will be available at `http://localhost:8501`

## Features

- **Reklamacje** (Complaints): Manage customer complaints and quality issues
- **Doskonalenia** (Improvements): Track continuous improvement initiatives
- **Raporty 8D** (8D Reports): Handle 8D problem-solving methodology reports
- **Audyty** (Audits): Manage internal and external audit processes

## Module Structure

The application is organized into a modular structure:

- **`app.py`**: Main application entry point with navigation
- **`Raporty/`**: Package containing all report modules
  - Each module handles a specific type of quality management report
  - All modules share common database connectivity and UI patterns
  - Real-time database updates with comprehensive error handling

## Database Requirements

- PostgreSQL database
- Database schema as defined in `schema_dump_v2.sql`

## Security Notes

- Never commit the `.env` file to version control
- The `.env` file contains sensitive database credentials
- Use strong passwords for database access
- Consider using environment-specific configurations for production

## Development

The application uses:
- **Streamlit** for the web interface
- **PostgreSQL** for data storage
- **pandas** for data manipulation
- **psycopg2** for database connectivity
- **python-dotenv** for environment variable management

### Adding New Report Types

To add a new report type:
1. Create a new Python file in the `Raporty/` directory
2. Follow the existing pattern with `main()` function
3. Add the import to `Raporty/__init__.py`
4. Update the navigation in `app.py` 