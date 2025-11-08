"""
Database configuration for SQL Server connection
Uses environment variables from Azure App Service
"""

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
import urllib
import logging

logger = logging.getLogger(__name__)

# Get connection string from environment
# This is set in Azure App Service app settings
def get_connection_string():
    """Build SQL Server connection string from environment variables"""
    
    # Option 1: Use full connection string (recommended)
    conn_str = os.getenv("SQL_CONNECTION_STRING")
    if conn_str:
        return conn_str
    
    # Option 2: Build from individual components
    server = os.getenv("SQL_SERVER_FQDN", "")
    database = os.getenv("SQL_DATABASE_NAME", "sqldb-app-dev")
    username = os.getenv("SQL_ADMIN_USERNAME", "sqladmin")
    password = os.getenv("SQL_ADMIN_PASSWORD", "")
    
    if server and password:
        return (
            f"Server=tcp:{server},1433;"
            f"Database={database};"
            f"Uid={username};"
            f"Pwd={password};"
            f"Encrypt=yes;"
            f"TrustServerCertificate=no;"
            f"Connection Timeout=30;"
        )
    
    # Fallback for local development
    logger.warning("Using local development database")
    return "sqlite:///./todo.db"

# Create SQLAlchemy engine
def create_db_engine():
    """Create database engine with proper driver"""
    conn_str = get_connection_string()
    
    # Check if using SQL Server or SQLite
    if conn_str.startswith("Server=") or conn_str.startswith("server="):
        # SQL Server connection
        # Convert ADO.NET connection string to SQLAlchemy format
        params = urllib.parse.quote_plus(conn_str)
        sqlalchemy_url = f"mssql+pyodbc:///?odbc_connect={params}"
        
        engine = create_engine(
            sqlalchemy_url,
            echo=True,  # Set to False in production
            pool_pre_ping=True,  # Enable connection health checks
            pool_recycle=3600,  # Recycle connections after 1 hour
        )
        logger.info(f"Connected to SQL Server")
    else:
        # SQLite for local development
        engine = create_engine(
            conn_str,
            connect_args={"check_same_thread": False},
            echo=True
        )
        logger.info("Connected to SQLite (local development)")
    
    return engine

# Create engine
engine = create_db_engine()

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create base class for models
Base = declarative_base()

# Dependency to get database session
def get_db():
    """Get database session for dependency injection"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Initialize database (create tables)
def init_db():
    """Initialize database - create all tables"""
    from models import Todo  # Import here to avoid circular dependency
    logger.info("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    logger.info("Database tables created successfully")