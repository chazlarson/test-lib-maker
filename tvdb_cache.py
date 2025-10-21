"""
TVDB database cache management.

This module handles fetching and caching TV and movie data from the TVDB API into a SQLite database.
It manages movies, series, seasons, and episodes with batch insertion and conflict handling.
"""
from alive_progress import alive_bar
from datetime import datetime
import tvdb_v4_official
import sqlalchemy
from sqlalchemy import DateTime, create_engine
from sqlalchemy import MetaData, Table, Column, Integer, String, Float
from sqlalchemy import MetaData
from sqlalchemy.dialects.sqlite import insert
from sqlalchemy import select, distinct

from sqlalchemy import MetaData
from tvdb_models import Base, Episode, Movie, Season, Series

import logging

logging.basicConfig()
logging.getLogger('sqlalchemy').setLevel(logging.ERROR)

metadata_obj = MetaData()

engine = create_engine("sqlite+pysqlite:///tvdb_database.sqlite", echo=False)

Base.metadata.create_all(engine)

tvdb = tvdb_v4_official.TVDB("bed9264b-82e9-486b-af01-1bb201bcb595")

since_movies = 0
since_series = 0
since_seasons = 0
since_episodes = 0

movies_list = []
series_list = []
seasons_list = []
episodes_list = []

movie_ids_in_db = []
series_ids_in_db = []
season_ids_in_db = []

with engine.connect() as conn:
    movie_latest_stmt = select(Movie.updated).order_by(Movie.updated.desc()).limit(1)
    results = conn.execute(movie_latest_stmt)
    try:
        since_movies = int(results.fetchone()[0].timestamp())
    except:
        since_movies = 0

    series_latest_stmt = select(Series.updated).order_by(Series.updated.desc()).limit(1)
    results = conn.execute(series_latest_stmt)
    try:
        since_series = int(results.fetchone()[0].timestamp())
    except:
        since_series = 0

    season_latest_stmt = select(Season.updated).order_by(Season.updated.desc()).limit(1)
    results = conn.execute(season_latest_stmt)
    try:
        since_seasons = int(results.fetchone()[0].timestamp())
    except:
        since_seasons = 0

    episode_latest_stmt = select(Episode.updated).order_by(Episode.updated.desc()).limit(1)
    results = conn.execute(episode_latest_stmt)
    try:
        since_episodes = int(results.fetchone()[0].timestamp())
    except:
        since_episodes = 0

    print(f"Gathering unique movie IDs...")
    unique_movies_stmt = select(distinct(Movie.id))
    movie_ids_in_db = results = conn.execute(unique_movies_stmt).scalars().all()
    print(f"{len(movie_ids_in_db)} unique movie IDs found in the database.")

    print(f"Gathering unique series IDs...")
    unique_series_stmt = select(distinct(Series.id))
    series_ids_in_db = results = conn.execute(unique_series_stmt).scalars().all()
    print(f"{len(series_ids_in_db)} unique series IDs found in the database.")

    print(f"Gathering unique series-season IDs...")
    unique_seasons_stmt = select(Season.show_id, Season.season_number)
    season_ids_raw = results = conn.execute(unique_seasons_stmt).all()
    with alive_bar(len(season_ids_raw)) as bar:
        for rec in season_ids_raw:
            season_ids_in_db.append(f"{rec.show_id}-{rec.season_number}")
            bar()
    print(f"{len(season_ids_in_db)} unique series-season IDs found in the database.")

# since_movies = 0
since_series = 0
since_seasons = 0
since_episodes = 0

index = 0
reached_the_end = False
insert_batch_size = 1500
insert_count = 0

print(f"Fetching movies since timestamp: {since_movies}")

with alive_bar() as bar:
    while not reached_the_end:
        bar.text(f"Processing page {index}")
        if since_movies > 0:
            got_it = False
            while not got_it:
                try:
                    this_page = tvdb.get_updates(since_movies, page=index, action='update', type='movie')
                    got_it = True
                except:
                    print(f"Error fetching movies, retrying page {index}")
        else:
            got_it = False
            while not got_it:
                try:
                    this_page = tvdb.get_all_movies(index)
                    got_it = True
                except:
                    print(f"Error fetching movies, retrying page {index}")
        reached_the_end = len(this_page) == 0
        movies_list += this_page
        index += 1
        # reached_the_end = index > 3
        bar()

print(f"Total movies fetched: {len(movies_list)}")

values_list = []

if len(movies_list) > 0:
    print(f"{len(movies_list)} movies to process.")

    with engine.connect() as conn:
        with alive_bar(len(movies_list)) as bar:
            for movie in movies_list:

                ID = movie['id']
                title = movie['name']
                year = movie['year'] if 'year' in movie else 1111

                if ID not in movie_ids_in_db:
                    tmpdict = {}
                    tmpdict['id'] = ID
                    tmpdict['name'] = title
                    tmpdict['year'] = year

                    values_list.append(tmpdict)

                if len(values_list) >= insert_batch_size:
                    # print(f"Insert {len(values_list)} movies into the database")
                    stmt = insert(Movie).values(values_list)
                    stmt = stmt.on_conflict_do_nothing(index_elements=['id'])

                    result = conn.execute(stmt)

                    conn.commit()

                    values_list = []
                    insert_count += len(values_list)

                bar()

            if len(values_list) > 0:
                # print(f"Insert {len(values_list)} movies into the database")

                stmt = insert(Movie).values(values_list)

                result = conn.execute(stmt)

                conn.commit()

                insert_count += len(values_list)

            bar()

print(f"{insert_count} movies inserted into the database.")


index = 0
reached_the_end = False
insert_count = 0

print(f"Fetching series since timestamp: {since_series}")

with alive_bar() as bar:
    while not reached_the_end:
        bar.text(f"Processing page {index}")
        if since_series > 0:
            got_it = False
            while not got_it:
                try:
                    this_page = tvdb.get_updates(since_series, page=index, action='update', type='series')
                    got_it = True
                except:
                    print(f"Error fetching series, retrying page {index}")
        else:
            got_it = False
            while not got_it:
                try:
                    this_page = tvdb.get_all_series(index)
                    got_it = True
                except:
                    print(f"Error fetching series, retrying page {index}")
        reached_the_end = len(this_page) == 0
        series_list += this_page
        index += 1
        # reached_the_end = index > 2
        bar()

print(f"Total series fetched: {len(series_list)}")

values_list = []
season_data_dict = {}

with engine.connect() as conn:
    with alive_bar(len(series_list)) as bar:
        for series in series_list:
            # I have a series; I want to insert it into the database if it's not already there
            # I also want to gather season data and insert *that* into the database
            # If the series already exists, I skip writing it
            # If the series has no episodes, I skip it
            no_write_series = []
            title = series['name']
            year = series['year'] if 'year' in series else 1111
            status = series['status']['id'] if 'status' in series and 'id' in series['status'] else None

            if 'id' in series:
                if 'name' in series:
                    need_episodes = True # assume we need episodes

                    if 'id' in series and series['id'] in series_ids_in_db:
                        # print(f"Series ID {series['id']} already exists in the database.")
                        no_write_series.append(series['id'])
                        # if the series is already in the database, and ended, we don't need to fetch episodes
                        need_episodes = status != 2  # If the series is ended, we don't need to fetch episodes

                    ID = series['id']

                    try:
                        # Get the series extended data, which includes all episodes
                        episodes = tvdb.get_series_episodes(ID)
                        episode_count = len(episodes['episodes'])
                    except:
                        episode_count = 0

                    if episode_count > 0:

                        # Get the episodes list from the extended data
                        episodes_list = episodes['episodes']

                        # Create a dictionary to store episode counts per season
                        seasons_info = {}

                        for episode in episodes_list:
                            season_number = episode.get('seasonNumber')
                            # 'seasonNumber' is None for specials or invalid episodes, so we skip them
                            if season_number is not None:
                                if season_number not in seasons_info:
                                    seasons_info[season_number] = 0
                                seasons_info[season_number] += 1

                        season_data ={
                            "total_seasons": len([s for s in seasons_info if s > 0]),
                            "episodes_per_season": seasons_info
                        }
                    else:
                        no_write_series.append(ID)
                        print(f"No episodes found for TVDB ID: {ID}")

                    if ID not in no_write_series and ID not in series_ids_in_db:
                        tmpdict = {}
                        tmpdict['id'] = ID
                        tmpdict['name'] = title
                        tmpdict['year'] = year if year is not None else 1111
                        tmpdict['season_count'] = season_data['total_seasons']

                        season_data_dict[ID] = season_data

                        values_list.append(tmpdict)
                    else:
                        print(f"Skipping series {ID} - {title} ({year}): already in database.")
                else:
                    print(f"Skipping series due to missing name: {series}")

            else:
                print(f"Skipping series due to missing ID: {series}")

            if len(values_list) >= insert_batch_size:
                # print(f"Insert {len(values_list)} series into the database")
                stmt = insert(Series).values(values_list)
                stmt = stmt.on_conflict_do_nothing(index_elements=['id'])

                result = conn.execute(stmt)

                conn.commit()

                values_list = []

                insert_count += len(values_list)
            else:
                season_data_dict[ID] = season_data
            bar()

        if len(values_list) > 0:
            # print(f"Insert {len(values_list)} series into the database")

            stmt = insert(Series).values(values_list)
            stmt = stmt.on_conflict_do_nothing(index_elements=['id'])

            result = conn.execute(stmt)

            conn.commit()

            insert_count += len(values_list)

        values_list = []

        bar()

    print(f"{insert_count} series inserted into the database.")

    insert_count = 0

    # now writing season data to the database
    with alive_bar(len(season_data_dict)) as bar:
        for series, episode_data in season_data_dict.items():
            episode_values = episode_data['episodes_per_season']
            for season_number, episode_count in episode_values.items():

                if f"{series}-{season_number}" not in series_ids_in_db:
                    # print(f"Inserting season {season_number} with {episode_count} episodes for series ID {series}")
                    tmpDict = {}
                    tmpDict['show_id'] = series
                    tmpDict['season_number'] = season_number
                    tmpDict['episode_count'] = episode_count


                    values_list.append(tmpDict)

                if len(values_list) >= insert_batch_size:
                    # print(f"Insert {len(values_list)} seasons into the database")
                    stmt = insert(Season).values(values_list)
                    stmt = stmt.on_conflict_do_nothing(index_elements=['show_id', 'season_number'])

                    result = conn.execute(stmt)

                    conn.commit()

                    values_list = []

                    insert_count += len(values_list)
            bar()

        if len(values_list) > 0:
            # print(f"Insert {len(values_list)} seasons into the database")

            stmt = insert(Season).values(values_list)
            stmt = stmt.on_conflict_do_nothing(index_elements=['show_id', 'season_number'])

            result = conn.execute(stmt)

            conn.commit()

            insert_count += len(values_list)

        values_list = []

        bar()

print(f"{insert_count} seasons inserted into the database.")

index = 0
reached_the_end = False

# with alive_bar() as bar:
#     while not reached_the_end:
#         index += 1
#         bar.text(f"Processing page {index}")
#         if since_seasons > 0:
#             this_page = tvdb.get_updates(since_seasons, page=index, action='update', type='seasons')
#         else:
#             this_page = tvdb.get_all_seasons(index)
#         reached_the_end = len(this_page) == 0
#         seasons_list += this_page
#         bar()

# print(f"Total seasons fetched: {len(seasons_list)}")

# values_list = []

# with engine.connect() as conn:
#     with alive_bar(len(seasons_list)) as bar:
#         for season in seasons_list:

#             ID = season['id']
#             showid = season['seriesId']
#             type = season['type']['type']
#             season_number = season['number']

#             check_stmt = select(season_table).where(season_table.c.Id == ID)
#             results = conn.execute(check_stmt)
#             if results.fetchone() is not None:
#                 continue

#             tmpdict = {}
#             tmpdict['Id'] = ID
#             tmpdict['ShowId'] = showid
#             tmpdict['type'] = type
#             tmpdict['season_number'] = season_number

#             values_list.append(tmpdict)

#             if len(values_list) >= insert_batch_size:
#                 print(f"Insert {len(values_list)} seasons into the database")
#                 stmt = insert(season_table).values(values_list)

#                 result = conn.execute(stmt)

#                 conn.commit()

#                 values_list = []
#             bar()

#         if len(values_list) > 0:
#             print(f"Insert {len(values_list)} seasons into the database")

#             stmt = insert(season_table).values(values_list)

#             result = conn.execute(stmt)

#             conn.commit()

#         bar()

# index = 0
# reached_the_end = False

# with alive_bar() as bar:
#     while not reached_the_end:
#         index += 1
#         bar.text(f"Processing page {index}")
#         if since_episodes > 0:
#             this_page = tvdb.get_updates(since_episodes, page=index, action='update', type='episodes')
#         else:
#             this_page = tvdb.get_all_episodes(index)
#         reached_the_end = len(this_page) == 0
#         episodes_list += this_page
#         bar()

# print(f"Total episodes fetched: {len(episodes_list)}")

# values_list = []

# with engine.connect() as conn:
#     with alive_bar(len(episodes_list)) as bar:
#         for episode in episodes_list:

#             ID = episode['id']
#             seriesId = episode['seriesId']
#             season_num = episode['seasonNumber']
#             episode_num = episode['number']
#             episode_absolute_num = episode['absoluteNumber']
#             title = episode['name']
#             year = episode['year'] if 'year' in episode else None

#             if not season_num or not episode_num or not episode_absolute_num:
#                 print(f"Skipping episode {ID}: {title} from series {seriesId} due to missing season or episode numbers")
#                 continue

#             check_stmt = select(episode_table).where(episode_table.c.Id == ID)
#             results = conn.execute(check_stmt)
#             if results.fetchone() is not None:
#                 continue

#             tmpdict = {}
#             tmpdict['Id'] = ID
#             tmpdict['seriesId'] = seriesId
#             tmpdict['season_num'] = season_num
#             tmpdict['episode_num'] = episode_num
#             tmpdict['episode_absolute_num'] = episode_absolute_num
#             tmpdict['Name'] = title
#             tmpdict['Year'] = year
#             tmpdict['Updated'] = datetime.now()

# # episode_table = Table('Episode', metadata_obj,
# #               Column('Id', Integer(),primary_key=True),
# #               Column('seriesId', Integer(), nullable=False),
# #               Column('season_num', Integer(), nullable=False),
# #               Column('episode_num', Integer(), nullable=False),
# #               Column('episode_absolute_num', Integer(), nullable=False),
# #               Column('Name', String(255), nullable=False),
# #               Column('Year', Integer(), nullable=False),
# #               Column('Updated', DateTime(), default=datetime.now())
# #               )

#             values_list.append(tmpdict)

#             if len(values_list) >= insert_batch_size:
#                 print(f"Insert {len(values_list)} episodes into the database")
#                 stmt = insert(episode_table).values(values_list)

#                 result = conn.execute(stmt)

#                 conn.commit()

#                 values_list = []
#             bar()

#         if len(values_list) > 0:
#             print(f"Insert {len(values_list)} episodes into the database")

#             stmt = insert(episode_table).values(values_list)

#             result = conn.execute(stmt)

#             conn.commit()

#         bar()


exit()

series_list = [ ]
while not reached_the_end: # Pages are numbered from 0
    series_list += tvdb.get_all_series(j)

# fetching a series
series = tvdb.get_series(121361)

# fetching a season's episode list
series = tvdb.get_series_extended(121361)
for season in sorted(series["seasons"], key=lambda x: (x["type"]["name"], x["number"])):
    print(f"{season["type"]["name"]}, {season["number"]}, {season["id"]}")
    # if season["type"]["name"] == "Aired Order" and season["number"] == 1:
	  #   season = tvdb.get_season_extended(season["id"])
	  #   break
else:
    season = None
if season is not None:
    print(season["episodes"])

# fetch a page of episodes from a series by season_type (type is "default" if unspecified)
info = tvdb.get_series_episodes(121361, page=0)
print(info["series"])
for ep in info["episodes"]:
    print(ep)

# fetching a movie
movie = tvdb.get_movie(31) # avengers

# access a movie's characters
movie = tvdb.get_movie_extended(31)
for c in movie["characters"]:
    print(c)

# fetching a person record
person = tvdb.get_person_extended(characters[0]["peopleId"])
print(person)

# using since If-Modifed-Since parameter
series = tvdb.get_series_extended(393199, if_modified_since="Wed, 30 Jun 2022 07:28:00 GMT")