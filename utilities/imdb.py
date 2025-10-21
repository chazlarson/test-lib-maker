"""
IMDb data retrieval and caching utilities.

Provides functions to fetch IMDb information for movies and TV series,
with SQLite caching to avoid repeated API calls.
"""
import sqlite3
from imdb import IMDb

# Create an instance of the IMDb class
ia = IMDb()

def get_imdb_info(title, year, media_type, db_path='imdb_cache.db'):
    """
    Gathers IMDb ID and related information, using a SQLite cache.
    Refreshes data for ongoing TV series.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Step 1: Check if the item exists in the database
    cursor.execute("SELECT * FROM media_info WHERE title=? AND release_year=?", (title, year))
    db_data = cursor.fetchone()

    if db_data:
        db_info = {
            'id': db_data[0],
            'title': db_data[1],
            'release_year': db_data[2],
            'media_type': db_data[3],
            'total_seasons': db_data[4],
            'total_episodes': db_data[5],
            'series_years': db_data[6]
        }

        # Step 2: Conditional refresh for ongoing TV shows
        if db_info['media_type'] == 'tv' and db_info['series_years'] and db_info['series_years'].endswith('-'):
            print("Refreshing data from IMDb...")
            try:
                # Fetch the latest data from IMDb
                series = ia.get_movie(db_info['id'])
                # The IMDbPY get_movie method doesn't always have season/episode counts directly
                # You need to update the object with the 'episodes' infoset.
                ia.update(series, 'episodes')

                total_seasons = len(series.get('episodes', []))
                total_episodes = sum(len(season) for season in series.get('episodes', {}).values())
                series_years = series.get('series years')

                # Update the database
                cursor.execute('''
                    UPDATE media_info
                    SET total_seasons=?, total_episodes=?, series_years=?
                    WHERE id=?
                ''', (total_seasons, total_episodes, series_years, db_info['id']))
                conn.commit()

                # Return the updated information
                db_info['total_seasons'] = total_seasons
                db_info['total_episodes'] = total_episodes
                db_info['series_years'] = series_years
                conn.close()
                return db_info

            except Exception as e:
                print(f"Error during refresh: {e}. Returning cached data.")
                conn.close()
                return db_info

        else:
            print("Returning cached data.")
            conn.close()
            return db_info

    else:
        # Step 3: Fetch from IMDb and store in the database
        print("Item not in cache. Fetching from IMDb...")

        try:
            if media_type == 'movie':
                search_results = ia.search_movie(title)
                # Find the best match by year
                match = next((m for m in search_results if str(m.get('year')) == str(year)), None)
                if match:
                    movie_id = match.getID()
                    info = {
                        'id': movie_id,
                        'title': match['title'],
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
                search_results = ia.search_movie(title)
                # Find the best match that is a TV series and matches the year
                match = next((m for m in search_results if m.get('kind') == 'tv series' and str(m.get('year')) == str(year)), None)
                if match:
                    series_id = match.getID()
                    series = ia.get_movie(series_id)
                    ia.update(series, 'episodes')

                    total_seasons = len(series.get('episodes', []))
                    total_episodes = sum(len(season) for season in series.get('episodes', {}).values())
                    series_years = series.get('series years')

                    info = {
                        'id': series_id,
                        'title': series['title'],
                        'release_year': year,
                        'media_type': 'tv',
                        'total_seasons': total_seasons,
                        'total_episodes': total_episodes,
                        'series_years': series_years
                    }
                    cursor.execute('''
                        INSERT INTO media_info
                        (id, title, release_year, media_type, total_seasons, total_episodes, series_years)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    ''', (info['id'], info['title'], info['release_year'], info['media_type'],
                          info['total_seasons'], info['total_episodes'], info['series_years']))
                    conn.commit()
                    conn.close()
                    return info
        except Exception as e:
            print(f"An error occurred: {e}")
            conn.close()
            return None

    conn.close()
    return None

# --- Example Usage ---
# First call (fetches from IMDb and stores)
print("--- First fetch for Breaking Bad ---")
tv_info_1 = get_imdb_info("Breaking Bad", 2008, 'tv')
print(tv_info_1)
print("\n" + "="*20 + "\n")

# Second call (retrieves from cache, no refresh needed as it's a completed series)
print("--- Second fetch for Breaking Bad ---")
tv_info_2 = get_imdb_info("Breaking Bad", 2008, 'tv')
print(tv_info_2)