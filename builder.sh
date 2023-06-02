%!/usr/bin/bash

mkdir -p "test_movie_lib/#AnneFrank. Parallel Stories (2019) {imdb-tt9850370} {tmdb-610643}"
mkdir -p "test_movie_lib/3 1 2 Hours (2021) {imdb-tt13475394} {tmdb-847208}"
mkdir -p "test_movie_lib/Anna and the Apocalypse (2018) {imdb-tt6433880} {tmdb-461928}"
mkdir -p "test_movie_lib/Ant-Man and the Wasp (2018) {tmdb-363088}"
mkdir -p "test_movie_lib/Christmas Pen Pals (2018) {imdb-tt8942494} {tmdb-550648}"
mkdir -p "test_movie_lib/Mad Max Fury Road (2015) {imdb-tt1392190} {tmdb-76341}"
mkdir -p "test_movie_lib/Mad Max Fury Road (2015) {tmdb-76341}"
mkdir -p "test_movie_lib/Myra Breckinridge (1970) {imdb-tt0066115} {tmdb-40973}"
mkdir -p "test_movie_lib/Poor Little Rich Girl (1936) {imdb-tt0028118} {tmdb-43268}"
mkdir -p "test_movie_lib/Star Trek The Motion Picture (1979) {tmdb-152}"
mkdir -p "test_movie_lib/Tampopo (1985) {imdb-tt0092048} {tmdb-11830}"
mkdir -p "test_movie_lib/Wild Gals of the Naked West (1962) {imdb-tt0056692} {tmdb-5646}"
mkdir -p "test_movie_lib/Star Trek The Motion Picture (1979) {imdb-tt0079945} {tmdb-152}"
mkdir -p "test_movie_lib/Star Wars (1977) {imdb-tt0076759} {tmdb-11}"
mkdir -p "test_movie_lib/The Conjuring (2013) {imdb-tt1457767} {tmdb-138843}"

ffmpeg -loop 1 -i testpattern.png -c:v libx264 -t 900 -pix_fmt yuv420p -vf scale=1920:1080 "1080.mkv"
ffmpeg -loop 1 -i testpattern.png -c:v libx264 -t 900 -pix_fmt yuv420p -vf scale=1920:1080 "1080.mp4"
ffmpeg -loop 1 -i testpattern.png -c:v libx264 -t 900 -pix_fmt yuv420p -vf scale=3840:2160 "4k.mkv"
ffmpeg -loop 1 -i testpattern.png -c:v libx264 -t 900 -pix_fmt yuv420p -vf scale=720:480 "720.mkv"
ffmpeg -loop 1 -i testpattern.png -c:v libx264 -t 900 -pix_fmt yuv420p -vf scale=720:480 "720.mp4"

ffmpeg -i video -stream_loop -1 -i audio -map 0:v -map 1:a -c:v copy -shortest output

# ffmpeg -i 15-min-audio.m4a 15-min-audio.mp3
# ffmpeg -i 15-min-audio.m4a 15-min-audio.ac3
# ffmpeg -i 1080.mkv -i sounds/15-min-audio.m4a -i sounds/15-min-audio.mp3 -c copy -map 0:v:0 -map 1:a:0 -map 2:a:0 output.mkv
# ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:1 title="Two" -metadata:s:a:0 language=eng -metadata:s:a:1 language=spa output-2.mkv

# ffmpeg -i 1080.mkv -i sounds/15-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 output.mkv

# ffmpeg -stream_loop -1 -i 720.mkv -stream_loop -1 -i sounds/sample1.dts -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 -map 2:a:0 -t 900 output.mkv

    # Stream #0:1(eng): Audio: aac (HE-AAC), 48000 Hz, stereo, fltp (default) (forced)
ffmpeg -i 1080.mkv -i sounds/15-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/#AnneFrank. Parallel Stories (2019) {imdb-tt9850370} {tmdb-610643}/#AnneFrank. Parallel Stories (2019) [tt9850370] [WEBDL-1080p H264 AAC 2.0]-DANTWEET.mkv"
rm output.mkv

    # Stream #0:1(ger): Audio: ac3, 48000 Hz, 5.1(side), fltp, 448 kb/s (default)
ffmpeg -i 1080.mkv -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 language=ger output-2.mkv
mv output-2.mkv "test_movie_lib/3 1 2 Hours (2021) {imdb-tt13475394} {tmdb-847208}/3 ½ Stunden (2021) {imdb-tt13475394} - WEBRip-1080p-SAVASTANOS.mkv"
rm output.mkv

# ffmpeg -i video -stream_loop -1 -i audio -map 0:v -map 1:a -c:v copy -shortest output
    # Stream #0:1(eng): Audio: dts (DTS-HD MA), 48000 Hz, 5.1(side), s32p (24 bit) (default)
    # Stream #0:2(eng): Audio: ac3, 48000 Hz, stereo, fltp, 192 kb/s
ffmpeg -i 1080.mkv -i sounds/12-min-audio.dts -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 -map 2:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:1 title="Two" -metadata:s:a:0 language=eng -metadata:s:a:1 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/Anna and the Apocalypse (2018) {imdb-tt6433880} {tmdb-461928}/Anna and the Apocalypse (2018) {edition-Theatrical} [Remux-1080p 8-bit AVC DTS-HD MA 5.1]-FraMeSToR.mkv"
rm output.mkv

    # Stream #0:1(eng): Audio: eac3, 48000 Hz, 6 channels, fltp
ffmpeg -i 1080.mkv -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/Ant-Man and the Wasp (2018) {tmdb-363088}/Ant.Man.and.the.Wasp.2018.IMAX.1080p.DSNP.WEB-DL.DDP5.1.Atmos.H.264-MZABI-{edition-IMAX ENHANCED}.mkv"
rm output.mkv

    # Stream #0:1(eng): Audio: eac3, 48000 Hz, 2 channels, fltp (default)
ffmpeg -i 1080.mkv -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/Christmas Pen Pals (2018) {imdb-tt8942494} {tmdb-550648}/Christmas Pen Pals (2018) [WEBDL-1080p 8-bit h264 EAC3 2.0]-deeplife.mkv"
rm output.mkv

    # Stream #0:1(eng): Audio: truehd, 48000 Hz, 7.1, s32 (24 bit) (default)
    # Stream #0:2(eng): Audio: ac3, 48000 Hz, 5.1(side), fltp, 640 kb/s
ffmpeg -i 1080.mkv -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/Mad Max Fury Road (2015) {imdb-tt1392190} {tmdb-76341}/Mad Max Fury Road (2015) [tt1392190] [Remux-1080p H264 TrueHD Atmos 7.1]-KRaLiMaRKo.mkv"
rm output.mkv

    # Stream #0:1: Audio: ac3, 48000 Hz, stereo, fltp, 256 kb/s (default)
ffmpeg -i 1080.mkv -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/Myra Breckinridge (1970) {imdb-tt0066115} {tmdb-40973}/Myra Breckinridge (1970) [WEBDL-1080p 8-bit x264 AC3 2.0].mkv"
rm output.mkv

    # Stream #0:1(und): Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 127 kb/s (default)
ffmpeg -i 720.mp4 -i sounds/15-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 output.mp4
ffmpeg -i output.mp4 -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 output-2.mp4
mv output-2.mp4 "test_movie_lib/Poor Little Rich Girl (1936) {imdb-tt0028118} {tmdb-43268}/Poor Little Rich Girl (1936) [DVD 8-bit x264 AAC 2.0].mp4"
rm output.mp4

    # Stream #0:1(eng): Audio: eac3, 48000 Hz, 6 channels, fltp (default)
ffmpeg -i 4k.mkv -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/Star Trek The Motion Picture (1979) {tmdb-152}/Star.Trek.The.Motion.Picture.The.Directors.Edition.1979.2160p.PMTP.WEB-DL.DDP5.1.Atmos.HDR.HEVC-TEPES-{edition-Directors Edition}.mkv"
rm output.mkv

    # Stream #0:1(eng): Audio: truehd, 48000 Hz, 7.1, s32 (24 bit) (default)
    # Stream #0:2(eng): Audio: ac3, 48000 Hz, 5.1(side), fltp, 640 kb/s (default)
    # Stream #0:3(eng): Audio: ac3, 48000 Hz, stereo, fltp, 224 kb/s
    # Stream #0:4(eng): Audio: ac3, 48000 Hz, stereo, fltp, 224 kb/s
ffmpeg -i 1080.mkv -i sounds/15-min-audio.ac3 -i sounds/15-min-audio.mp3 -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 -map 2:a:0 -map 3:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:1 title="Two" -metadata:s:a:2 title="Three" -metadata:s:a:0 language=eng -metadata:s:a:1 language=eng -metadata:s:a:2 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/Star Trek The Motion Picture (1979) {imdb-tt0079945} {tmdb-152}/Star Trek The Motion Picture (1979) Remastered [Remux-1080p 8-bit h264 TrueHD 7.1]-playBD.mkv"
rm output.mkv

    # Stream #0:1(jpn): Audio: dts (DTS-HD MA), 48000 Hz, mono, s32p (24 bit) (default)
ffmpeg -i 1080.mkv -i sounds/12-min-audio.dts -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 language=jpn output-2.mkv
mv output-2.mkv "test_movie_lib/Tampopo (1985) {imdb-tt0092048} {tmdb-11830}/Tampopo (1985) [Remux-1080p 8-bit AVC DTS-HD MA 1.0][JA]-FraMeSToR.mkv"
rm output.mkv

    # Stream #0:1: Audio: aac (LC), 48000 Hz, stereo, fltp (default)
ffmpeg -i 720.mkv -i sounds/15-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 output-2.mkv
mv output-2.mkv "test_movie_lib/Wild Gals of the Naked West (1962) {imdb-tt0056692} {tmdb-5646}/Wild Gals of the Naked West (1962) [DVD 8-bit x264 AAC 2.0]-DVD.mkv"
rm output.mkv

    # Stream #0:1(eng): Audio: dts (DTS-HD MA), 48000 Hz, 5.1(side), s32p (24 bit) (default)
ffmpeg -i 4k.mkv -i sounds/12-min-audio.dts -c copy -map 0:v:0 -map 1:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:0 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/The Conjuring (2013) {imdb-tt1457767} {tmdb-138843}/The Conjuring (2013) [WEBDL-2160p HEVC DV 10-bit DTS-HD MA 5.1]-SKiZOiD.mkv"
rm output.mkv

    # Stream #0:1(eng): Audio: truehd, 48000 Hz, 7.1, s32 (24 bit) (default)
    # Stream #0:2(eng): Audio: ac3, 48000 Hz, 5.1(side), fltp, 640 kb/s
    # Stream #0:3(eng): Audio: ac3, 48000 Hz, stereo, fltp, 224 kb/s
    # Stream #0:4(eng): Audio: ac3, 48000 Hz, stereo, fltp, 224 kb/s
ffmpeg -i 4k.mkv -i sounds/15-min-audio.ac3 -i sounds/15-min-audio.mp3 -i sounds/15-min-audio.ac3 -c copy -map 0:v:0 -map 1:a:0 -map 2:a:0 -map 3:a:0 output.mkv
ffmpeg -i output.mkv -map 0 -c copy -metadata:s:a:0 title="One" -metadata:s:a:1 title="Two" -metadata:s:a:2 title="Three" -metadata:s:a:0 language=eng -metadata:s:a:1 language=eng -metadata:s:a:2 language=eng output-2.mkv
mv output-2.mkv "test_movie_lib/Star Wars (1977) {imdb-tt0076759} {tmdb-11}/Star Wars (1977) [Remux-2160p HEVC DV HDR10 10-bit TrueHD Atmos 7.1]-FLUX.mkv"
rm output.mkv

cp protosub.srt "test_movie_lib/#AnneFrank. Parallel Stories (2019) {imdb-tt9850370} {tmdb-610643}/#AnneFrank. Parallel Stories (2019) [tt9850370] [WEBDL-1080p H264 AAC 2.0]-DANTWEET.en.srt"
cp protosub.srt "test_movie_lib/#AnneFrank. Parallel Stories (2019) {imdb-tt9850370} {tmdb-610643}/#AnneFrank. Parallel Stories (2019) [tt9850370] [WEBDL-1080p H264 AAC 2.0]-DANTWEET.es.srt"
cp protosub.srt "test_movie_lib/3 1 2 Hours (2021) {imdb-tt13475394} {tmdb-847208}/3 ½ Stunden (2021) {imdb-tt13475394} - WEBRip-1080p-SAVASTANOS.en.sdh.srt"
cp protosub.srt "test_movie_lib/Anna and the Apocalypse (2018) {imdb-tt6433880} {tmdb-461928}/Anna and the Apocalypse (2018) {edition-Theatrical} [Remux-1080p 8-bit AVC DTS-HD MA 5.1]-FraMeSToR.en.srt"
cp protosub.srt "test_movie_lib/Christmas Pen Pals (2018) {imdb-tt8942494} {tmdb-550648}/Christmas Pen Pals (2018) [WEBDL-1080p 8-bit h264 EAC3 2.0]-deeplife.en.srt"
cp protosub.srt "test_movie_lib/Mad Max Fury Road (2015) {imdb-tt1392190} {tmdb-76341}/Mad Max Fury Road (2015) [tt1392190] [Remux-1080p H264 TrueHD Atmos 7.1]-KRaLiMaRKo.ar.srt"
cp protosub.srt "test_movie_lib/Mad Max Fury Road (2015) {imdb-tt1392190} {tmdb-76341}/Mad Max Fury Road (2015) [tt1392190] [Remux-1080p H264 TrueHD Atmos 7.1]-KRaLiMaRKo.en.srt"
cp protosub.srt "test_movie_lib/Mad Max Fury Road (2015) {imdb-tt1392190} {tmdb-76341}/Mad Max Fury Road (2015) [tt1392190] [Remux-1080p H264 TrueHD Atmos 7.1]-KRaLiMaRKo.es.srt"
cp protosub.srt "test_movie_lib/Myra Breckinridge (1970) {imdb-tt0066115} {tmdb-40973}/Myra Breckinridge (1970) [WEBDL-1080p 8-bit x264 AC3 2.0].ar.srt"
cp protosub.srt "test_movie_lib/Myra Breckinridge (1970) {imdb-tt0066115} {tmdb-40973}/Myra Breckinridge (1970) [WEBDL-1080p 8-bit x264 AC3 2.0].en.srt"
cp protosub.srt "test_movie_lib/Poor Little Rich Girl (1936) {imdb-tt0028118} {tmdb-43268}/Poor Little Rich Girl (1936) [DVD 8-bit x264 AAC 2.0].en.srt"
cp protosub.srt "test_movie_lib/Poor Little Rich Girl (1936) {imdb-tt0028118} {tmdb-43268}/Poor Little Rich Girl (1936) [DVD 8-bit x264 AAC 2.0].es.srt"
cp protosub.srt "test_movie_lib/Star Trek The Motion Picture (1979) {imdb-tt0079945} {tmdb-152}/Star Trek The Motion Picture (1979) Remastered [Remux-1080p 8-bit h264 TrueHD 7.1]-playBD.en.srt"
cp protosub.srt "test_movie_lib/Star Trek The Motion Picture (1979) {imdb-tt0079945} {tmdb-152}/Star Trek The Motion Picture (1979) Remastered [Remux-1080p 8-bit h264 TrueHD 7.1]-playBD.ar.srt"
cp protosub.srt "test_movie_lib/Star Trek The Motion Picture (1979) {imdb-tt0079945} {tmdb-152}/Star Trek The Motion Picture (1979) Remastered [Remux-1080p 8-bit h264 TrueHD 7.1]-playBD.es.srt"
cp protosub.srt "test_movie_lib/Tampopo (1985) {imdb-tt0092048} {tmdb-11830}/Tampopo (1985) [Remux-1080p 8-bit AVC DTS-HD MA 1.0][JA]-FraMeSToR.ar.srt"
cp protosub.srt "test_movie_lib/Tampopo (1985) {imdb-tt0092048} {tmdb-11830}/Tampopo (1985) [Remux-1080p 8-bit AVC DTS-HD MA 1.0][JA]-FraMeSToR.en.srt"
cp protosub.srt "test_movie_lib/Tampopo (1985) {imdb-tt0092048} {tmdb-11830}/Tampopo (1985) [Remux-1080p 8-bit AVC DTS-HD MA 1.0][JA]-FraMeSToR.es.srt"
cp protosub.srt "test_movie_lib/Star Wars (1977) {imdb-tt0076759} {tmdb-11}/Star Wars (1977) [Remux-2160p HEVC DV HDR10 10-bit TrueHD Atmos 7.1]-FLUX.ar.srt"
cp protosub.srt "test_movie_lib/Star Wars (1977) {imdb-tt0076759} {tmdb-11}/Star Wars (1977) [Remux-2160p HEVC DV HDR10 10-bit TrueHD Atmos 7.1]-FLUX.en.srt"
cp protosub.srt "test_movie_lib/Star Wars (1977) {imdb-tt0076759} {tmdb-11}/Star Wars (1977) [Remux-2160p HEVC DV HDR10 10-bit TrueHD Atmos 7.1]-FLUX.es.srt"
cp protosub.srt "test_movie_lib/The Conjuring (2013) {imdb-tt1457767} {tmdb-138843}/The Conjuring (2013) [WEBDL-2160p HEVC DV 10-bit DTS-HD MA 5.1]-SKiZOiD.en.srt"
cp protosub.srt "test_movie_lib/The Conjuring (2013) {imdb-tt1457767} {tmdb-138843}/The Conjuring (2013) [WEBDL-2160p HEVC DV 10-bit DTS-HD MA 5.1]-SKiZOiD.ar.srt"
cp protosub.srt "test_movie_lib/The Conjuring (2013) {imdb-tt1457767} {tmdb-138843}/The Conjuring (2013) [WEBDL-2160p HEVC DV 10-bit DTS-HD MA 5.1]-SKiZOiD.es.srt"

convert -background pink -fill black -font fonts/Monaco.ttf -size 1000x1500  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/#AnneFrank. Parallel Stories (2019) {imdb-tt9850370} {tmdb-610643}/poster.jpg"
convert -background plum -fill black -font fonts/Monaco.ttf -size 1000x1500  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/3 1 2 Hours (2021) {imdb-tt13475394} {tmdb-847208}/poster.jpg"
convert -background SteelBlue1 -fill black -font fonts/Monaco.ttf -size 1000x1500  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/Anna and the Apocalypse (2018) {imdb-tt6433880} {tmdb-461928}/poster.jpg"
convert -background DarkSeaGreen1 -fill black -font fonts/Monaco.ttf -size 1000x1500  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/Christmas Pen Pals (2018) {imdb-tt8942494} {tmdb-550648}/poster.jpg"
convert -background LightGoldenrodYellow -fill black -font fonts/Monaco.ttf -size 1000x1500  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/Mad Max Fury Road (2015) {imdb-tt1392190} {tmdb-76341}/poster.jpg"
convert -background cornsilk -fill black -font fonts/Monaco.ttf -size 1000x1500  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/Myra Breckinridge (1970) {imdb-tt0066115} {tmdb-40973}/poster.jpg"
convert -background NavajoWhite -fill black -font fonts/Monaco.ttf -size 1000x1500  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/Poor Little Rich Girl (1936) {imdb-tt0028118} {tmdb-43268}/poster.jpg"
convert -background PeachPuff -fill black -font fonts/Monaco.ttf -size 1000x1500  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/Tampopo (1985) {imdb-tt0092048} {tmdb-11830}/poster.jpg"
convert -background lightgrey -fill black -font fonts/Monaco.ttf -size 1000x1500  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/Wild Gals of the Naked West (1962) {imdb-tt0056692} {tmdb-5646}/poster.jpg"
convert -background PaleTurquoise1 -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/Star Trek The Motion Picture (1979) {imdb-tt0079945} {tmdb-152}/poster.jpg"
convert -background aquamarine -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/Star Wars (1977) {imdb-tt0076759} {tmdb-11}/poster.jpg"
convert -background wheat -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:poster.jpg "test_movie_lib/The Conjuring (2013) {imdb-tt1457767} {tmdb-138843}/poster.jpg"

convert -background pink -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/#AnneFrank. Parallel Stories (2019) {imdb-tt9850370} {tmdb-610643}/fanart.jpg"
convert -background plum -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/3 1 2 Hours (2021) {imdb-tt13475394} {tmdb-847208}/fanart.jpg"
convert -background SteelBlue1 -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/Anna and the Apocalypse (2018) {imdb-tt6433880} {tmdb-461928}/fanart.jpg"
convert -background DarkSeaGreen1 -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/Christmas Pen Pals (2018) {imdb-tt8942494} {tmdb-550648}/fanart.jpg"
convert -background LightGoldenrodYellow -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/Mad Max Fury Road (2015) {imdb-tt1392190} {tmdb-76341}/fanart.jpg"
convert -background cornsilk -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/Myra Breckinridge (1970) {imdb-tt0066115} {tmdb-40973}/fanart.jpg"
convert -background NavajoWhite -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/Poor Little Rich Girl (1936) {imdb-tt0028118} {tmdb-43268}/fanart.jpg"
convert -background PeachPuff -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/Tampopo (1985) {imdb-tt0092048} {tmdb-11830}/fanart.jpg"
convert -background lightgrey -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/Wild Gals of the Naked West (1962) {imdb-tt0056692} {tmdb-5646}/fanart.jpg"
convert -background PaleTurquoise1 -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/Star Trek The Motion Picture (1979) {imdb-tt0079945} {tmdb-152}/fanart.jpg"
convert -background aquamarine -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/Star Wars (1977) {imdb-tt0076759} {tmdb-11}/fanart.jpg"
convert -background wheat -fill black -font fonts/Monaco.ttf -size 1920x1080  -pointsize 160  -gravity center label:fanart.jpg "test_movie_lib/The Conjuring (2013) {imdb-tt1457767} {tmdb-138843}/fanart.jpg"

cp nfos/tt0028118.nfo "test_movie_lib/Poor Little Rich Girl (1936) {imdb-tt0028118} {tmdb-43268}/Poor Little Rich Girl (1936) [DVD 8-bit x264 AAC 2.0].nfo"
cp nfos/tt0056692.nfo "test_movie_lib/Wild Gals of the Naked West (1962) {imdb-tt0056692} {tmdb-5646}/Wild Gals of the Naked West (1962) [DVD 8-bit x264 AAC 2.0]-DVD.nfo"
cp nfos/tt0066115.nfo "test_movie_lib/Myra Breckinridge (1970) {imdb-tt0066115} {tmdb-40973}/Myra Breckinridge (1970) [WEBDL-1080p 8-bit x264 AC3 2.0].nfo"
cp nfos/tt0079945.nfo "test_movie_lib/Star Trek The Motion Picture (1979) {imdb-tt0079945} {tmdb-152}/Star Trek The Motion Picture (1979) Remastered [Remux-1080p 8-bit h264 TrueHD 7.1]-playBD.nfo"
cp nfos/tt1392190.nfo "test_movie_lib/Mad Max Fury Road (2015) {imdb-tt1392190} {tmdb-76341}/Mad Max Fury Road (2015) [tt1392190] [Remux-1080p H264 TrueHD Atmos 7.1]-KRaLiMaRKo.nfo"
cp nfos/tt6433880.nfo "test_movie_lib/Anna and the Apocalypse (2018) {imdb-tt6433880} {tmdb-461928}/Anna and the Apocalypse (2018) {edition-Theatrical} [Remux-1080p 8-bit AVC DTS-HD MA 5.1]-FraMeSToR.nfo"
cp nfos/tt8942494.nfo "test_movie_lib/Christmas Pen Pals (2018) {imdb-tt8942494} {tmdb-550648}/Christmas Pen Pals (2018) [WEBDL-1080p 8-bit h264 EAC3 2.0]-deeplife.nfo"
cp nfos/tt9850370.nfo "test_movie_lib/#AnneFrank. Parallel Stories (2019) {imdb-tt9850370} {tmdb-610643}/#AnneFrank. Parallel Stories (2019) [tt9850370] [WEBDL-1080p H264 AAC 2.0]-DANTWEET.nfo"
cp nfos/tt13475394.nfo "test_movie_lib/3 1 2 Hours (2021) {imdb-tt13475394} {tmdb-847208}/3 ½ Stunden (2021) {imdb-tt13475394} - WEBRip-1080p-SAVASTANOS.nfo"
cp nfos/tt0076759.nfo "test_movie_lib/Star Wars (1977) {imdb-tt0076759} {tmdb-11}/movie.nfo"
cp nfos/tt1457767.nfo "test_movie_lib/The Conjuring (2013) {imdb-tt1457767} {tmdb-138843}/The Conjuring (2013) [WEBDL-2160p HEVC DV 10-bit DTS-HD MA 5.1]-SKiZOiD.nfo"

rm 1080.mkv
rm 1080.mp4
rm 4k.mkv
rm 720.mkv
rm 720.mp4
