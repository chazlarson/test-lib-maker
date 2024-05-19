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
        docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -loop 1 -i /config/testpattern.png -c:v libx264 -t 60 -pix_fmt yuv420p -vf scale=$2 /config/$FILE
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
    docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -i "$3.mkv" -i /config/sounds/1-min-audio.m4a -c copy -map 0:v:0 -map 1:a:0 "/config/test_movie_lib/$1 $2/$1 [WEBDL-$4 H264 AAC 2.0]-BINGBANG.mkv"
}

# Comedy after 2012
createtestvideo "21 Jump Street (2012)" "{imdb-tt1232829}" "4k" "2160p" # comedy
createtestvideo "22 Jump Street (2014)" "{imdb-tt2294449}" "4k" "2160p" # comedy
createtestvideo "About Time (2013)" "{imdb-tt2194499}" "4k" "2160p" # comedy
createtestvideo "Ant-Man (2015)" "{imdb-tt0478970}" "4k" "2160p" # comedy
createtestvideo "Ant-Man and the Wasp (2018)" "{imdb-tt5095030}" "4k" "2160p" # comedy
createtestvideo "Barbie (2023)" "{imdb-tt1517268}" "4k" "2160p" # comedy
createtestvideo "Big Hero 6 (2014)" "{imdb-tt2245084}" "4k" "2160p" # comedy
createtestvideo "Birdman or (The Unexpected Virtue of Ignorance) (2014)" "{imdb-tt2562232}" "4k" "2160p" # comedy
createtestvideo "Brave (2012)" "{imdb-tt1217209}" "4k" "2160p" # comedy
createtestvideo "Bullet Train (2022)" "{imdb-tt12593682}" "4k" "2160p" # comedy
createtestvideo "Deadpool (2016)" "{imdb-tt1431045} {tmdb-293660}" "1080" "1080p" # comedy
# createtestvideo "Deadpool (2016)" "{imdb-tt1431045}" "1080" "1080p" # comedy
createtestvideo "Deadpool 2 (2018)" "{imdb-tt5463162} {tmdb-383498}" "720" "720p" # comedy
# createtestvideo "Deadpool 2 (2018)" "{imdb-tt5463162}" "1080" "1080p" # comedy
createtestvideo "Despicable Me 2 (2013)" "{imdb-tt1690953}" "1080" "1080p" # comedy
createtestvideo "Don't Look Up (2021)" "{imdb-tt11286314}" "1080" "1080p" # comedy
createtestvideo "Everything Everywhere All at Once (2022)" "{imdb-tt6710474} {tmdb-545611}" "1080" "1080p" # comedy
# createtestvideo "Everything Everywhere All at Once (2022)" "{imdb-tt6710474}" "1080" "1080p" # comedy
createtestvideo "Free Guy (2021)" "{imdb-tt6264654}" "1080" "1080p" # comedy
createtestvideo "Frozen (2013)" "{imdb-tt2294629}" "1080" "1080p" # comedy
createtestvideo "Glass Onion (2022)" "{imdb-tt11564570}" "1080" "1080p" # comedy
createtestvideo "Green Book (2018)" "{imdb-tt6966692} {tmdb-490132}" "4k" "2160p" # comedy
# createtestvideo "Green Book (2018)" "{imdb-tt6966692}" "1080" "1080p" # comedy
createtestvideo "Guardians of the Galaxy (2014)" "{imdb-tt2015381}" "1080" "1080p" # comedy
createtestvideo "Guardians of the Galaxy Vol. 2 (2017)" "{imdb-tt3896198}" "720" "720p" # comedy
createtestvideo "Guardians of the Galaxy Vol. 3 (2023)" "{imdb-tt6791350} {tmdb-447365}" "720" "720p" # comedy
# createtestvideo "Guardians of the Galaxy Vol. 3 (2023)" "{imdb-tt6791350}" "720" "720p" # comedy
createtestvideo "Inside Out (2015)" "{imdb-tt2096673}" "720" "720p" # comedy
createtestvideo "Jojo Rabbit (2019)" "{imdb-tt2584384}" "720" "720p" # comedy
createtestvideo "Jumanji: Welcome to the Jungle (2017)" "{imdb-tt2283362}" "720" "720p" # comedy
createtestvideo "Kingsman: The Secret Service (2014)" "{imdb-tt2802144}" "720" "720p" # comedy
createtestvideo "Knives Out (2019)" "{imdb-tt8946378} {tmdb-546554}" "576" "576p" # comedy
# createtestvideo "Knives Out (2019)" "{imdb-tt8946378}" "720" "720p" # comedy
createtestvideo "La La Land (2016)" "{imdb-tt3783958} {tmdb-313369}" "480" "480p" # comedy
# createtestvideo "La La Land (2016)" "{imdb-tt3783958}" "720" "720p" # comedy
createtestvideo "Men in Black³ (2012)" "{imdb-tt1409024}" "720" "720p" # comedy
createtestvideo "Moana (2016)" "{imdb-tt3521164}" "720" "720p" # comedy
createtestvideo "Monsters University (2013)" "{imdb-tt1453405}" "576" "576p" # comedy
createtestvideo "Once Upon a Time... in Hollywood (2019)" "{imdb-tt7131622} {tmdb-466272}" "576" "576p" # comedy
# createtestvideo "Once Upon a Time... in Hollywood (2019)" "{imdb-tt7131622}" "576" "576p" # comedy
createtestvideo "Shazam! (2019)" "{imdb-tt0448115}" "576" "576p" # comedy
createtestvideo "Silver Linings Playbook (2012)" "{imdb-tt1045658}" "576" "576p" # comedy
createtestvideo "Soul (2020)" "{imdb-tt2948372}" "576" "576p" # comedy
createtestvideo "Spider-Man: Far from Home (2019)" "{imdb-tt6320628}" "576" "576p" # comedy
createtestvideo "Spider-Man: Into the Spider-Verse (2018)" "{imdb-tt4633694}" "576" "576p" # comedy
createtestvideo "Ted (2012)" "{imdb-tt1637725}" "576" "576p" # comedy
createtestvideo "The Big Short (2015)" "{imdb-tt1596363}" "576" "576p" # comedy
createtestvideo "The Grand Budapest Hotel (2014)" "{imdb-tt2278388}" "576" "576p" # comedy
createtestvideo "The Holdovers (2023)" "{imdb-tt14849194} {tmdb-840430}" "4k" "2160p" # comedy
createtestvideo "The Lego Movie (2014)" "{imdb-tt1490017}" "480" "480p" # comedy
createtestvideo "The Menu (2022)" "{imdb-tt9764362}" "480" "480p" # comedy
createtestvideo "The Suicide Squad (2021)" "{imdb-tt6334354}" "480" "480p" # comedy
# createtestvideo "The Wolf of Wall Street (2013)" "{imdb-tt0993846}" "480" "480p" # comedy
createtestvideo "The Wolf of Wall Street (2013)" "{imdb-tt0993846} {tmdb-106646}" "480" "480p" # comedy
createtestvideo "This Is the End (2013)" "{imdb-tt1245492}" "480" "480p" # comedy
createtestvideo "Thor: Love and Thunder (2022)" "{imdb-tt10648342}" "480" "480p" # comedy
createtestvideo "Thor: Ragnarok (2017)" "{imdb-tt3501632}" "480" "480p" # comedy
createtestvideo "Three Billboards Outside Ebbing, Missouri (2017)" "{imdb-tt5027774}" "480" "480p" # comedy
createtestvideo "We're the Millers (2013)" "{imdb-tt1723121}" "480" "480p" # comedy
createtestvideo "Wreck-It Ralph (2012)" "{imdb-tt1772341}" "480" "480p" # comedy

# IMDB Lowest
createtestvideo "3 Ninjas: High Noon at Mega Mountain (1998)" "{imdb-tt0118539} {tmdb-32302}" "4k" "2160p" # imdb lowest
createtestvideo "365 Days (2020)" "{imdb-tt10886166} {tmdb-664413}" "1080" "1080p" # imdb lowest
createtestvideo "365 Days (2020)" "{imdb-tt10886166}" "4k" "2160p" # imdb lowest
createtestvideo "365 Days: This Day (2022)" "{imdb-tt12996154}" "4k" "2160p" # imdb lowest
createtestvideo "Adipurush (2023)" "{imdb-tt12915716} {tmdb-734253}" "720" "720p" # imdb lowest
createtestvideo "Alone in the Dark (2005)" "{imdb-tt0369226} {tmdb-12142}" "576" "576p" # imdb lowest
createtestvideo "Baaghi 3 (2020)" "{imdb-tt8366590} {tmdb-594669}" "480" "480p" # imdb lowest
createtestvideo "Baby Geniuses (1999)" "{imdb-tt0118665} {tmdb-22345}" "4k" "2160p" # imdb lowest
createtestvideo "Barb Wire (1996)" "{imdb-tt0115624} {tmdb-11867}" "1080" "1080p" # imdb lowest
createtestvideo "Barb Wire (1996)" "{imdb-tt0115624}" "4k" "2160p" # imdb lowest
createtestvideo "Batman & Robin (1997)" "{imdb-tt0118688} {tmdb-415}" "720" "720p" # imdb lowest
createtestvideo "Batman & Robin (1997)" "{imdb-tt0118688}" "4k" "2160p" # imdb lowest
createtestvideo "Battlefield Earth (2000)" "{imdb-tt0185183} {tmdb-5491}" "576" "576p" # imdb lowest
createtestvideo "Battlefield Earth (2000)" "{imdb-tt0185183}" "4k" "2160p" # imdb lowest
createtestvideo "Birdemic: Shock and Terror (2010)" "{imdb-tt1316037} {tmdb-40016}" "480" "480p" # imdb lowest
createtestvideo "BloodRayne (2005)" "{imdb-tt0383222}" "4k" "2160p" # imdb lowest
createtestvideo "Cats (2019)" "{imdb-tt5697572}" "4k" "2160p" # imdb lowest
createtestvideo "Catwoman (2004)" "{imdb-tt0327554}" "4k" "2160p" # imdb lowest
createtestvideo "Cosmic Sin (2021)" "{imdb-tt11762434}" "4k" "2160p" # imdb lowest
createtestvideo "Crossroads (2002)" "{imdb-tt0275022}" "1080" "1080p" # imdb lowest
createtestvideo "Date Movie (2006)" "{imdb-tt0466342}" "1080" "1080p" # imdb lowest
createtestvideo "Disaster Movie (2008)" "{imdb-tt1213644}" "1080" "1080p" # imdb lowest
createtestvideo "Dragonball Evolution (2009)" "{imdb-tt1098327}" "1080" "1080p" # imdb lowest
createtestvideo "Dungeons & Dragons (2000)" "{imdb-tt0190374}" "1080" "1080p" # imdb lowest
createtestvideo "Epic Movie (2007)" "{imdb-tt0799949}" "1080" "1080p" # imdb lowest
createtestvideo "Gigli (2003)" "{imdb-tt0299930}" "1080" "1080p" # imdb lowest
createtestvideo "I Know Who Killed Me (2007)" "{imdb-tt0897361}" "1080" "1080p" # imdb lowest
createtestvideo "In the Name of the King: A Dungeon Siege Tale (2007)" "{imdb-tt0460780}" "1080" "1080p" # imdb lowest
createtestvideo "Jack and Jill (2011)" "{imdb-tt0810913}" "1080" "1080p" # imdb lowest
createtestvideo "Jaws 3-D (1983)" "{imdb-tt0085750}" "720" "720p" # imdb lowest
createtestvideo "Jaws: The Revenge (1987)" "{imdb-tt0093300}" "720" "720p" # imdb lowest
createtestvideo "Jeepers Creepers: Reborn (2022)" "{imdb-tt14121726}" "720" "720p" # imdb lowest
createtestvideo "Kazaam (1996)" "{imdb-tt0116756}" "720" "720p" # imdb lowest
createtestvideo "Left Behind (2014)" "{imdb-tt2467046}" "720" "720p" # imdb lowest
createtestvideo "Mac and Me (1988)" "{imdb-tt0095560}" "720" "720p" # imdb lowest
createtestvideo "Meet the Spartans (2008)" "{imdb-tt1073498}" "720" "720p" # imdb lowest
createtestvideo "Piranha 3DD (2012)" "{imdb-tt1714203}" "720" "720p" # imdb lowest
createtestvideo "Rollerball (2002)" "{imdb-tt0246894}" "720" "720p" # imdb lowest
createtestvideo "Scary Movie V (2013)" "{imdb-tt0795461}" "720" "720p" # imdb lowest
createtestvideo "Slender Man (2018)" "{imdb-tt5690360}" "576" "576p" # imdb lowest
createtestvideo "Son of the Mask (2005)" "{imdb-tt0362165}" "576" "576p" # imdb lowest
createtestvideo "Spice World (1997)" "{imdb-tt0120185}" "576" "576p" # imdb lowest
createtestvideo "Spy Kids 4: All the Time in the World (2011)" "{imdb-tt1517489}" "576" "576p" # imdb lowest
createtestvideo "Superman IV: The Quest for Peace (1987)" "{imdb-tt0094074}" "576" "576p" # imdb lowest
createtestvideo "Texas Chainsaw Massacre: The Next Generation (1994)" "{imdb-tt0110978}" "576" "576p" # imdb lowest
createtestvideo "The Adventures of Sharkboy and Lavagirl 3-D (2005)" "{imdb-tt0424774}" "576" "576p" # imdb lowest
createtestvideo "The Emoji Movie (2017)" "{imdb-tt4877122}" "576" "576p" # imdb lowest
createtestvideo "The Flintstones in Viva Rock Vegas (2000)" "{imdb-tt0158622}" "576" "576p" # imdb lowest
createtestvideo "The Fog (2005)" "{imdb-tt0432291}" "576" "576p" # imdb lowest
createtestvideo "The Hottie & the Nottie (2008)" "{imdb-tt0804492}" "480" "480p" # imdb lowest
createtestvideo "The Human Centipede 2 (Full Sequence) (2011)" "{imdb-tt1530509}" "480" "480p" # imdb lowest
createtestvideo "The Human Centipede III (Final Sequence) (2015)" "{imdb-tt1883367}" "480" "480p" # imdb lowest
createtestvideo "The Love Guru (2008)" "{imdb-tt0811138}" "480" "480p" # imdb lowest
createtestvideo "The Master of Disguise (2002)" "{imdb-tt0295427}" "480" "480p" # imdb lowest
createtestvideo "The NeverEnding Story III (1994)" "{imdb-tt0110647}" "480" "480p" # imdb lowest
createtestvideo "The Room (2003)" "{imdb-tt0368226}" "480" "480p" # imdb lowest
createtestvideo "The Starving Games (2013)" "{imdb-tt2403029}" "480" "480p" # imdb lowest
createtestvideo "The Wicker Man (2006)" "{imdb-tt0450345}" "480" "480p" # imdb lowest
createtestvideo "Troll 2 (1990)" "{imdb-tt0105643}" "480" "480p" # imdb lowest
createtestvideo "Winnie-the-Pooh: Blood and Honey (2023)" "{imdb-tt19623240}" "480" "480p" # imdb lowest

# IMDB most Popular
createtestvideo "Abigail (2024)" "{imdb-tt27489557}" "4k" "2160p" # imdb popular
createtestvideo "Amar Singh Chamkila (2024)" "{imdb-tt26658272}" "4k" "2160p" # imdb popular
createtestvideo "Anyone But You (2023)" "{imdb-tt26047818} {tmdb-1072790}" "480" "480p" # imdb popular
createtestvideo "Anyone But You (2023)" "{imdb-tt26047818}" "4k" "2160p" # imdb popular
createtestvideo "Argylle (2024)" "{imdb-tt15009428} {tmdb-848538}" "1080" "1080p" # imdb popular
createtestvideo "Argylle (2024)" "{imdb-tt15009428}" "4k" "2160p" # imdb popular
createtestvideo "Back to Black (2024)" "{imdb-tt21261712}" "4k" "2160p" # imdb popular
createtestvideo "Bade Miyan Chote Miyan (2024)" "{imdb-tt18072316}" "4k" "2160p" # imdb popular
createtestvideo "Challengers (2024)" "{imdb-tt16426418}" "4k" "2160p" # imdb popular
createtestvideo "Civil War (2024)" "{imdb-tt17279496}" "1080" "1080p" # imdb popular
createtestvideo "Damaged (2024)" "{imdb-tt27304026}" "1080" "1080p" # imdb popular
createtestvideo "Dune (2021)" "{imdb-tt1160419}" "1080" "1080p" # imdb popular
createtestvideo "Dune: Part One (2021)" "{imdb-tt1160419} {tmdb-438631}" "1080" "1080p" # imdb popular
createtestvideo "Dune: Part Two (2024)" "{imdb-tt15239678}" "1080" "1080p" # imdb popular
createtestvideo "Ghostbusters: Frozen Empire (2024)" "{imdb-tt21235248}" "1080" "1080p" # imdb popular
createtestvideo "Godzilla x Kong: The New Empire (2024)" "{imdb-tt14539740}" "1080" "1080p" # imdb popular
createtestvideo "Immaculate (2024)" "{imdb-tt23137390}" "1080" "1080p" # imdb popular
createtestvideo "Joker: Folie à Deux (2024)" "{imdb-tt11315808}" "720" "720p" # imdb popular
createtestvideo "Kingdom of the Planet of the Apes (2024)" "{imdb-tt11389872}" "720" "720p" # imdb popular
createtestvideo "Kung Fu Panda 4 (2024)" "{imdb-tt21692408}" "720" "720p" # imdb popular
createtestvideo "Late Night with the Devil (2023)" "{imdb-tt14966898}" "720" "720p" # imdb popular
createtestvideo "Love Lies Bleeding (2024)" "{imdb-tt19637052}" "720" "720p" # imdb popular
createtestvideo "Madame Web (2024)" "{imdb-tt11057302} {tmdb-634492}" "4k" "2160p" # imdb popular
createtestvideo "Monkey Man (2024)" "{imdb-tt9214772}" "720" "720p" # imdb popular
# createtestvideo "Oppenheimer (2023)" "{imdb-tt15398776}" "720" "720p" # imdb popular
createtestvideo "Poor Things (2023)" "{imdb-tt14230458} {tmdb-792307}" "720" "720p" # imdb popular
createtestvideo "Poor Things (2023)" "{imdb-tt14230458}" "576" "576p" # imdb popular
createtestvideo "Rebel Moon - Part One: A Child of Fire (2023)" "{imdb-tt14998742}" "576" "576p" # imdb popular
createtestvideo "Rebel Moon - Part Two: The Scargiver (2024)" "{imdb-tt23137904}" "576" "576p" # imdb popular
createtestvideo "Road House (2024)" "{imdb-tt3359350}" "576" "576p" # imdb popular
createtestvideo "Saltburn (2023)" "{imdb-tt17351924} {tmdb-930564}" "576" "576p" # imdb popular
createtestvideo "Scoop (2024)" "{imdb-tt21279806}" "576" "576p" # imdb popular
createtestvideo "Sleeping Dogs (2024)" "{imdb-tt8542964}" "576" "576p" # imdb popular
createtestvideo "Speak No Evil (2024)" "{imdb-tt27534307}" "576" "576p" # imdb popular
createtestvideo "The Beekeeper (2024)" "{imdb-tt15314262} {tmdb-866398}" "576" "576p" # imdb popular
createtestvideo "The Bricklayer (2023)" "{imdb-tt2016303}" "480" "480p" # imdb popular
createtestvideo "The Fall Guy (2024)" "{imdb-tt1684562}" "480" "480p" # imdb popular
createtestvideo "The First Omen (2024)" "{imdb-tt5672290}" "480" "480p" # imdb popular
createtestvideo "The Gentlemen (2019)" "{imdb-tt8367814}" "480" "480p" # imdb popular
createtestvideo "The Ministry of Ungentlemanly Warfare (2024)" "{imdb-tt5177120}" "480" "480p" # imdb popular
createtestvideo "The Talented Mr. Ripley (1999)" "{imdb-tt0134119}" "480" "480p" # imdb popular
createtestvideo "The Zone of Interest (2023)" "{imdb-tt7160372}" "480" "480p" # imdb popular
createtestvideo "Transformers One (2024)" "{imdb-tt8864596}" "480" "480p" # imdb popular
createtestvideo "Trap (2024)" "{imdb-tt26753003}" "480" "480p" # imdb popular
createtestvideo "Upgraded (2024)" "{imdb-tt21830902} {tmdb-1014590}" "480" "480p" # imdb popular
createtestvideo "Wish (2023)" "{imdb-tt11304740}" "480" "480p" # imdb popular
createtestvideo "Wonka (2023)" "{imdb-tt6166392} {tmdb-787699}" "720" "720p" # imdb popular

# IMDB Top 250
createtestvideo "12th Fail (2023)" "{imdb-tt23849204}" "4k" "2160p" # imdb top
createtestvideo "Alien (1979)" "{imdb-tt0078748}" "4k" "2160p" # imdb top
createtestvideo "Amadeus (1984)" "{imdb-tt0086879}" "4k" "2160p" # imdb top
createtestvideo "American Beauty (1999)" "{imdb-tt0169547}" "4k" "2160p" # imdb top
createtestvideo "Apocalypse Now (1979)" "{imdb-tt0078788}" "4k" "2160p" # imdb top
createtestvideo "Avengers: Endgame (2019)" "{imdb-tt4154796}" "4k" "2160p" # imdb top
createtestvideo "Dead Poets Society (1989)" "{imdb-tt0097165}" "4k" "2160p" # imdb top
createtestvideo "Django Unchained (2012)" "{imdb-tt1853728}" "4k" "2160p" # imdb top
createtestvideo "Dune: Part Two (2024)" "{imdb-tt15239678}" "4k" "2160p" # imdb top
createtestvideo "Fight Club (1999)" "{imdb-tt0137523}" "4k" "2160p" # imdb top
createtestvideo "Ford v Ferrari (2019)" "{imdb-tt1950186}" "1080" "1080p" # imdb top
createtestvideo "Forrest Gump (1994)" "{imdb-tt0109830}" "1080" "1080p" # imdb top
createtestvideo "Gladiator (2000)" "{imdb-tt0172495}" "1080" "1080p" # imdb top
createtestvideo "Godzilla Minus One (2023)" "{imdb-tt23289160}" "1080" "1080p" # imdb top
createtestvideo "Gone Girl (2014)" "{imdb-tt2267998} {tmdb-210577}" "576" "576p" # imdb top
createtestvideo "Gone with the Wind (1939)" "{imdb-tt0031381}" "1080" "1080p" # imdb top
createtestvideo "Good Will Hunting (1997)" "{imdb-tt0119217}" "1080" "1080p" # imdb top
createtestvideo "Goodfellas (1990)" "{imdb-tt0099685}" "1080" "1080p" # imdb top
# createtestvideo "Green Book (2018)" "{imdb-tt6966692} {tmdb-490132}" "4k" "2160p" # imdb top
createtestvideo "Inception (2010)" "{imdb-tt1375666}" "1080" "1080p" # imdb top
createtestvideo "Inglourious Basterds (2009)" "{imdb-tt0361748}" "1080" "1080p" # imdb top
createtestvideo "Interstellar (2014)" "{imdb-tt0816692} {tmdb-157336}" "1080" "1080p" # imdb top
# createtestvideo "Interstellar (2014)" "{imdb-tt0816692}" "1080" "1080p" # imdb top
createtestvideo "Joker (2019)" "{imdb-tt7286456} {tmdb-475557}" "1080" "1080p" # imdb top
# createtestvideo "Joker (2019)" "{imdb-tt7286456}" "720" "720p" # imdb top
createtestvideo "Jurassic Park (1993)" "{imdb-tt0107290}" "720" "720p" # imdb top
createtestvideo "Kill Bill: Vol. 1 (2003)" "{imdb-tt0266697}" "720" "720p" # imdb top
createtestvideo "Léon: The Professional (1994)" "{imdb-tt0110413}" "720" "720p" # imdb top
createtestvideo "Mad Max: Fury Road (2015)" "{imdb-tt1392190}" "720" "720p" # imdb top
createtestvideo "No Country for Old Men (2007)" "{imdb-tt0477348}" "720" "720p" # imdb top
createtestvideo "Oppenheimer (2023)" "{imdb-tt15398776} {tmdb-872585}" "4k" "2160p" # imdb top
# createtestvideo "Oppenheimer (2023)" "{imdb-tt15398776}" "720" "720p" # imdb top
createtestvideo "Parasite (2019)" "{imdb-tt6751668}" "720" "720p" # imdb top
createtestvideo "Pirates of the Caribbean: The Curse of the Black Pearl (2003)" "{imdb-tt0325980}" "720" "720p" # imdb top
createtestvideo "Prisoners (2013)" "{imdb-tt1392214}" "720" "720p" # imdb top
createtestvideo "Pulp Fiction (1994)" "{imdb-tt0110912}" "576" "576p" # imdb top
createtestvideo "Schindler's List (1993)" "{imdb-tt0108052}" "576" "576p" # imdb top
createtestvideo "Se7en (1995)" "{imdb-tt0114369}" "576" "576p" # imdb top
createtestvideo "Snatch (2000)" "{imdb-tt0208092}" "576" "576p" # imdb top
createtestvideo "Spider-Man: Across the Spider-Verse (2023)" "{imdb-tt9362722} {tmdb-569094}" "576" "576p" # imdb top
# createtestvideo "Spider-Man: Across the Spider-Verse (2023)" "{imdb-tt9362722}" "576" "576p" # imdb top
createtestvideo "Spider-Man: No Way Home (2021)" "{imdb-tt10872600} {tmdb-634649}" "480" "480p" # imdb top
# createtestvideo "Spider-Man: No Way Home (2021)" "{imdb-tt10872600}" "576" "576p" # imdb top
createtestvideo "The Dark Knight (2008)" "{imdb-tt0468569}" "576" "576p" # imdb top
createtestvideo "The Departed (2006)" "{imdb-tt0407887}" "576" "576p" # imdb top
createtestvideo "The Godfather (1972)" "{imdb-tt0068646}" "576" "576p" # imdb top
createtestvideo "The Godfather Part II (1974)" "{imdb-tt0071562}" "576" "576p" # imdb top
createtestvideo "The Green Mile (1999)" "{imdb-tt0120689}" "480" "480p" # imdb top
createtestvideo "The Lord of the Rings: The Fellowship of the Ring (2001)" "{imdb-tt0120737}" "480" "480p" # imdb top
createtestvideo "The Matrix (1999)" "{imdb-tt0133093}" "480" "480p" # imdb top
createtestvideo "The Prestige (2006)" "{imdb-tt0482571}" "480" "480p" # imdb top
createtestvideo "The Shawshank Redemption (1994)" "{imdb-tt0111161}" "480" "480p" # imdb top
createtestvideo "The Silence of the Lambs (1991)" "{imdb-tt0102926}" "480" "480p" # imdb top
createtestvideo "The Usual Suspects (1995)" "{imdb-tt0114814}" "480" "480p" # imdb top
# createtestvideo "The Wolf of Wall Street (2013)" "{imdb-tt0993846} {tmdb-106646}" "480" "480p" # imdb top
# createtestvideo "The Wolf of Wall Street (2013)" "{imdb-tt0993846}" "480" "480p" # imdb top
createtestvideo "Top Gun: Maverick (2022)" "{imdb-tt1745960} {tmdb-361743}" "720" "720p" # imdb top
# createtestvideo "Top Gun: Maverick (2022)" "{imdb-tt1745960}" "480" "480p" # imdb top
createtestvideo "Whiplash (2014)" "{imdb-tt2582802} {tmdb-244786}" "720" "720p" # imdb top
# createtestvideo "Whiplash (2014)" "{imdb-tt2582802}" "480" "480p" # imdb top
