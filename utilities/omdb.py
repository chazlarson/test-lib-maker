"""
OMDb API integration for IMDb ID lookup.

Provides functions to retrieve IMDb IDs and movie information from the OMDb
API.
"""
import requests

from utilities.config import Config

def get_imdb_id_omdb(title, year):
    """
    Looks up the IMDb ID for a given movie title and year using the OMDb API.

    Args:
        title (str): The title of the movie.
        year (int): The release year of the movie.

    Returns:
        str or None: The IMDb ID (e.g., "tt1234567") if found, otherwise None.
    """
    config = Config()

    base_url = "http://www.omdbapi.com/"
    params = {
        "apikey": config.get('omdb.apikey'),
        "t": title,  # 't' for title search
        "y": year,   # 'y' for year
        "type": "movie" # Ensure we only search for movies
    }

    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()  # Raise an exception for HTTP errors (4xx or 5xx)
        data = response.json()

        if data.get("Response") == "True":
            # OMDb returns the IMDb ID directly as 'imdbID'
            return data.get("imdbID")
        elif data.get("Response") == "False":
            # OMDb provides an error message if no results are found or other issues
            # print(f"OMDb Error for '{title} ({year})': {data.get('Error')}")
            return None
        else:
            print(f"Unexpected OMDb API response for '{title} ({year})': {data}")
            return None

    except requests.exceptions.RequestException as e:
        print(f"Network or API request error for '{title} ({year})': {e}")
        return None
    except ValueError as e:
        print(f"JSON decoding error for '{title} ({year})': {e}")
        return None


# import sqlite3
# import requests

# # Replace with your actual OMDb API key
# OMDB_API_KEY = 'YOUR_API_KEY'
# OMDB_API_URL = 'http://www.omdbapi.com/'

# def get_omdb_info(title, year, db_path='omdb_cache.db'):
#     """
#     Gathers OMDb information using a SQLite cache.
#     Refreshes data for ongoing TV series.
#     """
#     conn = sqlite3.connect(db_path)
#     cursor = conn.cursor()

#     # Step 1: Check if the item exists in the database
#     cursor.execute("SELECT * FROM media_info WHERE title=? AND release_year=?", (title, year))
#     db_data = cursor.fetchone()

#     if db_data:
#         db_info = {
#             'id': db_data[0],
#             'title': db_data[1],
#             'release_year': db_data[2],
#             'media_type': db_data[3],
#             'total_seasons': db_data[4],
#             'status': db_data[5]
#         }

#         # Step 2: Conditional refresh for ongoing TV shows
#         if db_info['media_type'] == 'series' and db_info['total_seasons'] == 'N/A':
#             print("Refreshing data from OMDb...")

#             try:
#                 params = {'t': title, 'y': year, 'apikey': OMDB_API_KEY}
#                 response = requests.get(OMDB_API_URL, params=params)
#                 response.raise_for_status() # Raise an error for bad status codes
#                 data = response.json()

#                 if data.get('Response') == 'True':
#                     # Update the database
#                     cursor.execute('''
#                         UPDATE media_info
#                         SET total_seasons=?
#                         WHERE id=?
#                     ''', (data.get('totalSeasons', 'N/A'), db_info['id']))
#                     conn.commit()

#                     # Return the updated information
#                     db_info['total_seasons'] = data.get('totalSeasons', 'N/A')
#                     conn.close()
#                     return db_info

#             except requests.exceptions.RequestException as e:
#                 print(f"Error during refresh: {e}. Returning cached data.")
#                 conn.close()
#                 return db_info

#         else:
#             print("Returning cached data.")
#             conn.close()
#             return db_info

#     else:
#         # Step 3: Fetch from OMDb and store in the database
#         print("Item not in cache. Fetching from OMDb...")

#         try:
#             params = {'t': title, 'y': year, 'apikey': OMDB_API_KEY}
#             response = requests.get(OMDB_API_URL, params=params)
#             response.raise_for_status()
#             data = response.json()

#             if data.get('Response') == 'True':
#                 # Map OMDb data to our schema
#                 info = {
#                     'id': data.get('imdbID'),
#                     'title': data.get('Title'),
#                     'release_year': year,
#                     'media_type': data.get('Type'),
#                     'total_seasons': data.get('totalSeasons', 'N/A'),
#                     'status': data.get('totalSeasons') if data.get('totalSeasons') != 'N/A' else 'Ongoing'
#                 }

#                 cursor.execute('''
#                     INSERT INTO media_info
#                     (id, title, release_year, media_type, total_seasons, status)
#                     VALUES (?, ?, ?, ?, ?, ?)
#                 ''', (info['id'], info['title'], info['release_year'], info['media_type'],
#                       info['total_seasons'], info['status']))
#                 conn.commit()
#                 conn.close()
#                 return info
#             else:
#                 print(f"Error from OMDb: {data.get('Error')}")
#                 conn.close()
#                 return None

#         except requests.exceptions.RequestException as e:
#             print(f"An error occurred: {e}")
#             conn.close()
#             return None

#     conn.close()
#     return None

# # --- Example Usage ---
# # First call (fetches from OMDb and stores)
# print("--- First fetch for Game of Thrones ---")
# media_info_1 = get_omdb_info("Game of Thrones", 2011)
# print(media_info_1)
# print("\n" + "="*20 + "\n")

# # Second call (retrieves from cache, no refresh needed as it's a completed series)
# print("--- Second fetch for Game of Thrones ---")
# media_info_2 = get_omdb_info("Game of Thrones", 2011)
# print(media_info_2)

