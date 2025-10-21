"""
Database setup and initialization utilities.

Provides functions to initialize SQLite databases for caching media information
from various sources (TMDB, IMDb, OMDb).
"""
import sqlite3

def setup_database(db_path='tmdb_cache.db'):
    """Sets up the SQLite database and table."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS media_info (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            release_year INTEGER,
            media_type TEXT NOT NULL,
            total_seasons INTEGER,
            total_episodes INTEGER,
            status TEXT
        )
    ''')
    conn.commit()
    conn.close()

# Run this once to initialize the database
setup_database()

import sqlite3

def setup_database(db_path='imdb_cache.db'):
    """Sets up the SQLite database and table."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS media_info (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            release_year INTEGER,
            media_type TEXT NOT NULL,
            total_seasons INTEGER,
            total_episodes INTEGER,
            series_years TEXT
        )
    ''')
    conn.commit()
    conn.close()

# Run this once to initialize the database
setup_database()

import sqlite3

def setup_database(db_path='omdb_cache.db'):
    """Sets up the SQLite database and table."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS media_info (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            release_year INTEGER,
            media_type TEXT NOT NULL,
            total_seasons TEXT,
            status TEXT
        )
    ''')
    conn.commit()
    conn.close()

# Run this once to initialize the database
setup_database()