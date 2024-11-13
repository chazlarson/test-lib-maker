#!/bin/bash

use_docker=false
ffmpeg_cmd='ffmpeg'
ffmpeg_log=true
show_create_start=true
show_create_done=true
path_prefix=''

if [ "$use_docker" = true ] ; then
    docker pull linuxserver/ffmpeg
    ffmpeg_cmd="docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg"
    path_prefix='/config/'
fi

select_random() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}

docker pull linuxserver/ffmpeg

# If you want a wider range of languages, rename this to "languages"
more_languages=("ara" "bul" "ces" "chi" "dan" "eng" "fas" "fra" "ger" "hin" "hun" "isl" "ita" "jpn" "kor" "nld" "nor" "pol" "por" "rus" "spa" "swe" "tel" "tha" "tur" "ukr" )
# and this to anything that is not "languages"
languages=("eng" "fra" "ger" "jpn"  "por" "spa")
# and add those languages to your kometa config [see readme]

sources=("Bluray" "Remux" "WEBDL" "WEBRIP" "HDTV" "DVD")
resolutions=("2160p" "1080p" "720p" "576p" "480p" "360p" "240p")
all_audios=("truehd_atmos" "dtsx" "plus_atmos" "dolby_atmos" "truehd" "ma" "flac" "pcm" "hra" "plus" "dtses" "dts" "digital" "aac" "mp3" "opus")
# simple_audios=("flac" "aac" "mp3" "opus")
simple_audios=("aac")

audiocodecs=("AAC" "AAC 1.0" "AAC 12.0" "AAC 2.0" "AAC 24.0" "AAC 2ch" "AAC 3.0" "AAC 4.0" "AAC 5.0" "AAC 5.1" "AAC 6.0" "AC3 1.0" "AC3 2.0" "AC3 2.0ch" "AC3 2.1" "AC3 2ch" "AC3 3.0" "AC3 3.1" "AC3 4.0" "AC3 4.1" "AC3 5.0" "AC3 5.1" "AC3 5.1ch" "AC3 6.0" "AC3 7.1" "AC3 Atmos 2.0" "AC3 Atmos 3.0" "AC3 Atmos 5.1" "AC3 Atmos 7.1" "AC3 Atmos 8.0" "ALAC 2.0" "Atmos 5.1" "DD 5.1" "DD2 0 TWA" "DD5.1" "DDP" "DDP 5.1" "DTS" "DTS 1.0" "DTS 2.0" "DTS 2.1" "DTS 3.0" "DTS 4.0" "DTS 5.0" "DTS 5.1" "DTS 6.0" "DTS 7.1" "DTS Express 5.1" "DTS HD MA 5 1" "DTS LBR 5.1" "DTS RB" "DTS-ES 5.1" "DTS-ES 6.0" "DTS-ES 6.1" "DTS-ES 7.1" "DTS-HD HRA 2.0" "DTS-HD HRA 5.0" "DTS-HD HRA 5.1" "DTS-HD HRA 6.1" "DTS-HD HRA 7.1" "DTS-HD HRA 8.0" "DTS-HD MA 1.0" "DTS-HD MA 2.0" "DTS-HD MA 2.1" "DTS-HD MA 3.0" "DTS-HD MA 3.1" "DTS-HD MA 4.0" "DTS-HD MA 4.1" "DTS-HD MA 5.0" "DTS-HD MA 5.1" "DTS-HD MA 6.0" "DTS-HD MA 6.1" "DTS-HD MA 7.1" "DTS-HD MA 8.0" "DTS-X 5.1" "DTS-X 7.1" "DTS-X 8.0" "DTSHD-MA 2ch" "DTSHD-MA 6ch" "DTSHD-MA 8ch" "FLAC" "FLAC 1.0" "FLAC 2.0" "FLAC 3.0" "FLAC 3.1" "FLAC 4.0" "FLAC 5.0" "FLAC 5.1" "FLAC 6.1" "FLAC 7.1" "MP2 1.0" "MP2 2.0" "MP3 1.0" "MP3 2.0" "MP3 2.0ch" "MP3 2ch" "Ogg" "Opus" "Opus 1.0" "Opus 2.0" "Opus 5.1" "Opus 7.1" "PCM 1.0" "PCM 2.0" "PCM 2ch" "PCM 3.0" "PCM 5.1" "PCM 6.0" "TrueHD 1.0" "TrueHD 2.0" "TrueHD 3.0" "TrueHD 3.1" "TrueHD 5.1" "TrueHD 6.1" "TrueHD Atmos 7.1" "Vorbis 1.0" "Vorbis 2.0" "Vorbis 6.0" "WMA 1.0" "WMA 2.0" "WMA 5.1" "WMA 6.0")

cur_src=$(select_random "${sources[@]}")
cur_res=$(select_random "${resolutions[@]}")
cur_sub1=$(select_random "${languages[@]}")
cur_sub2=$(select_random "${languages[@]}")
cur_aud1=$(select_random "${languages[@]}")
cur_aud2=$(select_random "${languages[@]}")
cur_codec=$(select_random "${audiocodecs[@]}")
cur_codec=$(select_random "${audiocodecs[@]}")

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

getrandomaudiocodec () {
    cur_codec=$(select_random "${audiocodecs[@]}")
}

randomizeall () {
    getrandomresolution
    getrandomsource
    get_random_langs
    getrandomaudiocodec
}

startnewshow () {
    getnextresolution $1
    getnextsource $2
    get_random_langs
    getrandomaudiocodec
}

createsubs () {
    cp subs/base.srt subs/sub.enu.srt
    cp subs/base.srt subs/sub.eng.srt
    for l in "${languages[@]}"
    do
        FILE="subs/sub.$l.srt"
        if [ -f $FILE ]; then
            echo "File $FILE exists."
        else
            echo "Creating $FILE..."
            cp subs/base.srt subs/sub.$l.srt
            echo "$FILE created"
            echo "==================="
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
                $ffmpeg_cmd -y -loglevel quiet -i ${path_prefix}sounds/1-min-audio.m4a -metadata:s:a:0 language=$l ${path_prefix}sounds/$FILE
                echo "$FILE created"
                echo "==================="
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
        echo "Creating $FILE... [1500 frames]"
        $ffmpeg_cmd -loglevel quiet -stats -loop 1 -i ${path_prefix}testpattern.png -c:v libx264 -t 60 -pix_fmt yuv420p -vf scale=$2 ${path_prefix}tmp.mp4
        $ffmpeg_cmd -loglevel quiet -stats -i "${path_prefix}tmp.mp4" -i ${path_prefix}sounds/1-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 ${path_prefix}$FILE
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

# $1 title with year
# $2 id string
# $3 Season number
# $4 episode number
# $5 resolution
# $6 Source

createepisode () {
    ((total_expected+=1))
    mkdir -p "test_tv_lib/$1 $2/Season $3"
    FILENAME="$1 - S$3E$4 [$cur_src-$cur_res][H264][$cur_codec]-BINGBANG.mkv"
    FOLDERPATH="test_tv_lib/$1 $2/"
    FILEPATH="$FOLDERPATH/Season $3/$FILENAME"
    
    log_path="/dev/null"

    if [ "$ffmpeg_log" = true ] ; then
        log_path="${path_prefix}${FOLDERPATH}ffmpeg-S$3E$4.log"
    fi

    if [ "$show_create_start" = true ] ; then
        echo "creating episode video file: $1 - S$3E$4 [$cur_src-$cur_res][H264][$cur_codec]-BINGBANG.mkv"
    fi

    $ffmpeg_cmd \
    -y -i "${path_prefix}$cur_res.mp4" \
    -i "${path_prefix}subs/sub.eng.srt" \
    -i "${path_prefix}subs/sub.$cur_sub1.srt" \
    -i "${path_prefix}subs/sub.$cur_sub2.srt" \
    -i "${path_prefix}sounds/1-min-audio-$cur_aud1.aac" \
    -i "${path_prefix}sounds/1-min-audio-$cur_aud2.aac" \
    -c copy \
    -map 0 -dn -map "-0:s" -map "-0:d" \
    -map "1:0" "-metadata:s:s:0" "language=eng" "-metadata:s:s:0" "handler_name=English"  "-metadata:s:s:0" "title=English" \
    -map "2:0" "-metadata:s:s:1" "language=$cur_sub1" "-metadata:s:s:1" "handler_name=$cur_sub1" "-metadata:s:s:1" "title=$cur_sub1" \
    -map "3:0" "-metadata:s:s:2" "language=$cur_sub2" "-metadata:s:s:2" "handler_name=$cur_sub2" "-metadata:s:s:2" "title=$cur_sub2" \
    -map "4:0" "-metadata:s:a:1" "language=$cur_aud1" "-metadata:s:a:1" "handler_name=$cur_aud1" "-metadata:s:a:1" "title=$cur_aud1 - $cur_codec" \
    -map "5:0" "-metadata:s:a:2" "language=$cur_aud2" "-metadata:s:a:2" "handler_name=$cur_aud2" "-metadata:s:a:2" "title=$cur_aud2 - $cur_codec" \
    "${path_prefix}$FILEPATH" 2> "${log_path}"

    if [ -f "$FILEPATH" ]; then
        if [ "$show_create_done" = true ] ; then
            echo "File $FILEPATH created."
        fi
        ((total_created+=1))
    else
        echo "DANGER: File $FILEPATH NOT CREATED."
    fi
}

# $1 title with year
# $2 id string
# $3 Season number
# $4 episode count

createseason () {

    s_num=$(printf "%02d" $3)

    mkdir -p "test_tv_lib/$1 $2/Season $s_num"

    echo "Creating $4 episodes in season $s_num of $1"

    for i in $(seq 1 $4); do 
        e_num=$(printf "%02d" $i)
        createepisode "$1" "$2" $s_num $e_num; 
    done

    echo "Season $s_num of $1 COMPLETE"
    echo "----------------------------"

}

# $1 title with year
# $2 TMDB string
# $3 Season count
# $4 Episode count

createshow () {
    mkdir -p "test_tv_lib/$1 $2"

    for i in $(seq 1 $3); do createseason "$1" "$2" $i $4; done
}

title () {
    echo "==============================================="
    echo "Creating $1 seasons of $2"
    echo "==============================================="
}

footer () {
    echo "==============================================="
    echo "Created $1 items of expected $2"
    echo "==============================================="
}

total_expected=0
total_created=0

title 3 'American Gods'
randomizeall
createseason 'American Gods (2017)' '{tvdb-253573}' 1 8
createseason 'American Gods (2017)' '{tvdb-253573}' 2 8
createseason 'American Gods (2017)' '{tvdb-253573}' 3 10
# 8 8 10
footer $total_created $total_expected

title 3 'Bloodline'
startnewshow $cur_res $cur_src
createseason 'Bloodline (2015)' '{tvdb-287314}' 1 13
createseason 'Bloodline (2015)' '{tvdb-287314}' 2 10
createseason 'Bloodline (2015)' '{tvdb-287314}' 3 10
# 13 10 10
footer $total_created $total_expected

title 5 'Breaking Bad'
startnewshow $cur_res $cur_src
createseason 'Breaking Bad (2008)' '{tvdb-81189}' 1 7
createseason 'Breaking Bad (2008)' '{tvdb-81189}' 2 13
createseason 'Breaking Bad (2008)' '{tvdb-81189}' 3 13
createseason 'Breaking Bad (2008)' '{tvdb-81189}' 4 13
createseason 'Breaking Bad (2008)' '{tvdb-81189}' 5 16
# 7 13 13 13 16
footer $total_created $total_expected

title 4 'Documentary Now!'
startnewshow $cur_res $cur_src
createseason 'Documentary Now! (2015)' '{tvdb-295697}' 1 7
createseason 'Documentary Now! (2015)' '{tvdb-295697}' 2 7
createseason 'Documentary Now! (2015)' '{tvdb-295697}' 3 7
createseason 'Documentary Now! (2015)' '{tvdb-295697}' 4 6
# 7 7 7 6
footer $total_created $total_expected

title 11 'Happy Days'
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  0  4
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  1 16
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  2 23
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  3 24
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  4 25
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  5 26
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  6 26
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  7 25
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  8 22
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}'  9 22
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}' 10 22
randomizeall
createseason 'Happy Days (1974)' '{tvdb-74475}' 11 22
footer $total_created $total_expected

title 5 'New Amsterdam'
startnewshow $cur_res $cur_src
createseason 'New Amsterdam (2018)' '{tvdb-349272}' 1 22
createseason 'New Amsterdam (2018)' '{tvdb-349272}' 2 18
createseason 'New Amsterdam (2018)' '{tvdb-349272}' 3 14
createseason 'New Amsterdam (2018)' '{tvdb-349272}' 4 22
createseason 'New Amsterdam (2018)' '{tvdb-349272}' 5 13
# 22 18 14 22 13
footer $total_created $total_expected

title 6 'Peaky Blinders'
startnewshow $cur_res $cur_src
createshow 'Peaky Blinders (2013)' '{tvdb-270915}' 6 6
footer $total_created $total_expected

title 1 'Picnic at Hanging Rock'
startnewshow $cur_res $cur_src
createshow 'Picnic at Hanging Rock (2018)' '{tvdb-336473}' 1 6
# 6
footer $total_created $total_expected

title 1 'Squid Game'
startnewshow $cur_res $cur_src
createshow 'Squid Game (2021)' '{tvdb-383275}' 1 9
# 9
footer $total_created $total_expected

title 3 'Ted Lasso'
startnewshow $cur_res $cur_src
createseason 'Ted Lasso (2020)' '{tvdb-383203}' 1 10
createseason 'Ted Lasso (2020)' '{tvdb-383203}' 2 12
createseason 'Ted Lasso (2020)' '{tvdb-383203}' 3 12
# 10 12 12
footer $total_created $total_expected

title 2 'A Touch of Cloth'
startnewshow $cur_res $cur_src
createshow 'A Touch of Cloth (2012)' '{tvdb-260750}' 2 2
# 2 2
footer $total_created $total_expected

title 5 'Yellowstone'
startnewshow $cur_res $cur_src
createseason 'Yellowstone (2018)' '{tvdb-341164}' 1 9
createseason 'Yellowstone (2018)' '{tvdb-341164}' 2 10
createseason 'Yellowstone (2018)' '{tvdb-341164}' 3 10
createseason 'Yellowstone (2018)' '{tvdb-341164}' 4 10
createseason 'Yellowstone (2018)' '{tvdb-341164}' 5 8
# 9 10 10 10 8
footer $total_created $total_expected

title 5 'Star Trek: Enterprise'
startnewshow $cur_res $cur_src
createseason 'Star Trek: Enterprise (2001)' '{tvdb-73893}' 0 1
createseason 'Star Trek: Enterprise (2001)' '{tvdb-73893}' 1 26
createseason 'Star Trek: Enterprise (2001)' '{tvdb-73893}' 2 26
createseason 'Star Trek: Enterprise (2001)' '{tvdb-73893}' 3 24
createseason 'Star Trek: Enterprise (2001)' '{tvdb-73893}' 4 22
footer $total_created $total_expected

title 3 'Star Trek: Short Treks'
startnewshow $cur_res $cur_src
createseason 'Star Trek: Short Treks (2018)' '{tvdb-376108}' 0 15
createseason 'Star Trek: Short Treks (2018)' '{tvdb-376108}' 1 4
createseason 'Star Trek: Short Treks (2018)' '{tvdb-376108}' 2 6
footer $total_created $total_expected

title 4 'Star Trek'
startnewshow $cur_res $cur_src
createseason 'Star Trek (1966)' '{tvdb-77526}' 0 5
createseason 'Star Trek (1966)' '{tvdb-77526}' 1 29
createseason 'Star Trek (1966)' '{tvdb-77526}' 2 26
createseason 'Star Trek (1966)' '{tvdb-77526}' 3 24
footer $total_created $total_expected

title 6 'Star Trek: Discovery'
startnewshow $cur_res $cur_src
createseason 'Star Trek: Discovery (2017)' '{tvdb-328711}' 0 4
createseason 'Star Trek: Discovery (2017)' '{tvdb-328711}' 1 15
createseason 'Star Trek: Discovery (2017)' '{tvdb-328711}' 2 14
createseason 'Star Trek: Discovery (2017)' '{tvdb-328711}' 3 13
createseason 'Star Trek: Discovery (2017)' '{tvdb-328711}' 4 13
createseason 'Star Trek: Discovery (2017)' '{tvdb-328711}' 5 10
footer $total_created $total_expected

title 3 'Star Trek: Strange New Worlds'
startnewshow $cur_res $cur_src
createseason 'Star Trek: Strange New Worlds (2022)' '{tvdb-382389}' 0 3
createseason 'Star Trek: Strange New Worlds (2022)' '{tvdb-382389}' 1 10
createseason 'Star Trek: Strange New Worlds (2022)' '{tvdb-382389}' 2 10
footer $total_created $total_expected

title 3 'Star Trek: The Animated Series'
startnewshow $cur_res $cur_src
createseason 'Star Trek: The Animated Series (1973)' '{tvdb-73566}' 0 2
createseason 'Star Trek: The Animated Series (1973)' '{tvdb-73566}' 1 16
createseason 'Star Trek: The Animated Series (1973)' '{tvdb-73566}' 2 6
footer $total_created $total_expected

title 8 'Star Trek: The Next Generation'
startnewshow $cur_res $cur_src
createseason 'Star Trek: The Next Generation (1987)' '{tvdb-71470}' 0 2
createseason 'Star Trek: The Next Generation (1987)' '{tvdb-71470}' 1 26
createseason 'Star Trek: The Next Generation (1987)' '{tvdb-71470}' 2 22
createseason 'Star Trek: The Next Generation (1987)' '{tvdb-71470}' 3 26
createseason 'Star Trek: The Next Generation (1987)' '{tvdb-71470}' 4 26
createseason 'Star Trek: The Next Generation (1987)' '{tvdb-71470}' 5 26
createseason 'Star Trek: The Next Generation (1987)' '{tvdb-71470}' 6 26
createseason 'Star Trek: The Next Generation (1987)' '{tvdb-71470}' 7 26
footer $total_created $total_expected

title 8 'Star Trek: Deep Space Nine'
startnewshow $cur_res $cur_src
createseason 'Star Trek: Deep Space Nine (1993)' '{tvdb-72073}' 0 3
createseason 'Star Trek: Deep Space Nine (1993)' '{tvdb-72073}' 1 20
createseason 'Star Trek: Deep Space Nine (1993)' '{tvdb-72073}' 2 26
createseason 'Star Trek: Deep Space Nine (1993)' '{tvdb-72073}' 3 26
createseason 'Star Trek: Deep Space Nine (1993)' '{tvdb-72073}' 4 26
createseason 'Star Trek: Deep Space Nine (1993)' '{tvdb-72073}' 5 26
createseason 'Star Trek: Deep Space Nine (1993)' '{tvdb-72073}' 6 26
createseason 'Star Trek: Deep Space Nine (1993)' '{tvdb-72073}' 7 26
footer $total_created $total_expected

title 8 'Star Trek: Voyager'
startnewshow $cur_res $cur_src
createseason 'Star Trek: Voyager (1995)' '{tvdb-74550}' 0 1
createseason 'Star Trek: Voyager (1995)' '{tvdb-74550}' 1 16
createseason 'Star Trek: Voyager (1995)' '{tvdb-74550}' 2 26
createseason 'Star Trek: Voyager (1995)' '{tvdb-74550}' 3 26
createseason 'Star Trek: Voyager (1995)' '{tvdb-74550}' 4 26
createseason 'Star Trek: Voyager (1995)' '{tvdb-74550}' 5 26
createseason 'Star Trek: Voyager (1995)' '{tvdb-74550}' 6 26
createseason 'Star Trek: Voyager (1995)' '{tvdb-74550}' 7 26
footer $total_created $total_expected

title 4 'Star Trek: Lower Decks'
startnewshow $cur_res $cur_src
createshow 'Star Trek: Lower Decks (2020)' '{tvdb-367138}' 4 10
footer $total_created $total_expected

title 2 'Star Trek: Prodigy'
startnewshow $cur_res $cur_src
createshow 'Star Trek: Prodigy (2021)' '{tvdb-385811}' 2 20
footer $total_created $total_expected

title 3 'Star Trek: Picard'
startnewshow $cur_res $cur_src
createshow 'Star Trek: Picard (2020)' '{tvdb-364093}' 3 10
footer $total_created $total_expected

title 1 'Bad Monkey'
startnewshow $cur_res $cur_src
createshow 'Bad Monkey (2024)' '{tvdb-408436}' 1 10
footer $total_created $total_expected

title 2 'Monster'
startnewshow $cur_res $cur_src
createseason 'Monster (2022)' '{tvdb-389492}' 1 10
createseason 'Monster (2022)' '{tvdb-389492}' 2 9
footer $total_created $total_expected

title 13 'Chicago Fire'
startnewshow $cur_res $cur_src
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 1 24
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 2 22
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 3 23
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 4 23
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 5 22
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 6 23
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 7 22
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 8 20
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 9 16
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 10 22
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 11 22
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 12 13
createseason 'Chicago Fire (2012)' '{tvdb-258541}' 13 5
footer $total_created $total_expected

title 1 'Chicago Justice'
startnewshow $cur_res $cur_src
createseason 'Chicago Justice (2017)' '{tvdb-311896}' 1 13
footer $total_created $total_expected

title 10 'Chicago Med'
startnewshow $cur_res $cur_src
createseason 'Chicago Med (2015)' '{tvdb-295640}' 1 18
createseason 'Chicago Med (2015)' '{tvdb-295640}' 2 23
createseason 'Chicago Med (2015)' '{tvdb-295640}' 3 20
createseason 'Chicago Med (2015)' '{tvdb-295640}' 4 22
createseason 'Chicago Med (2015)' '{tvdb-295640}' 5 20
createseason 'Chicago Med (2015)' '{tvdb-295640}' 6 16
createseason 'Chicago Med (2015)' '{tvdb-295640}' 7 22
createseason 'Chicago Med (2015)' '{tvdb-295640}' 8 22
createseason 'Chicago Med (2015)' '{tvdb-295640}' 9 13
createseason 'Chicago Med (2015)' '{tvdb-295640}' 10 5
footer $total_created $total_expected

title 12 'Chicago P.D.'
startnewshow $cur_res $cur_src
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 1 15
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 2 23
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 3 23
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 4 23
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 5 22
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 6 22
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 7 20
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 8 16
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 9 22
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 10 22
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 11 13
createseason 'Chicago P.D. (2014)' '{tvdb-269641}' 12 5
footer $total_created $total_expected

title 27 'Law & Order: Special Victims Unit (1999)'
startnewshow $cur_res $cur_src
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 0 6
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 1 22
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 2 21
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 3 23
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 4 25
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 5 25
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 6 23
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 7 22
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 8 22
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 9 19
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 10 22
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 11 24
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 12 24
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 13 23
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 14 24
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 15 24
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 16 23
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 17 23
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 18 21
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 19 24
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 20 24
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 21 20
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 22 16
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 23 22
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 24 22
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 25 13
createseason 'Law & Order: Special Victims Unit (1999)' '{tvdb-75692}' 26 5
footer $total_created $total_expected

title 9 'Fear the Walking Dead (2015)'
startnewshow $cur_res $cur_src
createseason 'Fear the Walking Dead (2015)' '{tvdb-290853}' 8 12
createseason 'Fear the Walking Dead (2015)' '{tvdb-290853}' 7 16
createseason 'Fear the Walking Dead (2015)' '{tvdb-290853}' 6 16
createseason 'Fear the Walking Dead (2015)' '{tvdb-290853}' 5 16
createseason 'Fear the Walking Dead (2015)' '{tvdb-290853}' 4 16
createseason 'Fear the Walking Dead (2015)' '{tvdb-290853}' 3 16
createseason 'Fear the Walking Dead (2015)' '{tvdb-290853}' 2 15
createseason 'Fear the Walking Dead (2015)' '{tvdb-290853}' 1 6
createseason 'Fear the Walking Dead (2015)' '{tvdb-290853}' 0 49
footer $total_created $total_expected

title 1 'Tales of the Walking Dead (2022)'
startnewshow $cur_res $cur_src
createshow 'Tales of the Walking Dead (2022)' '{tvdb-411314}' 1 6
footer $total_created $total_expected

title 11 'The Walking Dead (2010)'
startnewshow $cur_res $cur_src
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 11 24
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 10 22
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 9 16
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 8 16
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 7 16
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 6 16
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 5 16
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 4 16
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 3 16
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 2 13
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 1 6
createseason 'The Walking Dead (2010)' '{tvdb-153021}' 0 77
footer $total_created $total_expected

title 1 'The Walking Dead: Daryl Dixon (2023)'
startnewshow $cur_res $cur_src
createshow 'The Walking Dead: Daryl Dixon (2023)' '{tvdb-427464}' 2 6 
footer $total_created $total_expected

title 2 'The Walking Dead: The Ones Who Live (2024)'
startnewshow $cur_res $cur_src
createseason 'The Walking Dead: The Ones Who Live (2024)' '{tvdb-427202}' 1 6
createseason 'The Walking Dead: The Ones Who Live (2024)' '{tvdb-427202}' 0 1
footer $total_created $total_expected

title 2 'The Walking Dead: World Beyond (2020)'
startnewshow $cur_res $cur_src
createseason 'The Walking Dead: World Beyond (2020)' '{tvdb-372787}' 2 10
createseason 'The Walking Dead: World Beyond (2020)' '{tvdb-372787}' 1 10
footer $total_created $total_expected

title 2 'The Walking Dead: Dead City (2023)'
startnewshow $cur_res $cur_src
createseason 'The Walking Dead: Dead City (2023)' '{tvdb-417549}' 1 6
createseason 'The Walking Dead: Dead City (2023)' '{tvdb-417549}' 0 2
footer $total_created $total_expected

title 1 'Battlestar Galactica (2003)'
createshow 'Battlestar Galactica (2003)' '{imdb-tt0314979} {tmdb-71365}' 1 2
footer $total_created $total_expected

title 5 'Battlestar Galactica (2004)'
createseason 'Battlestar Galactica (2004)' '{imdb-tt0407362} {tmdb-1972}' 0 50
createseason 'Battlestar Galactica (2004)' '{imdb-tt0407362} {tmdb-1972}' 1 13
createseason 'Battlestar Galactica (2004)' '{imdb-tt0407362} {tmdb-1972}' 2 20
createseason 'Battlestar Galactica (2004)' '{imdb-tt0407362} {tmdb-1972}' 3 20
createseason 'Battlestar Galactica (2004)' '{imdb-tt0407362} {tmdb-1972}' 4 20
footer $total_created $total_expected

title 1 'Caprica (2010)'
createshow 'Caprica (2010)' '{imdb-tt1286130} {tmdb-105077}' 1 18
footer $total_created $total_expected
