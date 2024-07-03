#!/bin/bash

docker pull linuxserver/ffmpeg

select_random() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}

# If you want a wider range of languages, rename this to "languages"
more_languages=("ara" "bul" "ces" "chi" "dan" "fas" "fra" "ger" "hin" "hun" "isl" "ita" "jpn" "kor" "nld" "nor" "pol" "por" "rus" "spa" "swe" "tel" "tha" "tur" "ukr" )
# and this to anything that is not "languages"
languages=("fra" "ger" "jpn"  "por" "spa")
# and add those languages to your kometa config [see readme]

sources=("Bluray" "Remux" "WEBDL" "WEBRIP" "HDTV" "DVD")
resolutions=("2160p" "1080p" "720p" "576p" "480p" "360p" "240p")
editions=("-{edition-Extended-Edition}" "-{edition-Uncut-Edition}" "-{edition-Unrated-Edition}" "-{edition-Special-Edition}" "-{edition-Anniversary-Edition}" "-{edition-Collectors-Edition}" "-{edition-Diamond-Edition}" "-{edition-Platinum-Edition}" "-{edition-Directors-Cut}" "-{edition-Final-Cut}" "-{edition-International-Cut}" "-{edition-Theatrical-Cut}" "-{edition-Ultimate-Cut}" "-{edition-Alternate-Cut}" "-{edition-Coda-Cut}" "-{edition-IMAX-Enhanced}" "-{edition-IMAX}" "-{edition-Remastered}" "-{edition-Criterion}" "-{edition-Richard-Donner}" "-{edition-Black-And-Chrome}" "-{edition-Definitive}" "-{edition-Ulysses}")
all_audios=("truehd_atmos" "dtsx" "plus_atmos" "dolby_atmos" "truehd" "ma" "flac" "pcm" "hra" "plus" "dtses" "dts" "digital" "aac" "mp3" "opus")
# simple_audios=("flac" "aac" "mp3" "opus")
simple_audios=("aac")

cur_edition=""
cur_src=$(select_random "${sources[@]}")
cur_res=$(select_random "${resolutions[@]}")
cur_sub1=$(select_random "${languages[@]}")
cur_sub2=$(select_random "${languages[@]}")
cur_aud1=$(select_random "${languages[@]}")
cur_aud2=$(select_random "${languages[@]}")

get_random_langs () {
    cur_sub1=$(select_random "${languages[@]}")
    cur_sub2=$(select_random "${languages[@]}")
    while [[ "$cur_sub2" == "$cur_sub1" ]]
    do
        cur_sub2=$(select_random "${languages[@]}")
    done

    cur_aud1=$(select_random "${languages[@]}")
    cur_aud2=$(select_random "${languages[@]}")
    while [[ "$cur_aud2" == "$cur_aud1" ]]
    do
        cur_aud2=$(select_random "${languages[@]}")
    done
    echo "subtitle 1: $cur_sub1 subtitle 2: $cur_sub2 audio 1: $cur_aud1 audio 2: $cur_aud2"
}

get_random_edition () {
    cur_edition=$(select_random "${editions[@]}")
}

change_edition () {
    cur_edition=""
    [[ $(shuf -i 1-10 -n 1) == 1 ]] && get_random_edition
}

getnextsource () {
    if [ "$1" = 'Bluray' ]
    then
        cur_src='Remux'
    fi
    if [ "$1" = 'Remux' ]
    then
        cur_src='WEBDL'
    fi
    if [ "$1" = 'WEBDL' ]
    then
        cur_src='WEBRIP'
    fi
    if [ "$1" = 'WEBRIP' ]
    then
        cur_src='HDTV'
    fi
    if [ "$1" = 'HDTV' ]
    then
        cur_src='DVD'
    fi
    if [ "$1" = 'DVD' ]
    then
        cur_src='Bluray'
    fi
}

getnextresolution () {
    if [ "$1" = '2160p' ]
    then
        cur_res='1080p'
    fi
    if [ "$1" = '1080p' ]
    then
        cur_res='720p'
    fi
    if [ "$1" = '720p' ]
    then
        cur_res='576p'
    fi
    if [ "$1" = '576p' ]
    then
        cur_res='480p'
    fi
    if [ "$1" = '480p' ]
    then
        cur_res='360p'
    fi
    if [ "$1" = '360p' ]
    then
        cur_res='240p'
    fi
    if [ "$1" = '240p' ]
    then
        cur_res='2160p'
    fi
}

getrandomsource () {
    cur_src=$(select_random "${sources[@]}")
}

getrandomresolution () {
    cur_res=$(select_random "${resolutions[@]}")
}

randomizeall () {
    getrandomresolution
    getrandomsource
    change_edition
    get_random_langs
}
# At least two comedy movies released since 2012.
# At least two movies from the IMDB top 250.
# At least two movies from IMDB's Popular list.
# At least two movies from IMDB's Lowest Rated.
# A couple different resolutions among the movies.

createsubs () {
    cp subs/base.srt subs/sub.enu.srt
    for l in "${languages[@]}"
    do
        FILE="subs/sub.$l.srt"
        if [ -f $FILE ]; then
            echo "File $FILE exists."
        else
            echo "Creating $FILE..."
            cp subs/base.srt subs/sub.$l.srt
        fi
    done
}

createsubs

createaudiofiles () {
    for l in "${languages[@]}"
    do
        for f in "${simple_audios[@]}"
        do
            FILE="1-min-audio-$l.$f"
            if [ -f sounds/$FILE ]; then
                echo "File sounds/$FILE exists."
            else
                echo "Creating $FILE..."
                docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -stats -y -i /config/sounds/1-min-audio.m4a -metadata:s:a:0 language=$l /config/sounds/$FILE
            fi
        done
    done
}

createaudiofiles

createbasevideo () {
    FILE="$1.mp4"
    if [ -f $FILE ]; then
        echo "File $FILE exists."
    else
        echo "Creating $FILE..."
        docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -stats -loop 1 -i /config/testpattern.png -c:v libx264 -t 60 -pix_fmt yuv420p -vf scale=$2 /config/tmp.mp4
        docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -stats -i "/config/tmp.mp4" -i /config/sounds/1-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 /config/$FILE
        rm -f tmp.mp4
        echo "$FILE created"
        echo "==================="
    fi
}

createbasevideo '2160p' '3840:2160'
createbasevideo '1080p' '1920:1080'
createbasevideo '720p' '1280:720'
createbasevideo '576p' '1024:576'
createbasevideo '480p' '854:480'
createbasevideo '360p' '640:360'
createbasevideo '240p' '428:240'


createtestvideo () {
    randomizeall
    mkdir -p "test_movie_lib/$1$cur_edition"
    echo "creating $1 [$cur_src-$cur_res H264 AAC 2.0]-BINGBANG$cur_edition.mkv"
    docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg \
    -y -stats -i "/config/$cur_res.mp4" \
    -i "/config/subs/sub.enu.srt" \
    -i "/config/subs/sub.$cur_sub1.srt" \
    -i "/config/subs/sub.$cur_sub2.srt" \
    -i "/config/sounds/1-min-audio-$cur_aud1.aac" \
    -i "/config/sounds/1-min-audio-$cur_aud2.aac" \
    -c copy \
    -map 0 -dn -map "-0:s" -map "-0:d" \
    -map "1:0" "-metadata:s:s:0" "language=eng" "-metadata:s:s:0" "handler_name=English"  "-metadata:s:s:0" "title=English" \
    -map "2:0" "-metadata:s:s:1" "language=$cur_sub1" "-metadata:s:s:1" "handler_name=$cur_sub1" "-metadata:s:s:1" "title=$cur_sub1" \
    -map "3:0" "-metadata:s:s:2" "language=$cur_sub2" "-metadata:s:s:2" "handler_name=$cur_sub2" "-metadata:s:s:2" "title=$cur_sub2" \
    -map "4:0" "-metadata:s:a:1" "language=$cur_aud1" "-metadata:s:a:1" "handler_name=$cur_aud1" "-metadata:s:a:1" "title=$cur_aud1" \
    -map "5:0" "-metadata:s:a:2" "language=$cur_aud2" "-metadata:s:a:2" "handler_name=$cur_aud2" "-metadata:s:a:2" "title=$cur_aud2" \
    "/config/test_movie_lib/$1$cur_edition/$1 [$cur_src-$cur_res H264 AAC 2.0]-BINGBANG$cur_edition.mkv"
}

# Comedy after 2012
createtestvideo "21 Jump Street (2012) {imdb-tt1232829}" # comedy
createtestvideo "22 Jump Street (2014) {imdb-tt2294449}" # comedy
createtestvideo "About Time (2013) {imdb-tt2194499}" # comedy
createtestvideo "Ant-Man (2015) {imdb-tt0478970}" # comedy
createtestvideo "Ant-Man and the Wasp (2018) {imdb-tt5095030}" # comedy
createtestvideo "Barbie (2023) {imdb-tt1517268}" # comedy
createtestvideo "Big Hero 6 (2014) {imdb-tt2245084}" # comedy
createtestvideo "The Big Short (2015) {imdb-tt1596363}" # comedy
createtestvideo "Birdman or (The Unexpected Virtue of Ignorance) (2014) {imdb-tt2562232}" # comedy
createtestvideo "Brave (2012) {imdb-tt1217209}" # comedy
createtestvideo "Bullet Train (2022) {imdb-tt12593682}" # comedy
createtestvideo "Deadpool (2016) {imdb-tt1431045} {tmdb-293660}" # comedy
createtestvideo "Deadpool 2 (2018) {imdb-tt5463162} {tmdb-383498}" # comedy
createtestvideo "Despicable Me 2 (2013) {imdb-tt1690953}" # comedy
createtestvideo "Don't Look Up (2021) {imdb-tt11286314}" # comedy
createtestvideo "Everything Everywhere All at Once (2022) {imdb-tt6710474} {tmdb-545611}" # comedy
createtestvideo "Free Guy (2021) {imdb-tt6264654}" # comedy
createtestvideo "Frozen (2013) {imdb-tt2294629}" # comedy
createtestvideo "Glass Onion (2022) {imdb-tt11564570}" # comedy
createtestvideo "The Grand Budapest Hotel (2014) {imdb-tt2278388}" # comedy
createtestvideo "Green Book (2018) {imdb-tt6966692} {tmdb-490132}" # comedy
createtestvideo "Guardians of the Galaxy (2014) {imdb-tt2015381}" # comedy
createtestvideo "Guardians of the Galaxy Vol. 2 (2017) {imdb-tt3896198}" # comedy
createtestvideo "Guardians of the Galaxy Vol. 3 (2023) {imdb-tt6791350} {tmdb-447365}" # comedy
createtestvideo "The Holdovers (2023) {imdb-tt14849194} {tmdb-840430}" # comedy
createtestvideo "Inside Out (2015) {imdb-tt2096673}" # comedy
createtestvideo "Jojo Rabbit (2019) {imdb-tt2584384}" # comedy
createtestvideo "Jumanji: Welcome to the Jungle (2017) {imdb-tt2283362}" # comedy
createtestvideo "Kingsman: The Secret Service (2014) {imdb-tt2802144}" # comedy
createtestvideo "Knives Out (2019) {imdb-tt8946378} {tmdb-546554}" # comedy
createtestvideo "La La Land (2016) {imdb-tt3783958} {tmdb-313369}" # comedy
createtestvideo "The Lego Movie (2014) {imdb-tt1490017}" # comedy
createtestvideo "Men in Black³ (2012) {imdb-tt1409024}" # comedy
createtestvideo "The Menu (2022) {imdb-tt9764362}" # comedy
createtestvideo "Moana (2016) {imdb-tt3521164}" # comedy
createtestvideo "Monsters University (2013) {imdb-tt1453405}" # comedy
createtestvideo "Once Upon a Time... in Hollywood (2019) {imdb-tt7131622} {tmdb-466272}" # comedy
createtestvideo "Shazam! (2019) {imdb-tt0448115}" # comedy
createtestvideo "Silver Linings Playbook (2012) {imdb-tt1045658}" # comedy
createtestvideo "Soul (2020) {imdb-tt2948372}" # comedy
createtestvideo "Spider-Man: Far from Home (2019) {imdb-tt6320628}" # comedy
createtestvideo "Spider-Man: Into the Spider-Verse (2018) {imdb-tt4633694}" # comedy
createtestvideo "The Suicide Squad (2021) {imdb-tt6334354}" # comedy
createtestvideo "Ted (2012) {imdb-tt1637725}" # comedy
createtestvideo "This Is the End (2013) {imdb-tt1245492}" # comedy
createtestvideo "Thor: Love and Thunder (2022) {imdb-tt10648342}" # comedy
createtestvideo "Thor: Ragnarok (2017) {imdb-tt3501632}" # comedy
createtestvideo "Three Billboards Outside Ebbing, Missouri (2017) {imdb-tt5027774}" # comedy
createtestvideo "We're the Millers (2013) {imdb-tt1723121}" # comedy
createtestvideo "The Wolf of Wall Street (2013) {imdb-tt0993846} {tmdb-106646}" # comedy
createtestvideo "Wreck-It Ralph (2012) {imdb-tt1772341}" # comedy

# IMDB Lowest
createtestvideo "3 Ninjas: High Noon at Mega Mountain (1998) {imdb-tt0118539} {tmdb-32302}" # imdb lowest
createtestvideo "365 Days (2020) {imdb-tt10886166} {tmdb-664413}" # imdb lowest
createtestvideo "365 Days: This Day (2022) {imdb-tt12996154}" # imdb lowest
createtestvideo "Adipurush (2023) {imdb-tt12915716} {tmdb-734253}" # imdb lowest
createtestvideo "The Adventures of Sharkboy and Lavagirl 3-D (2005) {imdb-tt0424774}" # imdb lowest
createtestvideo "Alone in the Dark (2005) {imdb-tt0369226} {tmdb-12142}" # imdb lowest
createtestvideo "Baaghi 3 (2020) {imdb-tt8366590} {tmdb-594669}" # imdb lowest
createtestvideo "Baby Geniuses (1999) {imdb-tt0118665} {tmdb-22345}" # imdb lowest
createtestvideo "Barb Wire (1996) {imdb-tt0115624} {tmdb-11867}" # imdb lowest
createtestvideo "Batman & Robin (1997) {imdb-tt0118688} {tmdb-415}" # imdb lowest
createtestvideo "Battlefield Earth (2000) {imdb-tt0185183} {tmdb-5491}" # imdb lowest
createtestvideo "Birdemic: Shock and Terror (2010) {imdb-tt1316037} {tmdb-40016}" # imdb lowest
createtestvideo "BloodRayne (2005) {imdb-tt0383222}" # imdb lowest
createtestvideo "Cats (2019) {imdb-tt5697572}" # imdb lowest
createtestvideo "Catwoman (2004) {imdb-tt0327554}" # imdb lowest
createtestvideo "Cosmic Sin (2021) {imdb-tt11762434}" # imdb lowest
createtestvideo "Crossroads (2002) {imdb-tt0275022}" # imdb lowest
createtestvideo "Date Movie (2006) {imdb-tt0466342}" # imdb lowest
createtestvideo "Disaster Movie (2008) {imdb-tt1213644}" # imdb lowest
createtestvideo "Dragonball Evolution (2009) {imdb-tt1098327}" # imdb lowest
createtestvideo "Dungeons & Dragons (2000) {imdb-tt0190374}" # imdb lowest
createtestvideo "The Emoji Movie (2017) {imdb-tt4877122}" # imdb lowest
createtestvideo "Epic Movie (2007) {imdb-tt0799949}" # imdb lowest
createtestvideo "The Flintstones in Viva Rock Vegas (2000) {imdb-tt0158622}" # imdb lowest
createtestvideo "The Fog (2005) {imdb-tt0432291}" # imdb lowest
createtestvideo "Gigli (2003) {imdb-tt0299930}" # imdb lowest
createtestvideo "The Hottie & the Nottie (2008) {imdb-tt0804492}" # imdb lowest
createtestvideo "The Human Centipede 2 (Full Sequence) (2011) {imdb-tt1530509}" # imdb lowest
createtestvideo "The Human Centipede III (Final Sequence) (2015) {imdb-tt1883367}" # imdb lowest
createtestvideo "I Know Who Killed Me (2007) {imdb-tt0897361}" # imdb lowest
createtestvideo "In the Name of the King: A Dungeon Siege Tale (2007) {imdb-tt0460780}" # imdb lowest
createtestvideo "Jack and Jill (2011) {imdb-tt0810913}" # imdb lowest
createtestvideo "Jaws 3-D (1983) {imdb-tt0085750}" # imdb lowest
createtestvideo "Jaws: The Revenge (1987) {imdb-tt0093300}" # imdb lowest
createtestvideo "Jeepers Creepers: Reborn (2022) {imdb-tt14121726}" # imdb lowest
createtestvideo "Kazaam (1996) {imdb-tt0116756}" # imdb lowest
createtestvideo "Left Behind (2014) {imdb-tt2467046}" # imdb lowest
createtestvideo "The Love Guru (2008) {imdb-tt0811138}" # imdb lowest
createtestvideo "Mac and Me (1988) {imdb-tt0095560}" # imdb lowest
createtestvideo "The Master of Disguise (2002) {imdb-tt0295427}" # imdb lowest
createtestvideo "Meet the Spartans (2008) {imdb-tt1073498}" # imdb lowest
createtestvideo "The NeverEnding Story III (1994) {imdb-tt0110647}" # imdb lowest
createtestvideo "Piranha 3DD (2012) {imdb-tt1714203}" # imdb lowest
createtestvideo "Rollerball (2002) {imdb-tt0246894}" # imdb lowest
createtestvideo "The Room (2003) {imdb-tt0368226}" # imdb lowest
createtestvideo "Scary Movie V (2013) {imdb-tt0795461}" # imdb lowest
createtestvideo "Slender Man (2018) {imdb-tt5690360}" # imdb lowest
createtestvideo "Son of the Mask (2005) {imdb-tt0362165}" # imdb lowest
createtestvideo "Spice World (1997) {imdb-tt0120185}" # imdb lowest
createtestvideo "Spy Kids 4: All the Time in the World (2011) {imdb-tt1517489}" # imdb lowest
createtestvideo "The Starving Games (2013) {imdb-tt2403029}" # imdb lowest
createtestvideo "Superman IV: The Quest for Peace (1987) {imdb-tt0094074}" # imdb lowest
createtestvideo "Texas Chainsaw Massacre: The Next Generation (1994) {imdb-tt0110978}" # imdb lowest
createtestvideo "Troll 2 (1990) {imdb-tt0105643}" # imdb lowest
createtestvideo "The Wicker Man (2006) {imdb-tt0450345}" # imdb lowest
createtestvideo "Winnie-the-Pooh: Blood and Honey (2023) {imdb-tt19623240}" # imdb lowest

# IMDB most Popular
createtestvideo "Abigail (2024) {imdb-tt27489557}" # imdb popular
createtestvideo "Amar Singh Chamkila (2024) {imdb-tt26658272}" # imdb popular
createtestvideo "Anyone But You (2023) {imdb-tt26047818} {tmdb-1072790}" # imdb popular
createtestvideo "Argylle (2024) {imdb-tt15009428} {tmdb-848538}" # imdb popular
createtestvideo "Back to Black (2024) {imdb-tt21261712}" # imdb popular
createtestvideo "Bade Miyan Chote Miyan (2024) {imdb-tt18072316}" # imdb popular
createtestvideo "The Beekeeper (2024) {imdb-tt15314262} {tmdb-866398}" # imdb popular
createtestvideo "The Bricklayer (2023) {imdb-tt2016303}" # imdb popular
createtestvideo "Challengers (2024) {imdb-tt16426418}" # imdb popular
createtestvideo "Civil War (2024) {imdb-tt17279496}" # imdb popular
createtestvideo "Damaged (2024) {imdb-tt27304026}" # imdb popular
createtestvideo "Dune (2021) {imdb-tt1160419}" # imdb popular
createtestvideo "Dune: Part One (2021) {imdb-tt1160419} {tmdb-438631}" # imdb popular
createtestvideo "The Fall Guy (2024) {imdb-tt1684562}" # imdb popular
createtestvideo "The First Omen (2024) {imdb-tt5672290}" # imdb popular
createtestvideo "The Gentlemen (2019) {imdb-tt8367814}" # imdb popular
createtestvideo "Ghostbusters: Frozen Empire (2024) {imdb-tt21235248}" # imdb popular
createtestvideo "Godzilla x Kong: The New Empire (2024) {imdb-tt14539740}" # imdb popular
createtestvideo "Immaculate (2024) {imdb-tt23137390}" # imdb popular
createtestvideo "Joker: Folie à Deux (2024) {imdb-tt11315808}" # imdb popular
createtestvideo "Kingdom of the Planet of the Apes (2024) {imdb-tt11389872}" # imdb popular
createtestvideo "Kung Fu Panda 4 (2024) {imdb-tt21692408}" # imdb popular
createtestvideo "Late Night with the Devil (2023) {imdb-tt14966898}" # imdb popular
createtestvideo "Love Lies Bleeding (2024) {imdb-tt19637052}" # imdb popular
createtestvideo "Madame Web (2024) {imdb-tt11057302} {tmdb-634492}" # imdb popular
createtestvideo "The Ministry of Ungentlemanly Warfare (2024) {imdb-tt5177120}" # imdb popular
createtestvideo "Monkey Man (2024) {imdb-tt9214772}" # imdb popular
createtestvideo "Poor Things (2023) {imdb-tt14230458} {tmdb-792307}" # imdb popular
createtestvideo "Poor Things (2023) {imdb-tt14230458}" # imdb popular
createtestvideo "Rebel Moon - Part One: A Child of Fire (2023) {imdb-tt14998742}" # imdb popular
createtestvideo "Rebel Moon - Part Two: The Scargiver (2024) {imdb-tt23137904}" # imdb popular
createtestvideo "Road House (2024) {imdb-tt3359350}" # imdb popular
createtestvideo "Saltburn (2023) {imdb-tt17351924} {tmdb-930564}" # imdb popular
createtestvideo "Scoop (2024) {imdb-tt21279806}" # imdb popular
createtestvideo "Sleeping Dogs (2024) {imdb-tt8542964}" # imdb popular
createtestvideo "Speak No Evil (2024) {imdb-tt27534307}" # imdb popular
createtestvideo "The Talented Mr. Ripley (1999) {imdb-tt0134119}" # imdb popular
createtestvideo "Transformers One (2024) {imdb-tt8864596}" # imdb popular
createtestvideo "Trap (2024) {imdb-tt26753003}" # imdb popular
createtestvideo "Upgraded (2024) {imdb-tt21830902} {tmdb-1014590}" # imdb popular
createtestvideo "Wish (2023) {imdb-tt11304740}" # imdb popular
createtestvideo "Wonka (2023) {imdb-tt6166392} {tmdb-787699}" # imdb popular
createtestvideo "The Zone of Interest (2023) {imdb-tt7160372}" # imdb popular

# IMDB Top 250
createtestvideo "12th Fail (2023) {imdb-tt23849204}" # imdb top
createtestvideo "Alien (1979) {imdb-tt0078748}" # imdb top
createtestvideo "Amadeus (1984) {imdb-tt0086879}" # imdb top
createtestvideo "American Beauty (1999) {imdb-tt0169547}" # imdb top
createtestvideo "Apocalypse Now (1979) {imdb-tt0078788}" # imdb top
createtestvideo "Avengers: Endgame (2019) {imdb-tt4154796}" # imdb top
createtestvideo "The Dark Knight (2008) {imdb-tt0468569}" # imdb top
createtestvideo "Dead Poets Society (1989) {imdb-tt0097165}" # imdb top
createtestvideo "The Departed (2006) {imdb-tt0407887}" # imdb top
createtestvideo "Django Unchained (2012) {imdb-tt1853728}" # imdb top
createtestvideo "Dune: Part Two (2024) {imdb-tt15239678}" # imdb top
createtestvideo "Fight Club (1999) {imdb-tt0137523}" # imdb top
createtestvideo "Ford v Ferrari (2019) {imdb-tt1950186}" # imdb top
createtestvideo "Forrest Gump (1994) {imdb-tt0109830}" # imdb top
createtestvideo "Gladiator (2000) {imdb-tt0172495}" # imdb top
createtestvideo "The Godfather (1972) {imdb-tt0068646}" # imdb top
createtestvideo "The Godfather Part II (1974) {imdb-tt0071562}" # imdb top
createtestvideo "Godzilla Minus One (2023) {imdb-tt23289160}" # imdb top
createtestvideo "Gone Girl (2014) {imdb-tt2267998} {tmdb-210577}" # imdb top
createtestvideo "Gone with the Wind (1939) {imdb-tt0031381}" # imdb top
createtestvideo "Good Will Hunting (1997) {imdb-tt0119217}" # imdb top
createtestvideo "Goodfellas (1990) {imdb-tt0099685}" # imdb top
createtestvideo "The Green Mile (1999) {imdb-tt0120689}" # imdb top
createtestvideo "Inception (2010) {imdb-tt1375666}" # imdb top
createtestvideo "Inglourious Basterds (2009) {imdb-tt0361748}" # imdb top
createtestvideo "Interstellar (2014) {imdb-tt0816692} {tmdb-157336}" # imdb top
createtestvideo "Joker (2019) {imdb-tt7286456} {tmdb-475557}" # imdb top
createtestvideo "Jurassic Park (1993) {imdb-tt0107290}" # imdb top
createtestvideo "Kill Bill: Vol. 1 (2003) {imdb-tt0266697}" # imdb top
createtestvideo "Léon: The Professional (1994) {imdb-tt0110413}" # imdb top
createtestvideo "The Lord of the Rings: The Fellowship of the Ring (2001) {imdb-tt0120737}" # imdb top
createtestvideo "Mad Max: Fury Road (2015) {imdb-tt1392190}" # imdb top
createtestvideo "The Matrix (1999) {imdb-tt0133093}" # imdb top
createtestvideo "No Country for Old Men (2007) {imdb-tt0477348}" # imdb top
createtestvideo "Oppenheimer (2023) {imdb-tt15398776} {tmdb-872585}" # imdb top
createtestvideo "Parasite (2019) {imdb-tt6751668}" # imdb top
createtestvideo "Pirates of the Caribbean: The Curse of the Black Pearl (2003) {imdb-tt0325980}" # imdb top
createtestvideo "The Prestige (2006) {imdb-tt0482571}" # imdb top
createtestvideo "Prisoners (2013) {imdb-tt1392214}" # imdb top
createtestvideo "Pulp Fiction (1994) {imdb-tt0110912}" # imdb top
createtestvideo "Schindler's List (1993) {imdb-tt0108052}" # imdb top
createtestvideo "Se7en (1995) {imdb-tt0114369}" # imdb top
createtestvideo "Seven Samurai (1954) {imdb-tt0047478} {tmdb-346}" # imdb top
createtestvideo "The Shawshank Redemption (1994) {imdb-tt0111161}" # imdb top
createtestvideo "The Silence of the Lambs (1991) {imdb-tt0102926}" # imdb top
createtestvideo "Snatch (2000) {imdb-tt0208092}" # imdb top
createtestvideo "Spider-Man: Across the Spider-Verse (2023) {imdb-tt9362722} {tmdb-569094}" # imdb top
createtestvideo "Spider-Man: No Way Home (2021) {imdb-tt10872600} {tmdb-634649}" # imdb top
createtestvideo "Top Gun: Maverick (2022) {imdb-tt1745960} {tmdb-361743}" # imdb top
createtestvideo "The Usual Suspects (1995) {imdb-tt0114814}" # imdb top
createtestvideo "Whiplash (2014) {imdb-tt2582802} {tmdb-244786}" # imdb top

# star trek timeline
createtestvideo "Star Trek (2009) {tmdb-13475}"
createtestvideo "Star Trek Into Darkness (2013) {tmdb-54138}"
createtestvideo "Star Trek Beyond (2016) {tmdb-188927}"

createtestvideo "Star Trek: The Motion Picture (1979) {tmdb-152}"
createtestvideo "Star Trek II: The Wrath of Khan (1982) {tmdb-154}"
createtestvideo "Star Trek III: The Search for Spock (1984) {tmdb-157}"
createtestvideo "Star Trek IV: The Voyage Home (1986) {tmdb-168}"
createtestvideo "Star Trek V: The Final Frontier (1989) {tmdb-172}"
createtestvideo "Star Trek VI: The Undiscovered Country (1991) {tmdb-174}"
createtestvideo "Star Trek: First Contact (1996) {tmdb-199}"
createtestvideo "Star Trek: Generations (1994) {tmdb-193}"
createtestvideo "Star Trek: Insurrection (1998) {tmdb-200}"
createtestvideo "Star Trek: Nemesis (2002) {tmdb-201}"

# independence day movies:
createtestvideo "Mr. Smith Goes to Washington (1939) {imdb-tt0031679}"
createtestvideo "Yankee Doodle Dandy (1942) {imdb-tt0035575}"
createtestvideo "Patton (1970) {imdb-tt0066206}"
createtestvideo "1776 (1972) {imdb-tt0068156}"

# dark-comedy test stuff
# createtestvideo "1114 (2003) {imdb-tt0331811}" # dark-comedy test
# createtestvideo "7 Reasons to Run Away (from Society) (2019) {imdb-tt7416602}" # dark-comedy test
# createtestvideo "A Clockwork Orange (1971) {imdb-tt0066921}" # dark-comedy test
# createtestvideo "A New Leaf (1971) {imdb-tt0067482}" # dark-comedy test
# createtestvideo "A Series of Unfortunate Events (2004) {imdb-tt0339291}" # dark-comedy test
# createtestvideo "A Serious Man (2009) {imdb-tt1019452}" # dark-comedy test
# createtestvideo "A Simple Favor (2018) {imdb-tt7040874}" # dark-comedy test
# createtestvideo "A Simple Plan (1998) {imdb-tt0120324}" # dark-comedy test
# createtestvideo "A Somewhat Gentle Man (2010) {imdb-tt1386683}" # dark-comedy test
# createtestvideo "Aaltra (2004) {imdb-tt0405629}" # dark-comedy test
# createtestvideo "Adam's Apples (2005) {imdb-tt0418455}" # dark-comedy test
# createtestvideo "Adaptation. (2002) {imdb-tt0268126}" # dark-comedy test
# createtestvideo "After Hours (1985) {imdb-tt0088680}" # dark-comedy test
# createtestvideo "Airplane II The Sequel (1982) {imdb-tt0083530}" # dark-comedy test
# createtestvideo "Airplane! (1980) {imdb-tt0080339}" # dark-comedy test
# createtestvideo "Airport (1970) {imdb-tt0065377}" # dark-comedy test
# createtestvideo "Ali's Wedding (2017) {imdb-tt2782692}" # dark-comedy test
# createtestvideo "All for Two (2013) {imdb-tt2188655}" # dark-comedy test
# createtestvideo "All Is Bright (2013) {imdb-tt1462901}" # dark-comedy test
# createtestvideo "American Fiction (2023) {imdb-tt23561236}" # dark-comedy test
# createtestvideo "American Psycho (2000) {imdb-tt0144084}" # dark-comedy test
# createtestvideo "An American Werewolf in London (1981) {imdb-tt0082010}" # dark-comedy test
# createtestvideo "Animal (2023) {imdb-tt13751694}" # dark-comedy test
# createtestvideo "Another Round (2020) {imdb-tt10288566}" # dark-comedy test
# createtestvideo "Arachnophobia (1990) {imdb-tt0099052}" # dark-comedy test
# createtestvideo "Arsenic and Old Lace (1944) {imdb-tt0036613}" # dark-comedy test
# createtestvideo "Art School Confidential (2006) {imdb-tt0364955}" # dark-comedy test
# createtestvideo "Att angöra en brygga (1965) {imdb-tt0058926}" # dark-comedy test
# createtestvideo "Attack of the Killer Tomatoes! (1978) {imdb-tt0080391}" # dark-comedy test
# createtestvideo "Bad Boy Bubby (1993) {imdb-tt0106341}" # dark-comedy test
# createtestvideo "Bad Santa (2003) {imdb-tt0307987}" # dark-comedy test
# createtestvideo "Bad Teacher (2011) {imdb-tt1284575}" # dark-comedy test
# createtestvideo "Barton Fink (1991) {imdb-tt0101410}" # dark-comedy test
# createtestvideo "Basic Instinct (1992) {imdb-tt0103772}" # dark-comedy test
# createtestvideo "Baxter (1989) {imdb-tt0094713}" # dark-comedy test
# createtestvideo "Beau Is Afraid (2023) {imdb-tt13521006}" # dark-comedy test
# createtestvideo "Beetlejuice (1988) {imdb-tt0094721}" # dark-comedy test
# createtestvideo "Being John Malkovich (1999) {imdb-tt0120601}" # dark-comedy test
# createtestvideo "Bernie (2011) {imdb-tt1704573}" # dark-comedy test
# createtestvideo "Better Living Through Chemistry (2014) {imdb-tt1609479}" # dark-comedy test
# createtestvideo "Better Off Dead (1985) {imdb-tt0088794}" # dark-comedy test
# createtestvideo "Big Nothing (2006) {imdb-tt0488085}" # dark-comedy test
# createtestvideo "Birds of Prey (2020) {imdb-tt7713068}" # dark-comedy test
# createtestvideo "Black Sheep (2006) {imdb-tt0779982}" # dark-comedy test
# createtestvideo "BlacKkKlansman (2018) {imdb-tt7349662}" # dark-comedy test
# createtestvideo "Bodies Bodies Bodies (2022) {imdb-tt8110652}" # dark-comedy test
# createtestvideo "Borat (2006) {imdb-tt0443453}" # dark-comedy test
# createtestvideo "Border (2018) {imdb-tt5501104}" # dark-comedy test
# createtestvideo "Bottle Rocket (1996) {imdb-tt0115734}" # dark-comedy test
# createtestvideo "Bottoms (2023) {imdb-tt17527468}" # dark-comedy test
# createtestvideo "Boy Kills World (2023) {imdb-tt13923084}" # dark-comedy test
# createtestvideo "Brazil (1985) {imdb-tt0088846}" # dark-comedy test
# createtestvideo "Breaking News in Yuba County (2021) {imdb-tt7737640}" # dark-comedy test
# createtestvideo "Broken Flowers (2005) {imdb-tt0412019}" # dark-comedy test
# createtestvideo "Buba (2022) {imdb-tt21195548}" # dark-comedy test
# createtestvideo "Buffet Froid (1979) {imdb-tt0078913}" # dark-comedy test
# createtestvideo "Buffy the Vampire Slayer (1992) {imdb-tt0103893}" # dark-comedy test
# createtestvideo "Burn After Reading (2008) {imdb-tt0887883}" # dark-comedy test
# createtestvideo "But I'm a Cheerleader (1999) {imdb-tt0179116}" # dark-comedy test
# createtestvideo "Can You Ever Forgive Me? (2018) {imdb-tt4595882}" # dark-comedy test
# createtestvideo "Catch-22 (1970) {imdb-tt0065528}" # dark-comedy test
# createtestvideo "Catfight (2016) {imdb-tt5294198}" # dark-comedy test
# createtestvideo "Cheap Thrills (2013) {imdb-tt2389182}" # dark-comedy test
# createtestvideo "Chungking Express (1994) {imdb-tt0109424}" # dark-comedy test
# createtestvideo "Cocaine Bear (2023) {imdb-tt14209916}" # dark-comedy test
# createtestvideo "Cold Pursuit (2019) {imdb-tt5719748}" # dark-comedy test
# createtestvideo "Colossal (2016) {imdb-tt4680182}" # dark-comedy test
# createtestvideo "Comic Book Villains (2002) {imdb-tt0287969}" # dark-comedy test
# createtestvideo "Control (2003) {imdb-tt0373981}" # dark-comedy test
# createtestvideo "Cottage Country (2013) {imdb-tt2072933}" # dark-comedy test
# createtestvideo "Crank High Voltage (2009) {imdb-tt1121931}" # dark-comedy test
# createtestvideo "Crimes and Misdemeanors (1989) {imdb-tt0097123}" # dark-comedy test
# createtestvideo "Cruella (2021) {imdb-tt3228774}" # dark-comedy test
# createtestvideo "Dark Shadows (2012) {imdb-tt1077368}" # dark-comedy test
# createtestvideo "Day Shift (2022) {imdb-tt13314558}" # dark-comedy test
# createtestvideo "Dead Alive (1992) {imdb-tt0103873}" # dark-comedy test
# createtestvideo "Dead Fish (2005) {imdb-tt0379240}" # dark-comedy test
# createtestvideo "Dead in a Week Or Your Money Back (2018) {imdb-tt3525168}" # dark-comedy test
# createtestvideo "Dead Snow (2009) {imdb-tt1278340}" # dark-comedy test
# createtestvideo "Death at a Funeral (2007) {imdb-tt0795368}" # dark-comedy test
# createtestvideo "Death at a Funeral (2010) {imdb-tt1321509}" # dark-comedy test
# createtestvideo "Death Becomes Her (1992) {imdb-tt0104070}" # dark-comedy test
# createtestvideo "Death Proof (2007) {imdb-tt1028528}" # dark-comedy test
# createtestvideo "Death Race 2000 (1975) {imdb-tt0072856}" # dark-comedy test
# createtestvideo "Deathtrap (1982) {imdb-tt0083806}" # dark-comedy test
# createtestvideo "Delicatessen (1991) {imdb-tt0101700}" # dark-comedy test
# createtestvideo "District 9 (2009) {imdb-tt1136608}" # dark-comedy test
# createtestvideo "Do Revenge (2022) {imdb-tt13327038}" # dark-comedy test
# createtestvideo "Dogma (1999) {imdb-tt0120655}" # dark-comedy test
# createtestvideo "Dogs Don't Wear Pants (2019) {imdb-tt9074574}" # dark-comedy test
# createtestvideo "Don't Tell Mom the Babysitter's Dead (1991) {imdb-tt0101757}" # dark-comedy test
# createtestvideo "Double Jeopardy (1999) {imdb-tt0150377}" # dark-comedy test
# createtestvideo "Dr. Strangelove or How I Learned to Stop Worrying and Love the Bomb (1964) {imdb-tt0057012}" # dark-comedy test
# createtestvideo "Drag Me to Hell (2009) {imdb-tt1127180}" # dark-comedy test
# createtestvideo "Dream Scenario (2023) {imdb-tt21942866}" # dark-comedy test
# createtestvideo "Drop Dead Gorgeous (1999) {imdb-tt0157503}" # dark-comedy test
# createtestvideo "Drop Dead Sexy (2005) {imdb-tt0397401}" # dark-comedy test
# createtestvideo "Drowning Mona (2000) {imdb-tt0186045}" # dark-comedy test
# createtestvideo "Duplex (2003) {imdb-tt0266489}" # dark-comedy test
# createtestvideo "Eating Raoul (1982) {imdb-tt0083869}" # dark-comedy test
# createtestvideo "Ed Wood (1994) {imdb-tt0109707}" # dark-comedy test
# createtestvideo "Election (1999) {imdb-tt0126886}" # dark-comedy test
# createtestvideo "Eraserhead (1977) {imdb-tt0074486}" # dark-comedy test
# createtestvideo "Everybody Hates Johan (2022) {imdb-tt15466426}" # dark-comedy test
# createtestvideo "Falling Sky (2002) {imdb-tt0339149}" # dark-comedy test
# createtestvideo "Fantasy Island (2020) {imdb-tt0983946}" # dark-comedy test
# createtestvideo "Fargo (1996) {imdb-tt0116282}" # dark-comedy test
# createtestvideo "Fast Food Nation (2006) {imdb-tt0460792}" # dark-comedy test
# createtestvideo "Fear and Loathing in Las Vegas (1998) {imdb-tt0120669}" # dark-comedy test
# createtestvideo "Focus (2015) {imdb-tt2381941}" # dark-comedy test
# createtestvideo "Force Majeure (2014) {imdb-tt2121382}" # dark-comedy test
# createtestvideo "Four Lions (2010) {imdb-tt1341167}" # dark-comedy test
# createtestvideo "Four Rooms (1995) {imdb-tt0113101}" # dark-comedy test
# createtestvideo "Four Weddings and a Funeral (1994) {imdb-tt0109831}" # dark-comedy test
# createtestvideo "Frank (2014) {imdb-tt1605717}" # dark-comedy test
# createtestvideo "Freaky (2020) {imdb-tt10919380}" # dark-comedy test
# createtestvideo "Free Jimmy (2006) {imdb-tt0298337}" # dark-comedy test
# createtestvideo "Fresh (2022) {imdb-tt13403046}" # dark-comedy test
# createtestvideo "Fried Green Tomatoes (1991) {imdb-tt0101921}" # dark-comedy test
# createtestvideo "From Dusk Till Dawn (1996) {imdb-tt0116367}" # dark-comedy test
# createtestvideo "Fuck Up (2012) {imdb-tt2201063}" # dark-comedy test
# createtestvideo "Fukssvansen (2001) {imdb-tt0289195}" # dark-comedy test
# createtestvideo "Game Night (2018) {imdb-tt2704998}" # dark-comedy test
# createtestvideo "Gamle mænd i nye biler (2002) {imdb-tt0246692}" # dark-comedy test
# createtestvideo "Get Out (2017) {imdb-tt5052448}" # dark-comedy test
# createtestvideo "Go (1999) {imdb-tt0139239}" # dark-comedy test
# createtestvideo "God Bless America (2011) {imdb-tt1912398}" # dark-comedy test
# createtestvideo "Golden Years (2016) {imdb-tt4362646}" # dark-comedy test
# createtestvideo "Good Bye Lenin! (2003) {imdb-tt0301357}" # dark-comedy test
# createtestvideo "Good Morning, Vietnam (1987) {imdb-tt0093105}" # dark-comedy test
# createtestvideo "Grand Theft Parsons (2003) {imdb-tt0338075}" # dark-comedy test
# createtestvideo "Gremlins (1984) {imdb-tt0087363}" # dark-comedy test
# createtestvideo "Gridlock'd (1997) {imdb-tt0119225}" # dark-comedy test
# createtestvideo "Grilled (2006) {imdb-tt0409043}" # dark-comedy test
# createtestvideo "Grindhouse (2007) {imdb-tt0462322}" # dark-comedy test
# createtestvideo "Gringo (2018) {imdb-tt3721964}" # dark-comedy test
# createtestvideo "Grosse Pointe Blank (1997) {imdb-tt0119229}" # dark-comedy test
# createtestvideo "Gummo (1997) {imdb-tt0119237}" # dark-comedy test
# createtestvideo "Gunpowder Milkshake (2021) {imdb-tt8368408}" # dark-comedy test
# createtestvideo "Hansel & Gretel Witch Hunters (2013) {imdb-tt1428538}" # dark-comedy test
# createtestvideo "Happiest Season (2020) {imdb-tt8522006}" # dark-comedy test
# createtestvideo "Happiness (1998) {imdb-tt0147612}" # dark-comedy test
# createtestvideo "Happy Death Day (2017) {imdb-tt5308322}" # dark-comedy test
# createtestvideo "Harold and Maude (1971) {imdb-tt0067185}" # dark-comedy test
# createtestvideo "Head Above Water (1993) {imdb-tt0107121}" # dark-comedy test
# createtestvideo "Head Above Water (1996) {imdb-tt0116502}" # dark-comedy test
# createtestvideo "Headhunters (2011) {imdb-tt1614989}" # dark-comedy test
# createtestvideo "Heathers (1988) {imdb-tt0097493}" # dark-comedy test
# createtestvideo "Heavy Load (2019) {imdb-tt8960572}" # dark-comedy test
# createtestvideo "Heavyweights (1995) {imdb-tt0110006}" # dark-comedy test
# createtestvideo "High Fidelity (2000) {imdb-tt0146882}" # dark-comedy test
# createtestvideo "High Plains Drifter (1973) {imdb-tt0068699}" # dark-comedy test
# createtestvideo "Highway 61 (1991) {imdb-tt0102035}" # dark-comedy test
# createtestvideo "Hitman's Wife's Bodyguard (2021) {imdb-tt8385148}" # dark-comedy test
# createtestvideo "Home Sweet Hell (2015) {imdb-tt2802136}" # dark-comedy test
# createtestvideo "Horrible Bosses (2011) {imdb-tt1499658}" # dark-comedy test
# createtestvideo "Hot Fuzz (2007) {imdb-tt0425112}" # dark-comedy test
# createtestvideo "How to Be a Serial Killer (2008) {imdb-tt1038971}" # dark-comedy test
# createtestvideo "Howard the Duck (1986) {imdb-tt0091225}" # dark-comedy test
# createtestvideo "Hunt for the Wilderpeople (2016) {imdb-tt4698684}" # dark-comedy test
# createtestvideo "Hysteria (2011) {imdb-tt1435513}" # dark-comedy test
# createtestvideo "I Care a Lot (2020) {imdb-tt9893250}" # dark-comedy test
# createtestvideo "I Don't Feel at Home in This World Anymore (2017) {imdb-tt5710514}" # dark-comedy test
# createtestvideo "I Really Hate My Job (2007) {imdb-tt0831299}" # dark-comedy test
# createtestvideo "I, Tonya (2017) {imdb-tt5580036}" # dark-comedy test
# createtestvideo "I'm Thinking of Ending Things (2020) {imdb-tt7939766}" # dark-comedy test
# createtestvideo "Idiocracy (2006) {imdb-tt0387808}" # dark-comedy test
# createtestvideo "Idle Hands (1999) {imdb-tt0138510}" # dark-comedy test
# createtestvideo "Igby Goes Down (2002) {imdb-tt0280760}" # dark-comedy test
# createtestvideo "In Bruges (2008) {imdb-tt0780536}" # dark-comedy test
# createtestvideo "In Order of Disappearance (2014) {imdb-tt2675914}" # dark-comedy test
# createtestvideo "In the Loop (2009) {imdb-tt1226774}" # dark-comedy test
# createtestvideo "Ingrid Goes West (2017) {imdb-tt5962210}" # dark-comedy test
# createtestvideo "Inherent Vice (2014) {imdb-tt1791528}" # dark-comedy test
# createtestvideo "Intolerable Cruelty (2003) {imdb-tt0138524}" # dark-comedy test
# createtestvideo "Jack Be Nimble (1993) {imdb-tt0107242}" # dark-comedy test
# createtestvideo "Jackie Brown (1997) {imdb-tt0119396}" # dark-comedy test
# createtestvideo "Jackpot (2011) {imdb-tt1809231}" # dark-comedy test
# createtestvideo "Jonny Vang (2003) {imdb-tt0355611}" # dark-comedy test
# createtestvideo "Joy Ride (2001) {imdb-tt0206314}" # dark-comedy test
# createtestvideo "Judas Kiss (1998) {imdb-tt0138541}" # dark-comedy test
# createtestvideo "Just Buried (2007) {imdb-tt0906326}" # dark-comedy test
# createtestvideo "Kick-Ass (2010) {imdb-tt1250777}" # dark-comedy test
# createtestvideo "Kill Buljo 2 (2013) {imdb-tt2366131}" # dark-comedy test
# createtestvideo "Kill Buljo The Movie (2007) {imdb-tt0913401}" # dark-comedy test
# createtestvideo "Kill Me Three Times (2014) {imdb-tt2393845}" # dark-comedy test
# createtestvideo "Killer Joe (2011) {imdb-tt1726669}" # dark-comedy test
# createtestvideo "Killer Klowns from Outer Space (1988) {imdb-tt0095444}" # dark-comedy test
# createtestvideo "Killers Anonymous (2019) {imdb-tt8400758}" # dark-comedy test
# createtestvideo "Kind Hearts and Coronets (1949) {imdb-tt0041546}" # dark-comedy test
# createtestvideo "King of New York (1990) {imdb-tt0099939}" # dark-comedy test
# createtestvideo "Kingpin (1996) {imdb-tt0116778}" # dark-comedy test
# createtestvideo "Kiss Kiss Bang Bang (2005) {imdb-tt0373469}" # dark-comedy test
# createtestvideo "Koko-di Koko-da (2019) {imdb-tt9355200}" # dark-comedy test
# createtestvideo "Kunsten å tenke negativt (2006) {imdb-tt0945356}" # dark-comedy test
# createtestvideo "LaRoy, Texas (2023) {imdb-tt20102596}" # dark-comedy test
# createtestvideo "Lars and the Real Girl (2007) {imdb-tt0805564}" # dark-comedy test
# createtestvideo "Life of Brian (1979) {imdb-tt0079470}" # dark-comedy test
# createtestvideo "Little Evil (2017) {imdb-tt2937366}" # dark-comedy test
# createtestvideo "Little Miss Sunshine (2006) {imdb-tt0449059}" # dark-comedy test
# createtestvideo "Little Shop of Horrors (1986) {imdb-tt0091419}" # dark-comedy test
# createtestvideo "Lock, Stock and Two Smoking Barrels (1998) {imdb-tt0120735}" # dark-comedy test
# createtestvideo "Louise hires a contract killer (2008) {imdb-tt1132594}" # dark-comedy test
# createtestvideo "Lucky (2011) {imdb-tt1473397}" # dark-comedy test
# createtestvideo "Lune froide (1991) {imdb-tt0102358}" # dark-comedy test
# createtestvideo "M*A*S*H (1970) {imdb-tt0066026}" # dark-comedy test
# createtestvideo "Machete (2010) {imdb-tt0985694}" # dark-comedy test
# createtestvideo "Machete Kills (2013) {imdb-tt2002718}" # dark-comedy test
# createtestvideo "Mafia! (1998) {imdb-tt0120741}" # dark-comedy test
# createtestvideo "Major Payne (1995) {imdb-tt0110443}" # dark-comedy test
# createtestvideo "Mammuth (2010) {imdb-tt1473074}" # dark-comedy test
# createtestvideo "Man Bites Dog (1992) {imdb-tt0103905}" # dark-comedy test
# createtestvideo "Man Up (2015) {imdb-tt3064298}" # dark-comedy test
# createtestvideo "Marriage Story (2019) {imdb-tt7653254}" # dark-comedy test
# createtestvideo "Mars Attacks! (1996) {imdb-tt0116996}" # dark-comedy test
# createtestvideo "Masterminds (2015) {imdb-tt2461150}" # dark-comedy test
# createtestvideo "Maximum Overdrive (1986) {imdb-tt0091499}" # dark-comedy test
# createtestvideo "May December (2023) {imdb-tt13651794}" # dark-comedy test
# createtestvideo "Me, Myself & Irene (2000) {imdb-tt0183505}" # dark-comedy test
# createtestvideo "Meet the Feebles (1989) {imdb-tt0097858}" # dark-comedy test
# createtestvideo "Memories of Murder (2003) {imdb-tt0353969}" # dark-comedy test
# createtestvideo "Memphis Belle (1990) {imdb-tt0100133}" # dark-comedy test
# createtestvideo "Men & Chicken (2015) {imdb-tt3877674}" # dark-comedy test
# createtestvideo "Menneskedyret (1995) {imdb-tt0127021}" # dark-comedy test
# createtestvideo "Midsommar (2019) {imdb-tt8772262}" # dark-comedy test
# createtestvideo "Morgan Pålsson - Världsreporter (2008) {imdb-tt1135941}" # dark-comedy test
# createtestvideo "Mystics (2003) {imdb-tt0314416}" # dark-comedy test
# createtestvideo "Naked (1993) {imdb-tt0107653}" # dark-comedy test
# createtestvideo "Natural Born Killers (1994) {imdb-tt0110632}" # dark-comedy test
# createtestvideo "Near Dark (1987) {imdb-tt0093605}" # dark-comedy test
# createtestvideo "Network (1976) {imdb-tt0074958}" # dark-comedy test
# createtestvideo "Nord (2009) {imdb-tt1252610}" # dark-comedy test
# createtestvideo "Nothing But Trouble (1991) {imdb-tt0102558}" # dark-comedy test
# createtestvideo "Novocaine (2001) {imdb-tt0234354}" # dark-comedy test
# createtestvideo "O Brother, Where Art Thou? (2000) {imdb-tt0190590}" # dark-comedy test
# createtestvideo "Office Space (1999) {imdb-tt0151804}" # dark-comedy test
# createtestvideo "One Night at McCool's (2001) {imdb-tt0203755}" # dark-comedy test
# createtestvideo "Operation Belvis Bash (2011) {imdb-tt1288367}" # dark-comedy test
# createtestvideo "Ordinary Decent Criminal (2000) {imdb-tt0160611}" # dark-comedy test
# createtestvideo "Panic Room (2002) {imdb-tt0258000}" # dark-comedy test
# createtestvideo "Paprika (2006) {imdb-tt0851578}" # dark-comedy test
# createtestvideo "Patrick (2019) {imdb-tt7618604}" # dark-comedy test
# createtestvideo "Patriots Day (2016) {imdb-tt4572514}" # dark-comedy test
# createtestvideo "Pawn Shop Chronicles (2013) {imdb-tt1741243}" # dark-comedy test
# createtestvideo "Payback (1999) {imdb-tt0120784}" # dark-comedy test
# createtestvideo "People in the Sun (2011) {imdb-tt1699140}" # dark-comedy test
# createtestvideo "Pineapple Express (2008) {imdb-tt0910936}" # dark-comedy test
# createtestvideo "Pink Flamingos (1972) {imdb-tt0069089}" # dark-comedy test
# createtestvideo "Pixie (2020) {imdb-tt10831086}" # dark-comedy test
# createtestvideo "Planet Terror (2007) {imdb-tt1077258}" # dark-comedy test
# createtestvideo "Pleasantville (1998) {imdb-tt0120789}" # dark-comedy test
# createtestvideo "Polyester (1981) {imdb-tt0082926}" # dark-comedy test
# createtestvideo "Punch-Drunk Love (2002) {imdb-tt0272338}" # dark-comedy test
# createtestvideo "Queenpins (2021) {imdb-tt9054192}" # dark-comedy test
# createtestvideo "Raising Arizona (1987) {imdb-tt0093822}" # dark-comedy test
# createtestvideo "Ravenous (1999) {imdb-tt0129332}" # dark-comedy test
# createtestvideo "Ready or Not (2019) {imdb-tt7798634}" # dark-comedy test
# createtestvideo "RED (2010) {imdb-tt1245526}" # dark-comedy test
# createtestvideo "RED 2 (2013) {imdb-tt1821694}" # dark-comedy test
# createtestvideo "Red Heat (1988) {imdb-tt0095963}" # dark-comedy test
# createtestvideo "Renfield (2023) {imdb-tt11358390}" # dark-comedy test
# createtestvideo "Repo Man (1984) {imdb-tt0087995}" # dark-comedy test
# createtestvideo "Reservoir Dogs (1992) {imdb-tt0105236}" # dark-comedy test
# createtestvideo "Results (2015) {imdb-tt3824412}" # dark-comedy test
# createtestvideo "Risky Business (1983) {imdb-tt0086200}" # dark-comedy test
# createtestvideo "RocknRolla (2008) {imdb-tt1032755}" # dark-comedy test
# createtestvideo "Rubber (2010) {imdb-tt1612774}" # dark-comedy test
# createtestvideo "Run Lola Run (1998) {imdb-tt0130827}" # dark-comedy test
# createtestvideo "Ruthless People (1986) {imdb-tt0091877}" # dark-comedy test
# createtestvideo "Sausage Party (2016) {imdb-tt1700841}" # dark-comedy test
# createtestvideo "Scouts Guide to the Zombie Apocalypse (2015) {imdb-tt1727776}" # dark-comedy test
# createtestvideo "Scream 4 (2011) {imdb-tt1262416}" # dark-comedy test
# createtestvideo "Secretary (2002) {imdb-tt0274812}" # dark-comedy test
# createtestvideo "See You Up There (2017) {imdb-tt5258850}" # dark-comedy test
# createtestvideo "Serial Mom (1994) {imdb-tt0111127}" # dark-comedy test
# createtestvideo "Seven Psychopaths (2012) {imdb-tt1931533}" # dark-comedy test
# createtestvideo "Shallow Grave (1994) {imdb-tt0111149}" # dark-comedy test
# createtestvideo "Shaun of the Dead (2004) {imdb-tt0365748}" # dark-comedy test
# createtestvideo "Shiva Baby (2020) {imdb-tt11317142}" # dark-comedy test
# createtestvideo "Sideways (2004) {imdb-tt0375063}" # dark-comedy test
# createtestvideo "Sieranevada (2016) {imdb-tt4466490}" # dark-comedy test
# createtestvideo "Sightseers (2012) {imdb-tt2023690}" # dark-comedy test
# createtestvideo "Sister Act (1992) {imdb-tt0105417}" # dark-comedy test
# createtestvideo "Skulle det dukke opp flere lik er det bare å ringe..... (1970) {imdb-tt0066385}" # dark-comedy test
# createtestvideo "Slap Shot (1977) {imdb-tt0076723}" # dark-comedy test
# createtestvideo "Small Apartments (2012) {imdb-tt1272886}" # dark-comedy test
# createtestvideo "Small Soldiers (1998) {imdb-tt0122718}" # dark-comedy test
# createtestvideo "Smokin' Aces (2006) {imdb-tt0475394}" # dark-comedy test
# createtestvideo "So I Married an Axe Murderer (1993) {imdb-tt0108174}" # dark-comedy test
# createtestvideo "Sorry to Bother You (2018) {imdb-tt5688932}" # dark-comedy test
# createtestvideo "Spring Breakers (2012) {imdb-tt2101441}" # dark-comedy test
# createtestvideo "Stay Tuned (1992) {imdb-tt0105466}" # dark-comedy test
# createtestvideo "Strigoi (2009) {imdb-tt1117636}" # dark-comedy test
# createtestvideo "Striptease (1996) {imdb-tt0117765}" # dark-comedy test
# createtestvideo "Suburbicon (2017) {imdb-tt0491175}" # dark-comedy test
# createtestvideo "Surveillance (2008) {imdb-tt0409345}" # dark-comedy test
# createtestvideo "Swingers (1996) {imdb-tt0117802}" # dark-comedy test
# createtestvideo "Synecdoche, New York (2008) {imdb-tt0383028}" # dark-comedy test
# createtestvideo "Tank Girl (1995) {imdb-tt0114614}" # dark-comedy test
# createtestvideo "Taxidermia (2006) {imdb-tt0410730}" # dark-comedy test
# createtestvideo "Teaching Mrs. Tingle (1999) {imdb-tt0133046}" # dark-comedy test
# createtestvideo "Team America World Police (2004) {imdb-tt0372588}" # dark-comedy test
# createtestvideo "Terminator 2 Judgment Day (1991) {imdb-tt0103064}" # dark-comedy test
# createtestvideo "Thank You for Smoking (2005) {imdb-tt0427944}" # dark-comedy test
# createtestvideo "The Addams Family (1991) {imdb-tt0101272}" # dark-comedy test
# createtestvideo "The Adventures of Priscilla, Queen of the Desert (1994) {imdb-tt0109045}" # dark-comedy test
# createtestvideo "The Art of Self-Defense (2019) {imdb-tt7339248}" # dark-comedy test
# createtestvideo "The Ax (2005) {imdb-tt0422015}" # dark-comedy test
# createtestvideo "The Babysitter (2017) {imdb-tt4225622}" # dark-comedy test
# createtestvideo "The Baker (2007) {imdb-tt0783234}" # dark-comedy test
# createtestvideo "The Ballad of Buster Scruggs (2018) {imdb-tt6412452}" # dark-comedy test
# createtestvideo "The Banshees of Inisherin (2022) {imdb-tt11813216}" # dark-comedy test
# createtestvideo "The Big Feast (1973) {imdb-tt0070130}" # dark-comedy test
# createtestvideo "The Big Heist (2001) {imdb-tt0287336}" # dark-comedy test
# createtestvideo "The Big Lebowski (1998) {imdb-tt0118715}" # dark-comedy test
# createtestvideo "The Big White (2005) {imdb-tt0402850}" # dark-comedy test
# createtestvideo "The Boondock Saints (1999) {imdb-tt0144117}" # dark-comedy test
# createtestvideo "The Bothersome Man (2006) {imdb-tt0808185}" # dark-comedy test
# createtestvideo "The Brand New Testament (2015) {imdb-tt3792960}" # dark-comedy test
# createtestvideo "The Burning (1981) {imdb-tt0082118}" # dark-comedy test
# createtestvideo "The Cable Guy (1996) {imdb-tt0115798}" # dark-comedy test
# createtestvideo "The Celebration (1998) {imdb-tt0154420}" # dark-comedy test
# createtestvideo "The Chumscrubber (2005) {imdb-tt0406650}" # dark-comedy test
# createtestvideo "The Cleanse (2016) {imdb-tt3734354}" # dark-comedy test
# createtestvideo "The Coffee Table (2022) {imdb-tt21874760}" # dark-comedy test
# createtestvideo "The Columnist (2019) {imdb-tt9695308}" # dark-comedy test
# createtestvideo "The Cook, the Thief, His Wife & Her Lover (1989) {imdb-tt0097108}" # dark-comedy test
# createtestvideo "The Crossing (2004) {imdb-tt0383184}" # dark-comedy test
# createtestvideo "The Dead Don't Die (2019) {imdb-tt8695030}" # dark-comedy test
# createtestvideo "The Death of Stalin (2017) {imdb-tt4686844}" # dark-comedy test
# createtestvideo "The Disaster Artist (2017) {imdb-tt3521126}" # dark-comedy test
# createtestvideo "The Family (2013) {imdb-tt2404311}" # dark-comedy test
# createtestvideo "The Family Fang (2015) {imdb-tt2097331}" # dark-comedy test
# createtestvideo "The Favourite (2018) {imdb-tt5083738}" # dark-comedy test
# createtestvideo "The Firemen's Ball (1967) {imdb-tt0061781}" # dark-comedy test
# createtestvideo "The Frighteners (1996) {imdb-tt0116365}" # dark-comedy test
# createtestvideo "The Great Dictator (1940) {imdb-tt0032553}" # dark-comedy test
# createtestvideo "The Green Butchers (2003) {imdb-tt0342492}" # dark-comedy test
# createtestvideo "The Guard (2011) {imdb-tt1540133}" # dark-comedy test
# createtestvideo "The Hamiltons (2006) {imdb-tt0443527}" # dark-comedy test
# createtestvideo "The House of Yes (1997) {imdb-tt0119324}" # dark-comedy test
# createtestvideo "The Hunt (2020) {imdb-tt8244784}" # dark-comedy test
# createtestvideo "The Husband (2013) {imdb-tt2565650}" # dark-comedy test
# createtestvideo "The Ice Harvest (2005) {imdb-tt0400525}" # dark-comedy test
# createtestvideo "The Interview (2014) {imdb-tt2788710}" # dark-comedy test
# createtestvideo "The Kid Detective (2020) {imdb-tt8980602}" # dark-comedy test
# createtestvideo "The Ladykillers (1955) {imdb-tt0048281}" # dark-comedy test
# createtestvideo "The Ladykillers (2004) {imdb-tt0335245}" # dark-comedy test
# createtestvideo "The Land of Steady Habits (2018) {imdb-tt6485928}" # dark-comedy test
# createtestvideo "The Last Supper (1995) {imdb-tt0113613}" # dark-comedy test
# createtestvideo "The Little Death (2014) {imdb-tt2785032}" # dark-comedy test
# createtestvideo "The Little Hours (2017) {imdb-tt5666304}" # dark-comedy test
# createtestvideo "The Lobster (2015) {imdb-tt3464902}" # dark-comedy test
# createtestvideo "The Men Who Stare at Goats (2009) {imdb-tt1234548}" # dark-comedy test
# createtestvideo "The Nice Guys (2016) {imdb-tt3799694}" # dark-comedy test
# createtestvideo "The Other Guys (2010) {imdb-tt1386588}" # dark-comedy test
# createtestvideo "The Perfect Host (2010) {imdb-tt1334553}" # dark-comedy test
# createtestvideo "The Ref (1994) {imdb-tt0110955}" # dark-comedy test
# createtestvideo "The Return of the Living Dead (1985) {imdb-tt0089907}" # dark-comedy test
# createtestvideo "The Rocky Horror Picture Show (1975) {imdb-tt0073629}" # dark-comedy test
# createtestvideo "The Rules of Attraction (2002) {imdb-tt0292644}" # dark-comedy test
# createtestvideo "The Rum Diary (2011) {imdb-tt0376136}" # dark-comedy test
# createtestvideo "The Simpsons Movie (2007) {imdb-tt0462538}" # dark-comedy test
# createtestvideo "The Sisters Brothers (2018) {imdb-tt4971344}" # dark-comedy test
# createtestvideo "The To Do List (2013) {imdb-tt1758795}" # dark-comedy test
# createtestvideo "The Trip (2021) {imdb-tt13109952}" # dark-comedy test
# createtestvideo "The Trouble with Harry (1955) {imdb-tt0048750}" # dark-comedy test
# createtestvideo "The Two Popes (2019) {imdb-tt8404614}" # dark-comedy test
# createtestvideo "The Visit (2015) {imdb-tt3567288}" # dark-comedy test
# createtestvideo "The Voices (2014) {imdb-tt1567437}" # dark-comedy test
# createtestvideo "The War of the Roses (1989) {imdb-tt0098621}" # dark-comedy test
# createtestvideo "The Whole Nine Yards (2000) {imdb-tt0190138}" # dark-comedy test
# createtestvideo "The Willoughbys (2020) {imdb-tt5206260}" # dark-comedy test
# createtestvideo "The Witches of Eastwick (1987) {imdb-tt0094332}" # dark-comedy test
# createtestvideo "The Wolf of Snow Hollow (2020) {imdb-tt11140488}" # dark-comedy test
# createtestvideo "The World's End (2013) {imdb-tt1213663}" # dark-comedy test
# createtestvideo "The Young Offenders (2016) {imdb-tt4714568}" # dark-comedy test
# createtestvideo "They Cloned Tyrone (2023) {imdb-tt9873892}" # dark-comedy test
# createtestvideo "Thin Ice (2011) {imdb-tt1512240}" # dark-comedy test
# createtestvideo "Thoroughbreds (2017) {imdb-tt5649108}" # dark-comedy test
# createtestvideo "Three Kings (1999) {imdb-tt0120188}" # dark-comedy test
# createtestvideo "Throw Momma from the Train (1987) {imdb-tt0094142}" # dark-comedy test
# createtestvideo "Thursday (1998) {imdb-tt0124901}" # dark-comedy test
# createtestvideo "Time Bandits (1981) {imdb-tt0081633}" # dark-comedy test
# createtestvideo "To Die For (1995) {imdb-tt0114681}" # dark-comedy test
# createtestvideo "Tough Guys Don't Dance (1987) {imdb-tt0094169}" # dark-comedy test
# createtestvideo "Trainspotting (1996) {imdb-tt0117951}" # dark-comedy test
# createtestvideo "Tremors (1990) {imdb-tt0100814}" # dark-comedy test
# createtestvideo "Triangle of Sadness (2022) {imdb-tt7322224}" # dark-comedy test
# createtestvideo "Tropic Thunder (2008) {imdb-tt0942385}" # dark-comedy test
# createtestvideo "True Romance (1993) {imdb-tt0108399}" # dark-comedy test
# createtestvideo "Tucker and Dale vs Evil (2010) {imdb-tt1465522}" # dark-comedy test
# createtestvideo "Tully (2018) {imdb-tt5610554}" # dark-comedy test
# createtestvideo "Tusk (2014) {imdb-tt3099498}" # dark-comedy test
# createtestvideo "Ugly, Dirty and Bad (1976) {imdb-tt0074252}" # dark-comedy test
# createtestvideo "Uncut Gems (2019) {imdb-tt5727208}" # dark-comedy test
# createtestvideo "Used Cars (1980) {imdb-tt0081698}" # dark-comedy test
# createtestvideo "Vacation (1983) {imdb-tt0085995}" # dark-comedy test
# createtestvideo "Velvet Buzzsaw (2019) {imdb-tt7043012}" # dark-comedy test
# createtestvideo "Very Bad Things (1998) {imdb-tt0124198}" # dark-comedy test
# createtestvideo "War Dogs (2016) {imdb-tt2005151}" # dark-comedy test
# createtestvideo "War, Inc. (2008) {imdb-tt0884224}" # dark-comedy test
# createtestvideo "Weekend at Bernie's (1989) {imdb-tt0098627}" # dark-comedy test
# createtestvideo "Welcome to the Dollhouse (1995) {imdb-tt0114906}" # dark-comedy test
# createtestvideo "Wesele (2004) {imdb-tt0420318}" # dark-comedy test
# createtestvideo "What a Way to Go! (1964) {imdb-tt0058743}" # dark-comedy test
# createtestvideo "What Ever Happened to Aunt Alice? (1969) {imdb-tt0065206}" # dark-comedy test
# createtestvideo "What We Do in the Shadows (2014) {imdb-tt3416742}" # dark-comedy test
# createtestvideo "Wild at Heart (1990) {imdb-tt0100935}" # dark-comedy test
# createtestvideo "Wild Card (2015) {imdb-tt2231253}" # dark-comedy test
# createtestvideo "Wild Men (2021) {imdb-tt11328762}" # dark-comedy test
# createtestvideo "Wild Tales (2014) {imdb-tt3011894}" # dark-comedy test
# createtestvideo "Wild Things (1998) {imdb-tt0120890}" # dark-comedy test
# createtestvideo "Withnail & I (1987) {imdb-tt0094336}" # dark-comedy test
# createtestvideo "WWW What a Wonderful World (2006) {imdb-tt0478744}" # dark-comedy test
# createtestvideo "You Can't Stop the Murders (2003) {imdb-tt0303251}" # dark-comedy test
# createtestvideo "You People (2023) {imdb-tt14826022}" # dark-comedy test
# createtestvideo "You Really Got Me (2001) {imdb-tt0268917}" # dark-comedy test
# createtestvideo "Young Frankenstein (1974) {imdb-tt0072431}" # dark-comedy test
# createtestvideo "Zombieland (2009) {imdb-tt1156398}" # dark-comedy test
# createtestvideo "Zombieland Double Tap (2019) {imdb-tt1560220}" # dark-comedy test
