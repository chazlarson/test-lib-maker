"""
TMDB API integration for movie and TV series data retrieval.

Provides functions to fetch TMDB information with SQLite caching to avoid
repeated API calls for the same media.
"""
from tmdbpy import TMDb
import sqlite3

# Replace with your actual TMDB API key
tmdb = TMDb('YOUR_API_KEY')

def get_tmdb_info(title, year, media_type, db_path='tmdb_cache.db'):
    """
    Gathers TMDB ID and related information, using a SQLite cache.
    Refreshes data for airing or returning TV series.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Step 1: Check if the item exists in the database
    cursor.execute("SELECT * FROM media_info WHERE title=? AND release_year=?", (title, year))
    db_data = cursor.fetchone()

    # Define statuses that require a refresh
    refresh_statuses = ['Returning Series', 'In Production']

    if db_data:
        # Map database columns to a dictionary for easier access
        db_info = {
            'id': db_data[0],
            'title': db_data[1],
            'release_year': db_data[2],
            'media_type': db_data[3],
            'total_seasons': db_data[4],
            'total_episodes': db_data[5],
            'status': db_data[6]
        }

        # Step 2: Conditional refresh for TV shows
        if db_info['media_type'] == 'tv' and db_info['status'] in refresh_statuses:
            print("Refreshing data from TMDB...")
            # Fetch the latest data from TMDB
            tv_details = tmdb.tv.details(db_info['id'])

            # Update the database with the new information
            cursor.execute('''
                UPDATE media_info
                SET total_seasons=?, total_episodes=?, status=?
                WHERE id=?
            ''', (tv_details.get('number_of_seasons'),
                  tv_details.get('number_of_episodes'),
                  tv_details.get('status'),
                  db_info['id']))
            conn.commit()

            # Return the updated information
            db_info['total_seasons'] = tv_details.get('number_of_seasons')
            db_info['total_episodes'] = tv_details.get('number_of_episodes')
            db_info['status'] = tv_details.get('status')
            conn.close()
            return db_info

        else:
            # Item found in DB and doesn't need a refresh
            print("Returning cached data.")
            conn.close()
            return db_info

    else:
        # Step 3: Fetch from TMDB and store in the database
        print("Item not in cache. Fetching from TMDB...")

        # This part is similar to the original function
        if media_type == 'movie':
            search_results = tmdb.search.movie(query=title, year=year)
            if search_results:
                data = search_results[0]
                info = {
                    'id': data['id'],
                    'title': data['title'],
                    'release_year': year,
                    'media_type': 'movie'
                }
                cursor.execute('''
                    INSERT INTO media_info (id, title, release_year, media_type)
                    VALUES (?, ?, ?, ?)
                ''', (info['id'], info['title'], info['release_year'], info['media_type']))
                conn.commit()
                conn.close()
                return info

        elif media_type == 'tv':
            search_results = tmdb.search.tv(query=title, first_air_date_year=year)
            if search_results:
                data = search_results[0]
                tv_details = tmdb.tv.details(data['id'])
                info = {
                    'id': data['id'],
                    'title': data['name'],
                    'release_year': year,
                    'media_type': 'tv',
                    'total_seasons': tv_details.get('number_of_seasons'),
                    'total_episodes': tv_details.get('number_of_episodes'),
                    'status': tv_details.get('status')
                }
                cursor.execute('''
                    INSERT INTO media_info
                    (id, title, release_year, media_type, total_seasons, total_episodes, status)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                ''', (info['id'], info['title'], info['release_year'], info['media_type'],
                      info['total_seasons'], info['total_episodes'], info['status']))
                conn.commit()
                conn.close()
                return info

    conn.close()
    return None

# --- Example Usage ---
# First call (fetches from TMDB and stores)
print("--- First fetch for Breaking Bad ---")
tv_info_1 = get_tmdb_info("Breaking Bad", 2008, 'tv')
print(tv_info_1)
print("\n" + "="*20 + "\n")

# Second call (retrieves from cache, no refresh needed as it's not 'Returning Series' or 'In Production')
print("--- Second fetch for Breaking Bad ---")
tv_info_2 = get_tmdb_info("Breaking Bad", 2008, 'tv')
print(tv_info_2)