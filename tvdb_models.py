"""
SQLAlchemy ORM models for TVDB database entities.

Defines the database schema for movies, series, seasons, and episodes with proper
relationships and type annotations using SQLAlchemy's declarative mapping.
"""
import datetime
from datetime import datetime
from typing import List
from typing import Optional
from sqlalchemy import DateTime, ForeignKey
from sqlalchemy import String
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column
from sqlalchemy.orm import relationship

class Base(DeclarativeBase):
    pass

class Movie(Base):
    __tablename__ = "Movie"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(30))
    year: Mapped[int]
    updated: Mapped[datetime] = mapped_column(DateTime(), default=datetime.now())

    def __repr__(self) -> str:
        return f"Movie(id={self.id!r}, name={self.name!r}, year={self.year!r}, updated={self.updated!r})"
# {
#     'id': 188861,
#     'name': 'Northern Lights',
#     'slug': 'northern-lights',
#     'image': '/banners/posters/188861-2.jpg',
#     'nameTranslations': ['eng'],
#     'overviewTranslations': ['eng', 'fra'],
#     'aliases': [],
#     'firstAired': '2006-01-16',
#     'lastAired': '2008-12-21',
#     'nextAired': '',
#     'score': 60,
#     'status': {'id': None, 'name': None, 'recordType': '', 'keepUpdated': False},
#     'originalCountry': 'gbr',
#     'originalLanguage': 'eng',
#     'defaultSeasonType': 1,
#     'isOrderRandomized': False,
#     'lastUpdated': '2024-09-14 15:26:21',
#     'averageRuntime': 60,
#     'episodes': None,
#     'overview': 'ITV comedy drama starring Robson Green and Mark Benton. Happily married to sisters, l... strive to outdo each others achievements.',
#     'year': '2006'
#  }

# {
#   "status": "success",
#   "data": [
#     {
#       "id": 1,
#       "name": "Continuing",
#       "recordType": "series",
#       "keepUpdated": false
#     },
#     {
#       "id": 2,
#       "name": "Ended",
#       "recordType": "series",
#       "keepUpdated": false
#     },
#     {
#       "id": 3,
#       "name": "Upcoming",
#       "recordType": "series",
#       "keepUpdated": false
#     }
#   ]
# }
class Series(Base):
    __tablename__ = "Series"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(30))
    year: Mapped[int]
    status: Mapped[int]
    season_count: Mapped[int]
    updated: Mapped[datetime] = mapped_column(DateTime(), default=datetime.now())

    def __repr__(self) -> str:
        return f"Series(id={self.id!r}, name={self.name!r}, year={self.year!r}, season_count={self.season_count!r}, updated={self.updated!r})"

class Season(Base):
    __tablename__ = "Season"
    show_id: Mapped[int] = mapped_column(ForeignKey("Series.id"), primary_key=True)
    season_number: Mapped[int] = mapped_column(primary_key=True)
    episode_count: Mapped[int]
    updated: Mapped[datetime] = mapped_column(DateTime(), default=datetime.now())

    def __repr__(self) -> str:
        return f"Season(show_id={self.show_id!r}, season_number={self.season_number!r}, episode_count={self.episode_count!r}, updated={self.updated!r})"

# # 'episodes': [
# # 	{'id': 3254641,
# # 	'seriesId': 121361,
# # 	'name': 'Winter Is Coming',
# # 	'aired': '2011-04-17',
# # 	'runtime': 61,
# # 	'nameTranslations': ['ces', 'ara'],
# # 	'overview': "Lord Ned Stark is troubled by disturbing reports form a Night's Watch deserter; King Robert arrives at Winterfell.",
# # 	'overviewTranslations': ['ces', 'ara'],
# # 	'image': 'https://artworks.thetvdb.com/banners/episodes/121361/65970d5bd8d2a.jpg',
# # 	'imageType': 11,
# # 	'isMovie': 0,
# # 	'seasons': None,
# # 	'number': 1,
# # 	'absoluteNumber': 1,
# # 	'seasonNumber': 1,
# # 	'lastUpdated': '2024-01-04 19:57:15',
# # 	'finaleType': None,
# # 	'year': '2011'},

# episode_table = Table('Episode', metadata_obj,
#               Column('Id', Integer(),primary_key=True),
#               Column('seriesId', Integer(), nullable=False),
#               Column('season_num', Integer(), nullable=False),
#               Column('episode_num', Integer(), nullable=False),
#               Column('episode_absolute_num', Integer(), nullable=False),
#               Column('Name', String(255), nullable=False),
#               Column('Year', Integer(), nullable=False),
#               Column('Updated', DateTime(), default=datetime.now())
#               )

class Episode(Base):
    __tablename__ = "Episode"
    id: Mapped[int] = mapped_column(primary_key=True)
    series_id: Mapped[int] = mapped_column(ForeignKey("Series.id"))
    season_num: Mapped[int]
    episode_num: Mapped[int]
    episode_absolute_num: Mapped[int]
    name: Mapped[str]
    year: Mapped[int]
    updated: Mapped[datetime] = mapped_column(DateTime(), default=datetime.now())

    def __repr__(self) -> str:
        return f"Episode(id={self.id!r}, series_id={self.series_id!r}, season_num={self.season_num!r}, episode_num={self.episode_num!r}, episode_absolute_num={self.episode_absolute_num!r}, name={self.name!r}, year={self.year!r}, updated={self.updated!r})"
