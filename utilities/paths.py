"""
File path construction and release group utilities.

Provides functions to build file paths for movies and episodes, clean
filenames, and select random release groups for media metadata.
"""
from pathlib import Path
import random
import re

releasegroups = ['100REAL', '12GaugeShotgun', '182K', '2160p', '3CTWEB', '3L',
                 '3rdJLoMovieOfTheMonth', '4K', '4K4U', '4KBEC', '4kkkk', '4KN',
                 '4kTRASH', '4LHD', '4XK', '9THW', 'ABBiE', 'ABOMiNABLE', 'ABUSE',
                 'AccomplishedYak', 'acornnut', 'ADE', 'ADiOS', 'ADWeb',
                 'AfterYouHaveNothingElseToWatch', 'AGAiN', 'AilMWeb',
                 'AirForceOne', 'Aisha', 'AjA', 'AJP69', 'AKARi', 'AKG', 'AKi',
                 'aKraa', 'AKU', 'alfaHD', 'AlluringMooseOfExoticArtistry',
                 'AlteZachen', 'AMBiSONiC', 'AMORT', 'An0nym0us', 'ANAB0L1C',
                 'AnimeIsMyWaifu', 'ANNT', 'Anonymous', 'ANOREXIC', 'AntGod',
                 'AOC', 'apex', 'AppleTor', 'AR', 'Arabp2p',
                 'ArchetypalTruthfulPelicanOfWitchcraft', 'Archie', 'ARCTiC',
                 'AREY', 'AreYouLostBabyGirl', 'ARiC', 'ARiN', 'ARMO',
                 'ASCENDANCE', 'ASCENT', 'ASM', 'AV', 'AVI', 'Azkars', 'BAE',
                 'BaldNeonSalmonFromAsgard', 'BALENCiAGA', 'BANDOLEROS', 'BATWEB',
                 'BAUCHBEiNEPO', 'BBHMM', 'BDHD', 'BeCareful', 'BeerGAS', 'BEN',
                 'BestWEB', 'BetterCallSaul', 'BETTY', 'BHAiJAAN', 'BIGDOC',
                 'BiGiL', 'BiOMA', 'BIT', 'BiTCHNUGGET', 'BiTOR', 'BiZKiT',
                 'BLASPHEMY', 'BLKFLX', 'BluDragon', 'BLUEBIRD', 'BLURANiUM',
                 'BLUTONiUM', 'BobaFett', 'BONBON', 'BongAndTits', 'Booba',
                 'BOOMERs', 'BootyShaker', 'BOUJEE', 'BOUNTYTOOBIGTOIGNORE',
                 'BRAINS', 'BRKBD', 'BROTHERHOOD', 'BROZONED', 'BRYNOLF', 'BTN',
                 'BurCyg', 'BurrowingArtichokeCraneOfYouth', 'BUSSY', 'BUTTERCUP',
                 'BYNDR', 'BYZANTINE', 'C4K', 'C76', 'CALLi', 'Candial',
                 'CANTDO4kBEC', 'carlo', 'CAS', 'CatAiD', 'CATALOGUEDUMP', 'CBFM',
                 'CC', 'CEBEX', 'cfandora', 'CHDWEB', 'CHiCO', 'Chintu', 'CHOPiN',
                 'chr00t', 'CHUTKi', 'Cinefeel', 'CiNEPHiLES', 'CiUHD', 'cj',
                 'CLASSiC', 'CLEDIS', 'CM', 'CMN', 'CMRG', 'CMRG-Dual', 'CoCo',
                 'CODY', 'COMEDY', 'CompetentRighteousWombatFromAsgard',
                 'CONSORTiUM', 'COPiUM', 'CORRUPTiON', 'COYS', 'CPTN5DW',
                 'CRANiUM', 'CRFW', 'CRiMiNAL', 'CRLS', 'CTFOH', 'CTRLWEB',
                 'CUPCAKES', 'Cybertron', 'Cygnus', 'D3VB00TY', 'DADY', 'Dank',
                 'Dave', 'dB', 'dBBd', 'DDH', 'DDR', 'DEAL', 'DEFLATE',
                 'DeftSpectacularKoelOfDomination', 'DEMENTiA', 'DENEB', 'DepraveD',
                 'DETROIT', 'DEVIL', 'DeViSiVE', 'DiLF', 'DisCord', 'DiVA', 'DKM',
                 'DKS', 'DLx264', 'DM', 'DMMA', 'DMPD', 'DNB', 'DNServ', 'DOCiLE',
                 'DOG', 'DOLORES', 'DOLPHiN', 'DON', 'DONUTS', 'doraemon', 'DoVi',
                 'dOwn', 'DRAUGR', 'DRAWIZ', 'DreamHD', 'DRG', 'DriverChettan',
                 'DrS', 'DRX', 'DTR', 'DUALAUDIO', 'DUS', 'DUS-IcTv', 'DusIcTv',
                 'DVDWO', 'DVSUX', 'E.N.D', 'EASports', 'ECLiPSE', 'EDGE2020',
                 'EDITH', 'EDPH', 'EDV', 'EfficientNeatChachalacaOfOpportunity',
                 'EGEN', 'Ehrenfried', 'elackops', 'ElecTr0n', 'EMPATHY', 'EMX',
                 'ENDISNEAR', 'EniaHD', 'EnteTouchPoyi', 'EPSilON', 'ERBiUM',
                 'ERiX', 'ESCAPE', 'ETHEL', 'EVERYTHINGISPOSSIBLE', 'EVO',
                 'EXTREME', 'EZPLZ', 'EZPz', 'EzTruth', 'FAiRGAME', 'FAMILY',
                 'FARTS', 'FAWR', 'FCK', 'FEiJOADA', 'FERMi', 'Ferrum', 'FF',
                 'FGT', 'FHC', 'FiNiX', 'FLAME', 'Flights', 'FLOP', 'FLP',
                 'FLTTH', 'FLUX', 'FOXi', 'FraMeSToR', 'FRATERNiTY', 'FRDS',
                 'Freek911', 'FrIeNdS', 'FurryFox', 'FW', 'FWB', 'FX', 'FZHD',
                 'GameData', 'GASMASK', 'gattopollo', 'gazprom', 'GHD',
                 'GiganticEvasiveYakOfArgument', 'GigCle', 'GINO', 'Gir0h',
                 'Gloft', 'GNOME', 'GNOMiSSiON', 'GOLDENSHOWER', 'Gorgeous',
                 'GPTHD', 'GROGU', 'GRONK', 'GST', 'GTorg', 'GUACAMOLE', 'Haala',
                 'HAHAHA', 'HAHAHAHAHA', 'hallowed', 'HappyAlle', 'HaresWEB',
                 'HATINGADULTS', 'HBO', 'HD', 'HDBart', 'HDH', 'HDHWEB',
                 'HDKylinWEB', 'HDMA', 'HDS', 'HDSWEB', 'HdT', 'HDVWEB', 'HE',
                 'HEATHEN', 'HEHE', 'HEHEHE', 'HEHEHEHE', 'HELLSKiTCHEN', 'HEVC',
                 'HHWEB', 'Hiei', 'HiggsBoson', 'HiGH', 'HiHi', 'HiHiHiHi',
                 'HiHiHiHiHi', 'Hiro360', 'HiTCH', 'HLW', 'HMMM', 'HO', 'HOA',
                 'HOHO', 'HOHOHOHO', 'HOHOHOHOHO', 'HONE', 'Honey', 'HONOR',
                 'HOTLiPS', 'Hoyts', 'HPF', 'HQC', 'HTFS', 'HTP', 'HUHUHU',
                 'HumongousWoodooRhinoOfFinesse', 'HUZZAH', 'HY', 'HYHY', 'HYHYHY',
                 'HYMN', 'HypStu', 'iCMAL', 'IcTv', 'IFCKINGLOVENF',
                 'iFEViLWHYCUTE', 'ifjh', 'iFT', 'iKA', 'IKHNTDO4k', 'iLOVEYOU',
                 'Imagine', 'ImLovinIt', 'Immortal', 'Infamous',
                 'IniKaanaPovathuNijam', 'iNTENSO', 'IONICBOY', 'IPPORAATHRI',
                 'iRENE', 'iSSEYMiYAKE', 'iTE', 'ItsOk', 'iZO', 'J2GWEB', 'JATT',
                 'JAVLAR', 'JazzmansPink', 'JBYWEBHD', 'jennaortegaUHD',
                 'JiNJiNNaKKaDi', 'JKP', 'Jr', 'Json', 'JUNGLIST', 'JY25', 'K',
                 'KamiKaze', 'KaPPa', 'kbox', 'KC', 'KDOC', 'kellerratte', 'KHEZU',
                 'KHN', 'KiNGKHAN', 'KiNGSMAN', 'KIRA', 'KisColourKeKeys',
                 'Kitsune', 'KL', 'KnightRanger', 'kogi', 'Kowalski',
                 'KRaLiMaRKo', 'KTM', 'KUBER', 'KUCHU', 'KUMiN', 'KURiSU', 'KWK',
                 'L1avZh', 'LAMA', 'Laska', 'LatTeam', 'LAViSH', 'LAZY',
                 'LAZYCUNTS', 'LC', 'LeagueWEB', 'LeeCHDWEB', 'LEGi0N', 'Licdom',
                 'LiEFDE', 'LikeNFShows', 'LiQUiD', 'LiQWEB', 'LKST', 'LLL', 'LM',
                 'LoKeSH', 'LookUP', 'lost', 'LouLaVie', 'LOVEBiRD', 'LSS',
                 'LuciferCat', 'LUNGIANNA', 'M2P', 'mAck', 'Madeyemaddoc',
                 'MADHURi', 'MADSKY', 'MAMA', 'MARCOSKUPAL', 'MARK', 'MARKISBI',
                 'MARKISGAE', 'MaX', 'McNULTY', 'MeDaddy', 'MediaHoarderz', 'Meh',
                 'MEHH', 'MEME2', 'MenantuComel', 'MgB', 'MGE', 'MH', 'MikeTython',
                 'MiON', 'Miss', 'MiU', 'MJOLNiR', 'MKayV', 'mkvCinemas', 'MNRV',
                 'MOANaLOUDER', 'Mokahk', 'monkee', 'MONKEY', 'MORRICONE', 'MOTHER',
                 'MP12365', 'MPx', 'MrudhuBhaaveDhrudaKruthye', 'MTV', 'MULTiPLEX',
                 'MULTiVERSE', 'MUR4YAMA', 'MURiNGA', 'Murphy', 'MUSTANG', 'MVL',
                 'MWEB', 'MwoneJaada', 'MXY', 'MyHeartWillGoOn', 'MyKing',
                 'MYSPLEEN-MYSPLEEN', 'MZABI', 'NaB', 'NAF', 'NAHOM', 'NAISU',
                 'NaNi', 'NaniwaChan', 'NaniwaDanshi', 'NBR', 'NBRETAiL', 'NCmt',
                 'Ncw3qvm', 'NDD', 'nemmyg', 'NEOLUTiON', 'Neon', 'nest', 'NEW',
                 'NewYear', 'NiCO', 'NiDO', 'NiksINDIAN', 'NIMA4K',
                 'NimbleJudiciousFlamingoOfAuthority', 'NiRMATA', 'NiTK', 'NM21',
                 'NN', 'NOAH', 'Nobody', 'NoG', 'NoGroup', 'NoGrp',
                 'NoisyRedOtterOfReading', 'NOMA', 'NONE', 'NORViNE', 'NOSiViD',
                 'NotAPEX', 'NotEVO', 'NOTME', 'NotSharedPW', 'notthepedo', 'NTb',
                 'NTFL', 'NTG', 'NTROPiC', 'NTSTATUS', 'NUBER', 'oarton27',
                 'Oldstyle', 'OneDayToday', 'ONLY', 'OPiUM', 'OPUS', 'OSCAR',
                 'OurTV', 'Ov', 'OWiE', 'OzlerNingalPranayichitundo', 'PALMACiNO',
                 'PandaMoon', 'PaODEQUEiJO', 'ParkHD', 'PaSp', 'PBO', 'PEBBLES104',
                 'Penelope', 'Petrichor', 'PETRiFiED', 'PFa', 'PHDM', 'PHOENiX',
                 'PHOSPHENE', 'PiA', 'PiCCiNiNO', 'PiG30N', 'PineapplePizza',
                 'PiNKVENOM', 'PiRaTeS', 'PiTBULL', 'PitiPati', 'PLAN',
                 'PlatinumBlack', 'playBD', 'PLAYON', 'PLAYREADY', 'playTV',
                 'playWEB', 'pmHD', 'PMI', 'PmP', 'PMS', 'POKE', 'POLiTiCS',
                 'POWER', 'PP', 'pQ', 'PR0PER', 'PRETTYiNPiNK', 'PrimeFix',
                 'ProAce', 'ProTem', 'PSiG', 'PSTX', 'pt520', 'PTer', 'PTerWEB',
                 'PTF', 'PTHweb', 'PtP', 'PussyFoot', 'PuTao', 'QfG', 'QHstudIo',
                 'QTZ', 'R', 'RABiDS', 'Radarr', 'RaggaMuffin', 'Rain', 'RAMBO',
                 'RandH', 'RANSOM', 'RAPiDCOWS', 'Rare', 'RAV1NE', 'RCDiVX', 'RDC',
                 'REBiRTH', 'REBUK', 'redd', 'RedHeartsRedHeartsThatsWhatIamOn',
                 'REMUX-statiksh0ck', 'REVOLT', 'rEx', 'Rick', 'RiCKY', 'RiLE',
                 'RiPER', 'RiV', 'RMS', 'RNG', 'ROBOTS', 'ROCCaT', 'ROFL',
                 'ROMANTiC', 'RONIN', 'RSG', 'RU4HD', 'RUMOUR', 'RVKD', 'RypS',
                 'SABZIWALA', 'SAFETY', 'SAKADOX', 'SALT', 'saMMie', 'Sarry',
                 'SARVO', 'SasukeducK', 'SATANiC', 'SAUERKRAUT', 'SaukeducK',
                 'SCARECREW', 'SCHNiTZEL', 'Scoiatael', 'SCOPE', 'SECRECY',
                 'SEiGHT', 'SEIKEL', 'SEMANTiCS', 'SENAD', 'SEVERIN', 'SEX',
                 'SEXXY', 'SEXY', 'SexyAI', 'SF', 'SFs', 'SGF', 'SH3LBY',
                 'sh4down', 'SHANKARA', 'SHAREDPW', 'SharkWEB', 'SHD', 'SHIIIT',
                 'ShiNobi', 'SHiTRiPS', 'SHOT', 'SiC', 'SiCFoI', 'SiGLA',
                 'Sigtumb', 'SiSSY', 'SiXTYNiNE', 'Skav',
                 'SkilledMelodicSparrowFromHyperborea', 'SKiZOiD', 'Skull', 'SLAG',
                 'Slay3R', 'SLiM', 'SLOT', 'Slutz',
                 'SmilingAbidingSeriemaFromEldorado', 'SMURF', 'SNiFF', 'SNiPER',
                 'SNOOP', 'SNTK', 'SOFCJ', 'Sororitits', 'SowHD', 'SP', 'SP4K',
                 'SPECT3R', 'SPHD', 'Spidey', 'SPiRiT', 'SPOOKY',
                 'SpryFeatheredHornetOfEnhancement', 'STAF', 'starktony', 'STATiK',
                 'statiksh0ck', 'SteadfastGrayTarantulaOfPriority', 'STiNG',
                 'StopTheShorts', 'STOPTHESMURF', 'str0ke', 'Strafe', 'Subaashe',
                 'SUPPLY', 'SwAgLaNdEr', 'SWTYBLZ', 'SymBiOTes', 'T4H', 'TAGWEB',
                 'TamilMV', 'Tars', 'tarunk9c', 'TateBrothers', 'Tayy', 'TB',
                 'TBD', 'tcshades', 'Team', 'TeamHD', 'telemO', 'Telly', 'TEMHO',
                 'TeMPo', 'TEPES', 'TERMiNAL', 'TFA', 'TFBOYS', 'tG1R0',
                 'TheBiscuitMan', 'TheDNK', 'THEEND', 'THELEGENDOF1900',
                 'ThistleQuokkaOfScientificChampagne', 'THUNDER', 'TibetIcon',
                 'TIMECUT', 'TJUPT', 'TMSF', 'TMV', 'TOMMY', 'tomorrow505',
                 'TOOSA', 'Top10UKSingle', 'TossPot', 'TPaRT', 'TREBLE', 'TRF',
                 'TRiP', 'TRIPEL', 'TRiToN', 'TRMP', 'TrollUHD', 'TRULUV', 'TSCC',
                 'TTT', 'TungstenHyraxOfPremiumChampagne', 'TURG', 'TURKiSH', 'Tux',
                 'TvR', 'Tyrell', 'Tysha', 'UHDTV', 'UKDHD', 'UNDERTAKERS',
                 'UNITED24', 'UnKn0wn', 'UnknownMan', 'UNTHEVC', 'UPD',
                 'UPiNSMOKE', 'UTT', 'VAATHI', 'VARYG', 'VATAPA', 'VD0N', 'VECTOR',
                 'VEEPZ', 'VHANS', 'VHS', 'ViCTORS', 'VideoGod', 'ViETNAM',
                 'ViLLAiN', 'VisionXpert', 'Vitaly', 'ViVAAFRiCA', 'VoltaX',
                 'VoraciousRoosterOfAbsoluteWholeness', 'VoX', 'VOYAGES', 'VS',
                 'W32', 'W3iRD', 'w4k', 'WA', 'WADU', 'WaLKAFaLKA', 'walt',
                 'WARUI', 'WATCHER', 'WAYNE', 'WDYM', 'WeAreNotThere', 'WeAreOne',
                 'WEBLE', 'WEGOJIM', 'WELP', 'WFTp',
                 'WhisperingSpectacularOysterOfImprovement', 'WHOLETTHEDOGSOUT',
                 'WHYNOTGIRLS', 'WICKEDWEASEL', 'WiLDCAT', 'WiNE', 'WiNEY',
                 'WinOrLose', 'WINX', 'WiTCHCRAFT', 'WKS', 'Wondering', 'WORLD',
                 'wuzhetian', 'x265-17GB', 'xasi', 'XB', 'XBGB', 'xblz', 'XEBEC',
                 'xiaopieCHDWEB', 'XiQUEXiQUE', 'XiSS', 'XME', 'xpost', 'XtreamHD',
                 'xwMaRio', 'YAGAMi', 'YamRaaJ', 'YH', 'YingWEB', 'YInMn', 'YODA',
                 'YouDontScareMe', 'YOUNGDUMBANDBROKE', 'YTDL', 'YummY', 'Zapax',
                 'zek', 'ZeroTwo', 'ZESTY', 'ZEW', 'ZiYan', 'ZmWeb', 'ZONEHD',
                 'ZoroSenpai', 'ZORZI', 'ZQ', 'ZS', 'ZTR', 'Zzz']

def get_random_release_group ():
    return random.choice(releasegroups)

def clean_file_name(file_name: str) -> str:
    file_name = re.sub(r"/", "-", file_name)
    file_name = re.sub(r" +", " ", file_name)
    file_name = re.sub(r":", "", file_name)
    file_name = re.sub(r"\?", "", file_name)
    file_name = re.sub(r"…", "...", file_name)
    file_name = re.sub(r"[éèêë]", "e", file_name)
    file_name = re.sub(r"[àáâä]", "a", file_name)
    file_name = re.sub(r"[ç]", "c", file_name)
    file_name = re.sub(r"[üù]", "u", file_name)
    file_name = re.sub(r"[öô]", "o", file_name)
    file_name = re.sub(r"[îï]", "i", file_name)
    return file_name

def build_file_path(settings, media_data):
    #  series_data = {
    #    "title": title,
    #    "year": year,
    #    "tvdb_id": tvdb_id,
    #    "episode_order": episode_order
    #  }

    if 'imdb_id' in media_data:
        # this is a movie
        if media_data['edition']:
            settings['edition'] = f"{{edition-{media_data['edition']}}}"

        base_name = f"{media_data['title']} ({media_data['year']}) {{imdb-{media_data['imdb_id']}}}"
        if settings['edition']:
            base_name += f" {settings['edition']}"

        base_name = base_name.strip()

    else:
        if media_data['episode_order'] == 'official':
            settings['episode_order'] = ""

        base_name = f"{media_data['title']} ({media_data['year']}) {{tvdb-{media_data['tvdb_id']}}} {settings['episode_order']}".strip()

    target_dir = f"{base_name}"
    target_dir = clean_file_name(target_dir)
    target_dir = f"{settings['library_folder']}/{target_dir}"

    Path(target_dir).mkdir(parents=True, exist_ok=True)

    file_name=f"{base_name} [{settings['source']}-{settings['resolution']} {settings['video_codec']} {settings['dv']} {settings['hdr']} {settings['audio_codec']}]-{settings['release_group']}.mkv"
    file_name = clean_file_name(file_name)

    return target_dir, file_name

def build_episode_file_path(series: dict, episode: dict, target_dir: str, settings: dict) -> str:
    # Construct the episode file name based on the episode metadata and settings
    episode_file_name = f"{series['name']} - S{episode['seasonNumber']:02}E{episode['number']:02} - {episode['name']} - [{settings['source']}-{settings['resolution']} {settings['video_codec']} {settings['dv']} {settings['hdr']} {settings['audio_codec']}]-{settings['release_group']}.mkv"
    episode_file_name = clean_file_name(episode_file_name)
    return f"{target_dir}/{episode_file_name}"
