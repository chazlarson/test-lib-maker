#!/bin/bash

docker pull linuxserver/ffmpeg

select_random() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}

languages=("afr" "amh" "ara" "ave" "aze" "bak" "bel" "ben" "bis" "bos" "bre" "bul" "cat" "cha" "chi" "chu" "chv" "cor" "cos" "cre" "dan" "dzo" "est" "ewe" "fij" "fin" "fra" "ger" "gla" "gle" "grn" "hat" "hin" "hrv" "hun" "ile" "ind" "ita" "jpn" "kan" "kau" "khm" "kik" "kin" "kon" "lat" "lav" "lim" "lit" "ltz" "lub" "mah" "mal" "mar" "mlg" "mlt" "mon" "ndo" "nep" "nor" "orm" "pan" "phi" "pol" "por" "pus" "rus" "sag" "san" "sin" "sme" "smo" "sna" "snd" "som" "sot" "spa" "srd" "srp" "swe" "tat" "tgk" "tgl" "tha" "tsn" "tur" "twi" "uig" "ukr" "uzb" "ven" "zha")
sources=("Bluray" "Remux" "WEBDL" "WEBRIP" "HDTV" "DVD")
resolutions=("2160p" "1080p" "720p" "576p" "480p" "360p" "240p")
editions=("-{edition-Extended-Edition}" "-{edition-Uncut-Edition}" "-{edition-Unrated-Edition}" "-{edition-Special-Edition}" "-{edition-Anniversary-Edition}" "-{edition-Collectors-Edition}" "-{edition-Diamond-Edition}" "-{edition-Platinum-Edition}" "-{edition-Directors-Cut}" "-{edition-Final-Cut}" "-{edition-International-Cut}" "-{edition-Theatrical-Cut}" "-{edition-Ultimate-Cut}" "-{edition-Alternate-Cut}" "-{edition-Coda-Cut}" "-{edition-IMAX-Enhanced}" "-{edition-IMAX}" "-{edition-Remastered}" "-{edition-Criterion}" "-{edition-Richard-Donner}" "-{edition-Black-And-Chrome}" "-{edition-Definitive}" "-{edition-Ulysses}")
all_audios=("truehd_atmos" "dtsx" "plus_atmos" "dolby_atmos" "truehd" "ma" "flac" "pcm" "hra" "plus" "dtses" "dts" "digital" "aac" "mp3" "opus")
simple_audios=("flac" "m4a" "mp3" "opus")

cur_edition=""
cur_res='2160p'
cur_src='Bluray'
cur_sub1='fra'
cur_sub2='ger'
cur_aud1='bul'
cur_aud2='cat'

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
                ffmpeg -y -i sounds/1-min-audio.m4a -metadata:s:a:0 language=$l sounds/$FILE
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
        docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -loop 1 -i /config/testpattern.png -c:v libx264 -t 60 -pix_fmt yuv420p -vf scale=$2 /config/tmp.mp4
        docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -i "/config/tmp.mp4" -i /config/sounds/1-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 /config/$FILE
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
    -y -loglevel quiet -stats -i "/config/$cur_res.mp4" \
    -i "/config/subs/sub.eng.srt" \
    -i "/config/subs/sub.$cur_sub1.srt" \
    -i "/config/subs/sub.$cur_sub2.srt" \
    -i "/config/sounds/1-min-audio-$cur_aud1.m4a" \
    -i "/config/sounds/1-min-audio-$cur_aud2.m4a" \
    -c copy \
    -map 0 -dn -map "-0:s" -map "-0:d" \
    -map "1:0" "-metadata:s:s:0" "language=eng" "-metadata:s:s:0" "handler_name=English"  "-metadata:s:s:0" "title=English" \
    -map "2:0" "-metadata:s:s:1" "language=$cur_sub1" "-metadata:s:s:1" "handler_name=$cur_sub1" "-metadata:s:s:1" "title=$cur_sub1" \
    -map "3:0" "-metadata:s:s:2" "language=$cur_sub2" "-metadata:s:s:2" "handler_name=$cur_sub2" "-metadata:s:s:2" "title=$cur_sub2" \
    -map "4:0" "-metadata:s:s:3" "language=$cur_aud1" "-metadata:s:s:2" "handler_name=$cur_aud2" "-metadata:s:s:2" "title=$cur_aud2" \
    -map "5:0" "-metadata:s:s:4" "language=$cur_aud2" "-metadata:s:s:2" "handler_name=$cur_aud2" "-metadata:s:s:2" "title=$cur_aud2" \
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
createtestvideo "Birdman or (The Unexpected Virtue of Ignorance) (2014) {imdb-tt2562232}" # comedy
createtestvideo "Brave (2012) {imdb-tt1217209}" # comedy
createtestvideo "Bullet Train (2022) {imdb-tt12593682}" # comedy
createtestvideo "Deadpool (2016) {imdb-tt1431045} {tmdb-293660}" # comedy
# createtestvideo "Deadpool (2016) {imdb-tt1431045}" # comedy
createtestvideo "Deadpool 2 (2018) {imdb-tt5463162} {tmdb-383498}" # comedy
# createtestvideo "Deadpool 2 (2018) {imdb-tt5463162}" # comedy
createtestvideo "Despicable Me 2 (2013) {imdb-tt1690953}" # comedy
createtestvideo "Don't Look Up (2021) {imdb-tt11286314}" # comedy
createtestvideo "Everything Everywhere All at Once (2022) {imdb-tt6710474} {tmdb-545611}" # comedy
# createtestvideo "Everything Everywhere All at Once (2022) {imdb-tt6710474}" # comedy
createtestvideo "Free Guy (2021) {imdb-tt6264654}" # comedy
createtestvideo "Frozen (2013) {imdb-tt2294629}" # comedy
createtestvideo "Glass Onion (2022) {imdb-tt11564570}" # comedy
createtestvideo "Green Book (2018) {imdb-tt6966692} {tmdb-490132}" # comedy
# createtestvideo "Green Book (2018) {imdb-tt6966692}" # comedy
createtestvideo "Guardians of the Galaxy (2014) {imdb-tt2015381}" # comedy
createtestvideo "Guardians of the Galaxy Vol. 2 (2017) {imdb-tt3896198}" # comedy
createtestvideo "Guardians of the Galaxy Vol. 3 (2023) {imdb-tt6791350} {tmdb-447365}" # comedy
# createtestvideo "Guardians of the Galaxy Vol. 3 (2023) {imdb-tt6791350}" # comedy
createtestvideo "Inside Out (2015) {imdb-tt2096673}" # comedy
createtestvideo "Jojo Rabbit (2019) {imdb-tt2584384}" # comedy
createtestvideo "Jumanji: Welcome to the Jungle (2017) {imdb-tt2283362}" # comedy
createtestvideo "Kingsman: The Secret Service (2014) {imdb-tt2802144}" # comedy
createtestvideo "Knives Out (2019) {imdb-tt8946378} {tmdb-546554}" # comedy
# createtestvideo "Knives Out (2019) {imdb-tt8946378}" # comedy
createtestvideo "La La Land (2016) {imdb-tt3783958} {tmdb-313369}" # comedy
# createtestvideo "La La Land (2016) {imdb-tt3783958}" # comedy
createtestvideo "Men in Black³ (2012) {imdb-tt1409024}" # comedy
createtestvideo "Moana (2016) {imdb-tt3521164}" # comedy
createtestvideo "Monsters University (2013) {imdb-tt1453405}" # comedy
createtestvideo "Once Upon a Time... in Hollywood (2019) {imdb-tt7131622} {tmdb-466272}" # comedy
# createtestvideo "Once Upon a Time... in Hollywood (2019) {imdb-tt7131622}" # comedy
createtestvideo "Shazam! (2019) {imdb-tt0448115}" # comedy
createtestvideo "Silver Linings Playbook (2012) {imdb-tt1045658}" # comedy
createtestvideo "Soul (2020) {imdb-tt2948372}" # comedy
createtestvideo "Spider-Man: Far from Home (2019) {imdb-tt6320628}" # comedy
createtestvideo "Spider-Man: Into the Spider-Verse (2018) {imdb-tt4633694}" # comedy
createtestvideo "Ted (2012) {imdb-tt1637725}" # comedy
createtestvideo "The Big Short (2015) {imdb-tt1596363}" # comedy
createtestvideo "The Grand Budapest Hotel (2014) {imdb-tt2278388}" # comedy
createtestvideo "The Holdovers (2023) {imdb-tt14849194} {tmdb-840430}" # comedy
createtestvideo "The Lego Movie (2014) {imdb-tt1490017}" # comedy
createtestvideo "The Menu (2022) {imdb-tt9764362}" # comedy
createtestvideo "The Suicide Squad (2021) {imdb-tt6334354}" # comedy
# createtestvideo "The Wolf of Wall Street (2013) {imdb-tt0993846}" # comedy
createtestvideo "The Wolf of Wall Street (2013) {imdb-tt0993846} {tmdb-106646}" # comedy
createtestvideo "This Is the End (2013) {imdb-tt1245492}" # comedy
createtestvideo "Thor: Love and Thunder (2022) {imdb-tt10648342}" # comedy
createtestvideo "Thor: Ragnarok (2017) {imdb-tt3501632}" # comedy
createtestvideo "Three Billboards Outside Ebbing, Missouri (2017) {imdb-tt5027774}" # comedy
createtestvideo "We're the Millers (2013) {imdb-tt1723121}" # comedy
createtestvideo "Wreck-It Ralph (2012) {imdb-tt1772341}" # comedy

# IMDB Lowest
createtestvideo "3 Ninjas: High Noon at Mega Mountain (1998) {imdb-tt0118539} {tmdb-32302}" # imdb lowest
createtestvideo "365 Days (2020) {imdb-tt10886166} {tmdb-664413}" # imdb lowest
createtestvideo "365 Days (2020) {imdb-tt10886166}" # imdb lowest
createtestvideo "365 Days: This Day (2022) {imdb-tt12996154}" # imdb lowest
createtestvideo "Adipurush (2023) {imdb-tt12915716} {tmdb-734253}" # imdb lowest
createtestvideo "Alone in the Dark (2005) {imdb-tt0369226} {tmdb-12142}" # imdb lowest
createtestvideo "Baaghi 3 (2020) {imdb-tt8366590} {tmdb-594669}" # imdb lowest
createtestvideo "Baby Geniuses (1999) {imdb-tt0118665} {tmdb-22345}" # imdb lowest
createtestvideo "Barb Wire (1996) {imdb-tt0115624} {tmdb-11867}" # imdb lowest
createtestvideo "Barb Wire (1996) {imdb-tt0115624}" # imdb lowest
createtestvideo "Batman & Robin (1997) {imdb-tt0118688} {tmdb-415}" # imdb lowest
createtestvideo "Batman & Robin (1997) {imdb-tt0118688}" # imdb lowest
createtestvideo "Battlefield Earth (2000) {imdb-tt0185183} {tmdb-5491}" # imdb lowest
createtestvideo "Battlefield Earth (2000) {imdb-tt0185183}" # imdb lowest
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
createtestvideo "Epic Movie (2007) {imdb-tt0799949}" # imdb lowest
createtestvideo "Gigli (2003) {imdb-tt0299930}" # imdb lowest
createtestvideo "I Know Who Killed Me (2007) {imdb-tt0897361}" # imdb lowest
createtestvideo "In the Name of the King: A Dungeon Siege Tale (2007) {imdb-tt0460780}" # imdb lowest
createtestvideo "Jack and Jill (2011) {imdb-tt0810913}" # imdb lowest
createtestvideo "Jaws 3-D (1983) {imdb-tt0085750}" # imdb lowest
createtestvideo "Jaws: The Revenge (1987) {imdb-tt0093300}" # imdb lowest
createtestvideo "Jeepers Creepers: Reborn (2022) {imdb-tt14121726}" # imdb lowest
createtestvideo "Kazaam (1996) {imdb-tt0116756}" # imdb lowest
createtestvideo "Left Behind (2014) {imdb-tt2467046}" # imdb lowest
createtestvideo "Mac and Me (1988) {imdb-tt0095560}" # imdb lowest
createtestvideo "Meet the Spartans (2008) {imdb-tt1073498}" # imdb lowest
createtestvideo "Piranha 3DD (2012) {imdb-tt1714203}" # imdb lowest
createtestvideo "Rollerball (2002) {imdb-tt0246894}" # imdb lowest
createtestvideo "Scary Movie V (2013) {imdb-tt0795461}" # imdb lowest
createtestvideo "Slender Man (2018) {imdb-tt5690360}" # imdb lowest
createtestvideo "Son of the Mask (2005) {imdb-tt0362165}" # imdb lowest
createtestvideo "Spice World (1997) {imdb-tt0120185}" # imdb lowest
createtestvideo "Spy Kids 4: All the Time in the World (2011) {imdb-tt1517489}" # imdb lowest
createtestvideo "Superman IV: The Quest for Peace (1987) {imdb-tt0094074}" # imdb lowest
createtestvideo "Texas Chainsaw Massacre: The Next Generation (1994) {imdb-tt0110978}" # imdb lowest
createtestvideo "The Adventures of Sharkboy and Lavagirl 3-D (2005) {imdb-tt0424774}" # imdb lowest
createtestvideo "The Emoji Movie (2017) {imdb-tt4877122}" # imdb lowest
createtestvideo "The Flintstones in Viva Rock Vegas (2000) {imdb-tt0158622}" # imdb lowest
createtestvideo "The Fog (2005) {imdb-tt0432291}" # imdb lowest
createtestvideo "The Hottie & the Nottie (2008) {imdb-tt0804492}" # imdb lowest
createtestvideo "The Human Centipede 2 (Full Sequence) (2011) {imdb-tt1530509}" # imdb lowest
createtestvideo "The Human Centipede III (Final Sequence) (2015) {imdb-tt1883367}" # imdb lowest
createtestvideo "The Love Guru (2008) {imdb-tt0811138}" # imdb lowest
createtestvideo "The Master of Disguise (2002) {imdb-tt0295427}" # imdb lowest
createtestvideo "The NeverEnding Story III (1994) {imdb-tt0110647}" # imdb lowest
createtestvideo "The Room (2003) {imdb-tt0368226}" # imdb lowest
createtestvideo "The Starving Games (2013) {imdb-tt2403029}" # imdb lowest
createtestvideo "The Wicker Man (2006) {imdb-tt0450345}" # imdb lowest
createtestvideo "Troll 2 (1990) {imdb-tt0105643}" # imdb lowest
createtestvideo "Winnie-the-Pooh: Blood and Honey (2023) {imdb-tt19623240}" # imdb lowest

# IMDB most Popular
createtestvideo "Abigail (2024) {imdb-tt27489557}" # imdb popular
createtestvideo "Amar Singh Chamkila (2024) {imdb-tt26658272}" # imdb popular
createtestvideo "Anyone But You (2023) {imdb-tt26047818} {tmdb-1072790}" # imdb popular
createtestvideo "Anyone But You (2023) {imdb-tt26047818}" # imdb popular
createtestvideo "Argylle (2024) {imdb-tt15009428} {tmdb-848538}" # imdb popular
createtestvideo "Argylle (2024) {imdb-tt15009428}" # imdb popular
createtestvideo "Back to Black (2024) {imdb-tt21261712}" # imdb popular
createtestvideo "Bade Miyan Chote Miyan (2024) {imdb-tt18072316}" # imdb popular
createtestvideo "Challengers (2024) {imdb-tt16426418}" # imdb popular
createtestvideo "Civil War (2024) {imdb-tt17279496}" # imdb popular
createtestvideo "Damaged (2024) {imdb-tt27304026}" # imdb popular
createtestvideo "Dune (2021) {imdb-tt1160419}" # imdb popular
createtestvideo "Dune: Part One (2021) {imdb-tt1160419} {tmdb-438631}" # imdb popular
createtestvideo "Dune: Part Two (2024) {imdb-tt15239678}" # imdb popular
createtestvideo "Ghostbusters: Frozen Empire (2024) {imdb-tt21235248}" # imdb popular
createtestvideo "Godzilla x Kong: The New Empire (2024) {imdb-tt14539740}" # imdb popular
createtestvideo "Immaculate (2024) {imdb-tt23137390}" # imdb popular
createtestvideo "Joker: Folie à Deux (2024) {imdb-tt11315808}" # imdb popular
createtestvideo "Kingdom of the Planet of the Apes (2024) {imdb-tt11389872}" # imdb popular
createtestvideo "Kung Fu Panda 4 (2024) {imdb-tt21692408}" # imdb popular
createtestvideo "Late Night with the Devil (2023) {imdb-tt14966898}" # imdb popular
createtestvideo "Love Lies Bleeding (2024) {imdb-tt19637052}" # imdb popular
createtestvideo "Madame Web (2024) {imdb-tt11057302} {tmdb-634492}" # imdb popular
createtestvideo "Monkey Man (2024) {imdb-tt9214772}" # imdb popular
# createtestvideo "Oppenheimer (2023) {imdb-tt15398776}" # imdb popular
createtestvideo "Poor Things (2023) {imdb-tt14230458} {tmdb-792307}" # imdb popular
createtestvideo "Poor Things (2023) {imdb-tt14230458}" # imdb popular
createtestvideo "Rebel Moon - Part One: A Child of Fire (2023) {imdb-tt14998742}" # imdb popular
createtestvideo "Rebel Moon - Part Two: The Scargiver (2024) {imdb-tt23137904}" # imdb popular
createtestvideo "Road House (2024) {imdb-tt3359350}" # imdb popular
createtestvideo "Saltburn (2023) {imdb-tt17351924} {tmdb-930564}" # imdb popular
createtestvideo "Scoop (2024) {imdb-tt21279806}" # imdb popular
createtestvideo "Sleeping Dogs (2024) {imdb-tt8542964}" # imdb popular
createtestvideo "Speak No Evil (2024) {imdb-tt27534307}" # imdb popular
createtestvideo "The Beekeeper (2024) {imdb-tt15314262} {tmdb-866398}" # imdb popular
createtestvideo "The Bricklayer (2023) {imdb-tt2016303}" # imdb popular
createtestvideo "The Fall Guy (2024) {imdb-tt1684562}" # imdb popular
createtestvideo "The First Omen (2024) {imdb-tt5672290}" # imdb popular
createtestvideo "The Gentlemen (2019) {imdb-tt8367814}" # imdb popular
createtestvideo "The Ministry of Ungentlemanly Warfare (2024) {imdb-tt5177120}" # imdb popular
createtestvideo "The Talented Mr. Ripley (1999) {imdb-tt0134119}" # imdb popular
createtestvideo "The Zone of Interest (2023) {imdb-tt7160372}" # imdb popular
createtestvideo "Transformers One (2024) {imdb-tt8864596}" # imdb popular
createtestvideo "Trap (2024) {imdb-tt26753003}" # imdb popular
createtestvideo "Upgraded (2024) {imdb-tt21830902} {tmdb-1014590}" # imdb popular
createtestvideo "Wish (2023) {imdb-tt11304740}" # imdb popular
createtestvideo "Wonka (2023) {imdb-tt6166392} {tmdb-787699}" # imdb popular

# IMDB Top 250
createtestvideo "12th Fail (2023) {imdb-tt23849204}" # imdb top
createtestvideo "Alien (1979) {imdb-tt0078748}" # imdb top
createtestvideo "Amadeus (1984) {imdb-tt0086879}" # imdb top
createtestvideo "American Beauty (1999) {imdb-tt0169547}" # imdb top
createtestvideo "Apocalypse Now (1979) {imdb-tt0078788}" # imdb top
createtestvideo "Avengers: Endgame (2019) {imdb-tt4154796}" # imdb top
createtestvideo "Dead Poets Society (1989) {imdb-tt0097165}" # imdb top
createtestvideo "Django Unchained (2012) {imdb-tt1853728}" # imdb top
createtestvideo "Dune: Part Two (2024) {imdb-tt15239678}" # imdb top
createtestvideo "Fight Club (1999) {imdb-tt0137523}" # imdb top
createtestvideo "Ford v Ferrari (2019) {imdb-tt1950186}" # imdb top
createtestvideo "Forrest Gump (1994) {imdb-tt0109830}" # imdb top
createtestvideo "Gladiator (2000) {imdb-tt0172495}" # imdb top
createtestvideo "Godzilla Minus One (2023) {imdb-tt23289160}" # imdb top
createtestvideo "Gone Girl (2014) {imdb-tt2267998} {tmdb-210577}" # imdb top
createtestvideo "Gone with the Wind (1939) {imdb-tt0031381}" # imdb top
createtestvideo "Good Will Hunting (1997) {imdb-tt0119217}" # imdb top
createtestvideo "Goodfellas (1990) {imdb-tt0099685}" # imdb top
# createtestvideo "Green Book (2018) {imdb-tt6966692} {tmdb-490132}" # imdb top
createtestvideo "Inception (2010) {imdb-tt1375666}" # imdb top
createtestvideo "Inglourious Basterds (2009) {imdb-tt0361748}" # imdb top
createtestvideo "Interstellar (2014) {imdb-tt0816692} {tmdb-157336}" # imdb top
# createtestvideo "Interstellar (2014) {imdb-tt0816692}" # imdb top
createtestvideo "Joker (2019) {imdb-tt7286456} {tmdb-475557}" # imdb top
# createtestvideo "Joker (2019) {imdb-tt7286456}" # imdb top
createtestvideo "Jurassic Park (1993) {imdb-tt0107290}" # imdb top
createtestvideo "Kill Bill: Vol. 1 (2003) {imdb-tt0266697}" # imdb top
createtestvideo "Léon: The Professional (1994) {imdb-tt0110413}" # imdb top
createtestvideo "Mad Max: Fury Road (2015) {imdb-tt1392190}" # imdb top
createtestvideo "No Country for Old Men (2007) {imdb-tt0477348}" # imdb top
createtestvideo "Oppenheimer (2023) {imdb-tt15398776} {tmdb-872585}" # imdb top
# createtestvideo "Oppenheimer (2023) {imdb-tt15398776}" # imdb top
createtestvideo "Parasite (2019) {imdb-tt6751668}" # imdb top
createtestvideo "Pirates of the Caribbean: The Curse of the Black Pearl (2003) {imdb-tt0325980}" # imdb top
createtestvideo "Prisoners (2013) {imdb-tt1392214}" # imdb top
createtestvideo "Pulp Fiction (1994) {imdb-tt0110912}" # imdb top
createtestvideo "Schindler's List (1993) {imdb-tt0108052}" # imdb top
createtestvideo "Se7en (1995) {imdb-tt0114369}" # imdb top
createtestvideo "Snatch (2000) {imdb-tt0208092}" # imdb top
createtestvideo "Spider-Man: Across the Spider-Verse (2023) {imdb-tt9362722} {tmdb-569094}" # imdb top
# createtestvideo "Spider-Man: Across the Spider-Verse (2023) {imdb-tt9362722}" # imdb top
createtestvideo "Spider-Man: No Way Home (2021) {imdb-tt10872600} {tmdb-634649}" # imdb top
# createtestvideo "Spider-Man: No Way Home (2021) {imdb-tt10872600}" # imdb top
createtestvideo "The Dark Knight (2008) {imdb-tt0468569}" # imdb top
createtestvideo "The Departed (2006) {imdb-tt0407887}" # imdb top
createtestvideo "The Godfather (1972) {imdb-tt0068646}" # imdb top
createtestvideo "The Godfather Part II (1974) {imdb-tt0071562}" # imdb top
createtestvideo "The Green Mile (1999) {imdb-tt0120689}" # imdb top
createtestvideo "The Lord of the Rings: The Fellowship of the Ring (2001) {imdb-tt0120737}" # imdb top
createtestvideo "The Matrix (1999) {imdb-tt0133093}" # imdb top
createtestvideo "The Prestige (2006) {imdb-tt0482571}" # imdb top
createtestvideo "The Shawshank Redemption (1994) {imdb-tt0111161}" # imdb top
createtestvideo "The Silence of the Lambs (1991) {imdb-tt0102926}" # imdb top
createtestvideo "The Usual Suspects (1995) {imdb-tt0114814}" # imdb top
# createtestvideo "The Wolf of Wall Street (2013) {imdb-tt0993846} {tmdb-106646}" # imdb top
# createtestvideo "The Wolf of Wall Street (2013) {imdb-tt0993846}" # imdb top
createtestvideo "Top Gun: Maverick (2022) {imdb-tt1745960} {tmdb-361743}" # imdb top
# createtestvideo "Top Gun: Maverick (2022) {imdb-tt1745960}" # imdb top
createtestvideo "Whiplash (2014) {imdb-tt2582802} {tmdb-244786}" # imdb top
# createtestvideo "Whiplash (2014) {imdb-tt2582802}" # imdb top
