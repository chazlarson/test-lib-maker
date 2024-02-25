#!/bin/bash

# SCRIPT TO DO STUFF

# At least two comedy movies released since 2012.
# At least two movies from the IMDB top 250.
# At least two movies from IMDB's Popular list.
# At least two movies from IMDB's Lowest Rated.
# A couple different resolutions among the movies.

# ffmpeg -f lavfi -i nullsrc=s=1280x720 -filter_complex "geq=random(1)*255:128:128;aevalsrc=-2+random(0)" -t 900 output.mkv

createbasevideo () {
    FILE="$1.mkv"
    if [ -f $FILE ]; then
        echo "File $FILE exists."
    else
        echo "Creating $FILE..."
        ffmpeg -loop 1 -i testpattern.png -c:v libx264 -t 60 -pix_fmt yuv420p -vf scale=$2 $FILE
        echo "$FILE created"
        echo "==================="
    fi
}

createbasevideo '4k' '3840:2160'
createbasevideo '1080' '1920:1080'
createbasevideo '720' '1280:720'
createbasevideo '576' '1024:576'
createbasevideo '480' '854:480'

createtestvideo () {
    mkdir -p "test_movie_lib/$1 $2"
    ffmpeg -i "$3.mkv" -i sounds/1-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 "test_movie_lib/$1 $2/$1 [WEBDL-$4 H264 AAC 2.0]-BINGBANG.mkv"
}


# Comedy after 2012
createtestvideo "The Holdovers (2023)" "{imdb-tt14849194} {tmdb-840430}" "4k" "2160p"
createtestvideo "Deadpool (2016)" "{imdb-tt1431045} {tmdb-293660}" "1080" "1080p"
createtestvideo "Deadpool 2 (2018)" "{imdb-tt5463162} {tmdb-383498}" "720" "720p"
createtestvideo "Once Upon a Time... in Hollywood (2019)" "{imdb-tt7131622} {tmdb-466272}" "576" "576p"
createtestvideo "The Wolf of Wall Street (2013)" "{imdb-tt0993846} {tmdb-106646}" "480" "480p"
createtestvideo "Green Book (2018)" "{imdb-tt6966692} {tmdb-490132}" "4k" "2160p"
createtestvideo "Everything Everywhere All at Once (2022)" "{imdb-tt6710474} {tmdb-545611}" "1080" "1080p"
createtestvideo "Guardians of the Galaxy Vol. 3 (2023)" "{imdb-tt6791350} {tmdb-447365}" "720" "720p"
createtestvideo "Knives Out (2019)" "{imdb-tt8946378} {tmdb-546554}" "576" "576p"
createtestvideo "La La Land (2016)" "{imdb-tt3783958} {tmdb-313369}" "480" "480p"
# IMDB Top 250
createtestvideo "Oppenheimer (2023)" "{imdb-tt15398776} {tmdb-872585}" "4k" "2160p"
createtestvideo "Interstellar (2014)" "{imdb-tt0816692} {tmdb-157336}" "1080" "1080p"
createtestvideo "Top Gun: Maverick (2022)" "{imdb-tt1745960} {tmdb-361743}" "720" "720p"
createtestvideo "Spider-Man: Across the Spider-Verse (2023)" "{imdb-tt9362722} {tmdb-569094}" "576" "576p"
# createtestvideo "The Wolf of Wall Street (2013)" "{imdb-tt0993846} {tmdb-106646}" "480" "480p"
# createtestvideo "Green Book (2018)" "{imdb-tt6966692} {tmdb-490132}" "4k" "2160p"
createtestvideo "Joker (2019)" "{imdb-tt7286456} {tmdb-475557}" "1080" "1080p"
createtestvideo "Whiplash (2014)" "{imdb-tt2582802} {tmdb-244786}" "720" "720p"
createtestvideo "Gone Girl (2014)" "{imdb-tt2267998} {tmdb-210577}" "576" "576p"
createtestvideo "Spider-Man: No Way Home (2021)" "{imdb-tt10872600} {tmdb-634649}" "480" "480p"
# IMDB most Popular
createtestvideo "Madame Web (2024)" "{imdb-tt11057302} {tmdb-634492}" "4k" "2160p"
createtestvideo "Dune: Part One (2021)" "{imdb-tt1160419} {tmdb-438631}" "1080" "1080p"
createtestvideo "Poor Things (2023)" "{imdb-tt14230458} {tmdb-792307}" "720" "720p"
createtestvideo "Saltburn (2023)" "{imdb-tt17351924} {tmdb-930564}" "576" "576p"
createtestvideo "Anyone But You (2023)" "{imdb-tt26047818} {tmdb-1072790}" "480" "480p"
createtestvideo "Argylle (2024)" "{imdb-tt15009428} {tmdb-848538}" "1080" "1080p"
createtestvideo "Wonka (2023)" "{imdb-tt6166392} {tmdb-787699}" "720" "720p"
createtestvideo "The Beekeeper (2024)" "{imdb-tt15314262} {tmdb-866398}" "576" "576p"
createtestvideo "Upgraded (2024)" "{imdb-tt21830902} {tmdb-1014590}" "480" "480p"
# IMDB Lowest
createtestvideo "3 Ninjas: High Noon at Mega Mountain (1998)" "{imdb-tt0118539} {tmdb-32302}" "4k" "2160p"
createtestvideo "365 Days (2020)" "{imdb-tt10886166} {tmdb-664413}" "1080" "1080p"
createtestvideo "Adipurush (2023)" "{imdb-tt12915716} {tmdb-734253}" "720" "720p"
createtestvideo "Alone in the Dark (2005)" "{imdb-tt0369226} {tmdb-12142}" "576" "576p"
createtestvideo "Baaghi 3 (2020)" "{imdb-tt8366590} {tmdb-594669}" "480" "480p"
createtestvideo "Baby Geniuses (1999)" "{imdb-tt0118665} {tmdb-22345}" "4k" "2160p"
createtestvideo "Barb Wire (1996)" "{imdb-tt0115624} {tmdb-11867}" "1080" "1080p"
createtestvideo "Batman & Robin (1997)" "{imdb-tt0118688} {tmdb-415}" "720" "720p"
createtestvideo "Battlefield Earth (2000)" "{imdb-tt0185183} {tmdb-5491}" "576" "576p"
createtestvideo "Birdemic: Shock and Terror (2010)" "{imdb-tt1316037} {tmdb-40016}" "480" "480p"

