require "lib/Collider.rb"
require "lib/Misc.rb"
require "lib/Datas.rb"
require "lib/Objects.rb"
require "lib/Events.rb"
require "lib/Enemies.rb"

require_all "mods/**/*.rb" if !VANILLA

module Level
    Hills = 0
    Tree = 1
    Shore = 2
    Water = 3
    House = 4
    Forest = 5
    Ruins = 6
    Forest_2 = 7
    Dark_Forest = 8
    Forest_Abyss = 9
    Sanctuary = 10
    Avenue = 11
    Plateau = 12
    City = 13
    Desert = 14
    Temple = 15
    Cave = 16
    Ice_Cave = 17
    Shi_Base = 18
    Fire_Cave = 19
    Volcano = 20
    Sewer = 21
    Wreck = 22
    District = 23
    Testsite = 24
    Launcher = 25
    Yunada = 26
    Sanatorium = 27
    Unknown = 28
    Factory = 29
    Dark_Path = 30
    
    Name = {"1-0-1" => "W10",
            "1-1-1" => "W11",
            "1-1-2" => "W11",
            "1-2-1" => "W11",
            "1-2-2" => "W11",
            "1-2-3" => "W11",
            "1-3-1" => "W12",
            "1-3-2" => "W12",
            "1-4-1" => "W12",
            "1-4-2" => "W12",
            "1-5-1" => "W13",
            "1-5-2" => "W13",
            "1-5-3" => "W13",
            "1-6-1" => "W13",
            "1-7-1" => "W14",
            "1-7-2" => "W14",
            "1-7-3" => "W14",
            "1-8-1" => "W14",
            "1-8-2" => "W15",
            "1-9-1" => "W15",
            "1-9-2" => "W15",
            "1-9-3" => "W15",
            "1-9-4" => "W15",
            "2-1-1" => "W21",
            "2-1-2" => "W21",
            "2-2-1" => "W21",
            "2-2-2" => "W21",
            "2-3-1" => "W22",
            "2-3-2" => "W22",
            "2-4-1" => "W22",
            "2-4-2" => "W22",
            "2-5-1" => "W23",
            "2-5-2" => "W23",
            "2-5-3" => "W23",
            "2-6-1" => "W23",
            "2-6-2" => "W23",
            "2-7-1" => "W24",
            "2-7-2" => "W24",
            "2-7-3" => "W24",
            "2-8-1" => "W24",
            "2-8-2" => "W24",
            "2-8-3" => "W24",
            "2-9-1" => "W25",
            "2-9-2" => "W25",
            "2-9-3" => "W25",
            "2-10-1"=> "W25",
            "2-10-2"=> "W25",
            "2-11-1"=> "W26",
            "2-11-2"=> "W26",
            "3-1-1" => "W31",
            "3-1-2" => "W31",
            "3-2-1" => "W31",
            "3-2-2" => "W31",
            "3-3-1" => "W32",
            "3-3-2" => "W32",
            "3-4-1" => "W32",
            "3-4-2" => "W32",
            "3-5-1" => "W33",
            "3-5-2" => "W33",
            "3-5-3" => "W33",
            "3-6-1" => "W33",
            "3-6-2" => "W33",
            "3-7-1" => "W34",
            "3-7-2" => "W34",
            "3-7-3" => "W34",
            "3-7-4" => "W34",
            "3-8-1" => "W34",
            "3-8-2" => "W34",
            "3-9-1" => "W35",
            "3-9-2" => "W35",
            "3-10-1"=> "W35",
            "3-10-2"=> "W35",
            "3-11-1"=> "W36",
            "3-11-2"=> "W36",
            "3-11-3"=> "W36",
            "4-1-1" => "W41",
            "4-1-2" => "W41",
            "4-2-1" => "W41",
            "4-2-2" => "W41",
            "4-3-1" => "W42",
            "4-3-2" => "W42",
            "4-4-1" => "W42",
            "4-4-2" => "W42",
            "4-5-1" => "W43",
            "4-5-2" => "W43",
            "4-5-3" => "W43",
            "4-5-4" => "W43",
            "4-6-1" => "W43",
            "4-6-2" => "W43",
            "4-7-1" => "W44",
            "4-7-2" => "W44",
            "4-7-3" => "W44",
            "4-8-1" => "W44",
            "4-8-2" => "W44",
            "4-9-1" => "W45",
            "4-9-2" => "W45",
            "4-10-1"=> "W45",
            "4-10-2"=> "W45",
            "4-10-3"=> "W45",
            "5-1-1" => "W51",
            "5-1-2" => "W51",
            "5-2-1" => "W51",
            "5-2-2" => "W51",
            "5-3-1" => "W52",
            "5-3-2" => "W52",
            "5-3-3" => "W52",
            "5-4-1" => "W52",
            "5-4-2" => "W52",
            "5-5-1" => "W53",
            "5-5-2" => "W53",
            "5-5-3" => "W53",
            "5-5-4" => "W53",
            "5-5-5" => "W53",
            "5-6-1" => "W53",
            "5-6-2" => "W53",
            "5-7-1" => "W54",
            "5-7-2" => "W54",
            "5-8-1" => "W54",
            "5-8-2" => "W54",
            "5-9-1" => "W55",
            "5-9-2" => "W55",
            "5-9-3" => "W55",
            "5-10-1" => "W55",
            "5-10-2" => "W55"
           }
    Desc = {"1-0-1" => "Cleanbuil Debug",
            "1-1-1" => "Cleanbuil Meadow 1-1",
            "1-1-2" => "Cleanbuil Meadow 1-2",
            "1-2-1" => "Cleanbuil Meadow 2-1",
            "1-2-2" => "Cleanbuil Meadow 2-2",
            "1-2-3" => "Cleanbuil Meadow 2-3",
            "1-3-1" => "Cleanbuil Shore 1-1",
            "1-3-2" => "Cleanbuil Shore 1-2",
            "1-4-1" => "Cleanbuil Lake 1-1",
            "1-4-2" => "Cleanbuil Lake 1-2",
            "1-5-1" => "Cleanbuil Meadow 3-1",
            "1-5-2" => "Cleanbuil Meadow 3-2",
            "1-5-3" => "Cleanbuil Meadow 3-3",
            "1-6-1" => "Hedgehound's House",
            "1-7-1" => "Cleanbuil Shore 2-1",
            "1-7-2" => "Cleanbuil Shore 2-2",
            "1-7-3" => "Cleanbuil Shore 2-3",
            "1-8-1" => "Cleanbuil Ruins 1",
            "1-8-2" => "Cleanbuil Ruins 2",
            "1-9-1" => "Cleanbuil Lake 2-1",
            "1-9-2" => "Cleanbuil Lake 2-2",
            "1-9-3" => "Cleanbuil Lake 2-3",
            "1-9-4" => "Cleanbuil Lake 2-4",
            "2-1-1" => "Dominwood West 1-1",
            "2-1-2" => "Dominwood West 1-2",
            "2-2-1" => "Dominwood West 2-1",
            "2-2-2" => "Dominwood West 2-2",
            "2-3-1" => "Dominwood East 1-1",
            "2-3-2" => "Dominwood East 1-2",
            "2-4-1" => "Dominwood East 2-1",
            "2-4-2" => "Dominwood East 2-2",
            "2-5-1" => "Dominwood East 3-1",
            "2-5-2" => "Dominwood East 3-2",
            "2-5-3" => "Dominwood East 3-3",
            "2-6-1" => "Nautawood 1-1",
            "2-6-2" => "Nautawood 1-2",
            "2-7-1" => "Nautawood 2-1",
            "2-7-2" => "Nautawood 2-3",
            "2-7-3" => "Nautawood 2-2",	# Intended! Because of section exchange.
            "2-8-1" => "Nautabyss 1-1",
            "2-8-2" => "Nautabyss 1-2",
            "2-8-3" => "Nautabyss 1-3",
            "2-9-1" => "Nautabyss 2-1",
            "2-9-2" => "Nautabyss 2-2",
            "2-9-3" => "Nautabyss 2-3",
            "2-10-1"=> "Dominwood West 3-1",
            "2-10-2"=> "Dominwood West 3-2",
            "2-11-1"=> "Dominwood Sanctuary 1",
            "2-11-2"=> "Dominwood Sanctuary 2",
            "3-1-1" => "Park Avenue 1-1",
            "3-1-2" => "Park Avenue 1-2",
            "3-2-1" => "Park Avenue 2-1",
            "3-2-2" => "Park Avenue 2-2",
            "3-3-1" => "Pond Bay 1",
            "3-3-2" => "Pond Bay 2",
            "3-4-1" => "West Hill Plateau 1-1",
            "3-4-2" => "West Hill Plateau 1-2",
            "3-5-1" => "West Hill Plateau 2-1",
            "3-5-2" => "West Hill Plateau 2-2",
            "3-5-3" => "West Hill Plateau 2-3",
            "3-6-1" => "Pond Meadow 1",
            "3-6-2" => "Pond Meadow 2",
            "3-7-1" => "Pondton City 1",
            "3-7-2" => "Pondton City 2",
            "3-7-3" => "Pondton City 3",
            "3-7-4" => "Pondton City 4",
            "3-8-1" => "UCA Base 1",
            "3-8-2" => "UCA Base 2",
            "3-9-1" => "Sand Meadow 1-1",
            "3-9-2" => "Sand Meadow 1-2",
            "3-10-1"=> "Sand Meadow 2-1",
            "3-10-2"=> "Sand Meadow 2-2",
            "3-11-1"=> "Temple of Dyunteh 1",
            "3-11-2"=> "Temple of Dyunteh 2",
            "3-11-3"=> "Temple of Dyunteh 3",
            "4-1-1" => "Westton Cave 1-1",
            "4-1-2" => "Westton Cave 1-2",
            "4-2-1" => "Westton Cave 2-1",
            "4-2-2" => "Westton Cave 2-2",
            "4-3-1" => "Frost Cavern 1-1",
            "4-3-2" => "Frost Cavern 1-2",
            "4-4-1" => "Frost Cavern 2-1",
            "4-4-2" => "Frost Cavern 2-2",
            "4-5-1" => "Westton Base 1",
            "4-5-2" => "Westton Base 2",
            "4-5-3" => "Westton Base 3",
            "4-5-4" => "Westton Base 4",
            "4-6-1" => "Inferno Cavern 1",
            "4-6-2" => "Inferno Cavern 2",
            "4-7-1" => "Inferno Core 1",
            "4-7-2" => "Inferno Core 2",
            "4-7-3" => "Inferno Core 3",
            "4-8-1" => "Pondton Sewerage 1-1",
            "4-8-2" => "Pondton Sewerage 1-2",
            "4-9-1" => "Pondton Sewerage 2-1",
            "4-9-2" => "Pondton Sewerage 2-2",
            "4-10-1"=> "Ladamethah Wreck 1",
            "4-10-2"=> "Ladamethah Wreck 2",
            "4-10-3"=> "Ladamethah Wreck 3",
            "5-1-1" => "Shi District 1-1",
            "5-1-2" => "Shi District 1-2",
            "5-2-1" => "Shi District 2-1",
            "5-2-2" => "Shi District 2-2",
            "5-3-1" => "Shi Test Site 1",
            "5-3-2" => "Shi Test Site 2",
            "5-3-3" => "Shi Test Site 3",
            "5-4-1" => "Shi Launching Pad 1",
            "5-4-2" => "Shi Launching Pad 2",
            "5-5-1" => "Yunada Ship 1",
            "5-5-2" => "Yunada Ship 2",
            "5-5-3" => "Yunada Ship 3",
            "5-5-4" => "Yunada Ship 4",
            "5-5-5" => "Yunada Ship 5",
            "5-6-1" => "Shi Factory 1-1",
            "5-6-2" => "Shi Factory 1-2",
            "5-7-1" => "Shi Factory 2-1",
            "5-7-2" => "Shi Factory 2-2",
            "5-8-1" => "Shi Trail 1",
            "5-8-2" => "Shi Trail 2",
            "5-9-1" => "Shi Sanatorium 1",
            "5-9-2" => "Shi Sanatorium 2",
            "5-9-3" => "Shi Sanatorium 3",
            "5-10-1"=> "Yunada Bridge 1",
            "5-10-2"=> "Yunada Bridge 2"
            }
    
    Story = ["1-1", "1-2", "1-3", "1-4", "1-5",
             "2-1", "2-2", "2-3", "2-4", "2-5",
             "3-1", "3-2", "3-3", "3-4", "3-5",
             "4-1", "4-2", "4-3", "4-4", "4-5",
             "5-1", "5-2", "5-3", "5-4", "5-5", "5-10"]
    
    Bg = {"1-0-1" => "Volcano_Sky",
          "1-1-1" => "Sky",
          "1-1-2" => "Sky",
          "1-2-1" => "Sky",
          "1-2-2" => "Tree",
          "1-2-3" => "Sky",
          "1-3-1" => "Sky",
          "1-3-2" => "Sky",
          "1-4-1" => "Sky",
          "1-4-2" => "Sky",
          "1-5-1" => "Sky",
          "1-5-2" => "Sky",
          "1-5-3" => "Sky",
          "1-6-1" => "Sky",
          "1-7-1" => "Sky",
          "1-7-2" => "Sky",
          "1-7-3" => "Sky",
          "1-8-1" => "Sky",
          "1-8-2" => "Dark",
          "1-9-1" => "Dark",
          "1-9-2" => "Sky",
          "1-9-3" => "Sky",
          "1-9-4" => "Sky",
          "2-1-1" => "Forest",
          "2-1-2" => "Forest",
          "2-2-1" => "Forest",
          "2-2-2" => "Forest",
          "2-3-1" => "Forest",
          "2-3-2" => "Forest",
          "2-4-1" => "Forest",
          "2-4-2" => "Tree",
          "2-5-1" => "Forest",
          "2-5-2" => "Forest",
          "2-5-3" => "Forest",
          "2-6-1" => "Dark_Forest",
          "2-6-2" => "Dark_Forest",
          "2-7-1" => "Dark_Forest",
          "2-7-2" => "Dark_Forest",
          "2-7-3" => "Dark_Forest",
          "2-8-1" => "Dark_Forest",
          "2-8-2" => "Abyss",
          "2-8-3" => "Abyss",
          "2-9-1" => "Abyss",
          "2-9-2" => "Abyss",
          "2-9-3" => "Abyss",
          "2-10-1"=> "Forest",
          "2-10-2"=> "Forest",
          "2-11-1"=> "Forest",
          "2-11-2"=> "Forest",
          "3-1-1" => "Sky",
          "3-1-2" => "Sky",
          "3-2-1" => "Sky",
          "3-2-2" => "Sky",
          "3-3-1" => "Sunset_Sky",
          "3-3-2" => "Sunset_Sky",
          "3-4-1" => "Dark_Sky",
          "3-4-2" => "Dark_Sky",
          "3-5-1" => "Dark_Sky",
          "3-5-2" => "Dark_Sky",
          "3-5-3" => "Dark_Sky",
          "3-6-1" => "Dark_Sky",
          "3-6-2" => "Dark_Sky",
          "3-7-1" => "Sky",
          "3-7-2" => "Sky",
          "3-7-3" => "High_Sky",
          "3-7-4" => "High_Sky",
          "3-8-1" => "Dark",
          "3-8-2" => "Dark",
          "3-9-1" => "Sky",
          "3-9-2" => "Sky",
          "3-10-1"=> "Desert_Sky",
          "3-10-2"=> "Desert_Sky",
          "3-11-1"=> "Dark",
          "3-11-2"=> "Dark",
          "3-11-3"=> "Dark",
          "4-1-1" => "Cave",
          "4-1-2" => "Cave",
          "4-2-1" => "Cave",
          "4-2-2" => "Cave",
          "4-3-1" => "Cave",
          "4-3-2" => "Ice",
          "4-4-1" => "Ice",
          "4-4-2" => "Ice",
          "4-5-1" => "Cave",
          "4-5-2" => "Dark",
          "4-5-3" => "Dark",
          "4-5-4" => "Cave",
          "4-6-1" => "Cave",
          "4-6-2" => "Volcano",
          "4-7-1" => "Volcano",
          "4-7-2" => "Volcano_Sky",
          "4-7-3" => "Volcano",
          "4-8-1" => "Sewer",
          "4-8-2" => "Sewer",
          "4-9-1" => "Sewer",
          "4-9-2" => "Sewer",
          "4-10-1"=> "High_Sky",
          "4-10-2"=> "Volcano_Sky",
          "4-10-3"=> "Sunset_Sky",
          "5-1-1" => "Red_Sky",
          "5-1-2" => "Red_Sky",
          "5-2-1" => "Red_Sky",
          "5-2-2" => "Red_Sky",
          "5-3-1" => "Red_Sky",
          "5-3-2" => "Red_Sky",
          "5-3-3" => "Red_Sky",
          "5-4-1" => "Red_Sky",
          "5-4-2" => "Red_Sky",
          "5-5-1" => "Dark_Sky",
          "5-5-2" => "Dark_Sky",
          "5-5-3" => "Dark_Sky",
          "5-5-4" => "Dark_Sky",
          "5-5-5" => "Dark_Sky",
          "5-6-1" => "Factory",
          "5-6-2" => "Factory",
          "5-7-1" => "Factory",
          "5-7-2" => "Factory",
          "5-8-1" => "Lunar",
          "5-8-2" => "Lunar_Eclipse",
          "5-9-1" => "Sunset_Sky",
          "5-9-2" => "Sunset_Sky",
          "5-9-3" => "Sunset_Sky",
          "5-10-1"=> "Earth",
          "5-10-2"=> "Earth",
          "?-?-?" => "Sky"
         }
    Special = {"1-0-1" => "Nebula",
               "2-6-1" => "Nebula",
               "2-6-2" => "Nebula",
               "2-7-1" => "Nebula",
               "2-7-3" => "Nebula",
               "2-9-2" => "Nebula",
               "2-9-3" => "Nebula",
               "3-4-1" => "Nebula",
               "3-4-2" => "Nebula",
               "3-5-1" => "Nebula",
               "3-5-2" => "Nebula",
               "3-5-3" => "Nebula",
               "3-11-1"=> "Nebula",
               "4-2-1" => "Nebula",
               "4-2-2" => "Nebula",
               "4-3-1" => "Nebula",
               "4-3-2" => "Nebula",
               "4-4-1" => "Nebula",
               "4-4-2" => "Nebula",
               "4-6-1" => "Nebula",
               "4-6-2" => "Nebula",
               "4-7-1" => "Nebula",
               "4-7-3" => "Nebula",
               "4-9-1" => "Nebula",
               "5-8-1" => "Nebula",
               "5-8-2" => "Nebula"
              }
    Desc2 = {"1-0" => "Cleanbuil Debug",
             "1-1" => "Cleanbuil Meadow 1",
             "1-2" => "Cleanbuil Meadow 2",
             "1-3" => "Cleanbuil Shore 1",
             "1-4" => "Cleanbuil Lake 1",
             "1-5" => "Cleanbuil Meadow 3",
             "1-6" => "Hedgehound's House",
             "1-7" => "Cleanbuil Shore 2",
             "1-8" => "Cleanbuil Ruins",
             "1-9" => "Cleanbuil Lake 2",
             
             "2-1" => "Dominwood West 1",
             "2-2" => "Dominwood West 2",
             "2-3" => "Dominwood East 1",
             "2-4" => "Dominwood East 2",
             "2-5" => "Dominwood East 3",
             "2-6" => "Nautawood 1",
             "2-7" => "Nautawood 2",
             "2-8" => "Nautabyss 1",
             "2-9" => "Nautabyss 2",
             "2-10"=> "Dominwood West 3",
             "2-11"=> "Dominwood Sanctuary",
             
             "3-1" => "Park Avenue 1",
             "3-2" => "Park Avenue 2",
             "3-3" => "Pond Bay",
             "3-4" => "West Hill Plateau 1",
             "3-5" => "West Hill Plateau 2",
             "3-6" => "Pond Meadow",
             "3-7" => "Pondton City",
             "3-8" => "UCA Base",
             "3-9" => "Sand Meadow 1",
             "3-10"=> "Sand Meadow 2",
             "3-11"=> "Temple of Dyunteh",
             
             "4-1" => "Westton Cave 1",
             "4-2" => "Westton Cave 2",
             "4-3" => "Frost Cavern 1",
             "4-4" => "Frost Cavern 2",
             "4-5" => "Westton Base",
             "4-6" => "Inferno Cavern",
             "4-7" => "Inferno Core",
             "4-8" => "Pondton Sewerage 1",
             "4-9" => "Pondton Sewerage 2",
             "4-10"=> "Ladamethah Wreck",
             
             "5-1" => "Shi District 1",
             "5-2" => "Shi District 2",
             "5-3" => "Shi Test Site",
             "5-4" => "Shi Launching Pad",
             "5-5" => "Yunada Ship",
             "5-6" => "Shi Factory 1",
             "5-7" => "Shi Factory 2",
             "5-8" => "Shi Trail",
             "5-9" => "Shi Sanatorium",
             "5-10"=> "Yunada Bridge"
            }
    
    Connections = {"1-0" => [false, false, false, false],	# [DOWN, LEFT, RIGHT, UP]
                   "1-1" => [false, false, "1-0", "1-2"],
                   "1-2" => [false, false, "1-3", false],
                   "1-3" => [false, false, "1-7", "1-4"],
                   "1-4" => [false, false, "1-5", "1-6"],
                   "1-5" => [false, false, "2-1", false],
                   "1-6" => [false, false, false, false],
                   "1-7" => [false, false, false, "1-8"],
                   "1-8" => [false, false, false, "1-9"],
                   "1-9" => [false, false, false ,false],
                   
                   "2-1" => ["2-2", false, "2-12","2-6"],
                   "2-2" => ["2-10",false, "2-3", false],
                   "2-3" => [false, false, false, "2-4"],
                   "2-4" => [false, false, "2-5", false],
                   "2-5" => [false, false, "3-1", false],
                   "2-6" => [false, false, "2-7", false],
                   "2-7" => ["2-4", false, "2-8", false],
                   "2-8" => [false, false, "2-9", false],
                   "2-9" => [false, false, false, false],
                   "2-10"=> [false, false, "2-11",false],
                   "2-11"=> [false, false, "3-9", "2-5"],
                   
                   "3-1" => [false, false, false, "3-2"],
                   "3-2" => [false, false, "3-3", false],
                   "3-3" => ["3-4", false, "3-6", "3-8"],
                   "3-4" => [false, false, "3-5", false],
                   "3-5" => [false, false, "4-1", false],
                   "3-6" => ["3-5", false, false, "3-7"],
                   "3-7" => [false, false, "4-8", false],
                   "3-8" => [false, false, false, false],
                   "3-9" => [false, false, "3-10",false],
                   "3-10"=> [false, false, "3-11","3-4"],
                   "3-11"=> [false, false, false, false],
                   
                   "4-1" => [false, false, "4-2", false],
                   "4-2" => ["4-6", false, "4-3", false],
                   "4-3" => ["4-4", false, false, false],
                   "4-4" => ["4-5", false, false, false],
                   "4-5" => [false, false, "5-1", false],
                   "4-6" => [false, "4-7", "4-4", false],
                   "4-7" => [false, false, false, false],
                   "4-8" => [false, false, "4-9", false],
                   "4-9" => ["4-3", false, "4-10",false],
                   "4-10"=> [false, false, false, false],
                   
                   "5-1" => [false, false, false, "5-2"],
                   "5-2" => [false, false, "5-3", false],
                   "5-3" => [false, false, "5-4", "5-8"],
                   "5-4" => ["5-6", false, false, "5-5"],
                   "5-5" => [false, false, "5-10",false],
                   "5-6" => [false, false, "5-7", false],
                   "5-7" => [false, false, false, false],
                   "5-8" => [false, "5-9", false, false],
                   "5-9" => [false, false, false, false],
                   "5-10"=> [false, false, false, false]
                   }
    Symbols = {"1-0" => Forest,
               "1-1" => Hills,
               "1-2" => Tree,
               "1-3" => Shore,
               "1-4" => Water,
               "1-5" => Hills,
               "1-6" => House,
               "1-7" => Shore,
               "1-8" => Ruins,
               "1-9" => Water,
               
               "2-1" => Forest,
               "2-2" => Forest,
               "2-3" => Forest_2,
               "2-4" => Forest_2,
               "2-5" => Forest_2,
               "2-6" => Dark_Forest,
               "2-7" => Dark_Forest,
               "2-8" => Forest_Abyss,
               "2-9" => Forest_Abyss,
               "2-10"=> Forest,
               "2-11"=> Sanctuary,
               
               "3-1" => Avenue,
               "3-2" => Avenue,
               "3-3" => Shore,
               "3-4" => Plateau,
               "3-5" => Plateau,
               "3-6" => Hills,
               "3-7" => City,
               "3-8" => Ruins,
               "3-9" => Desert,
               "3-10"=> Desert,
               "3-11"=> Temple,
               
               "4-1" => Cave,
               "4-2" => Cave,
               "4-3" => Ice_Cave,
               "4-4" => Ice_Cave,
               "4-5" => Shi_Base,
               "4-6" => Fire_Cave,
               "4-7" => Volcano,
               "4-8" => Sewer,
               "4-9" => Sewer,
               "4-10"=> Wreck,
               
               "5-1" => District,
               "5-2" => District,
               "5-3" => Testsite,
               "5-4" => Launcher,
               "5-5" => Yunada,
               "5-6" => Factory,
               "5-7" => Factory,
               "5-8" => Dark_Path,
               "5-9" => Sanatorium,
               "5-10"=> Unknown
              }
    Positions = {"1-0" => [100, 450],
                 "1-1" => [30, 450],
                 "1-2" => [80, 360],
                 "1-3" => [180, 340],
                 "1-4" => [200, 200],
                 "1-5" => [520, 200],
                 "1-6" => [160, 100],
                 "1-7" => [300, 410],
                 "1-8" => [320, 270],
                 "1-9" => [290, 40],
                 
                 "2-1" => [50, 200],
                 "2-2" => [40, 300],
                 "2-3" => [300, 300],
                 "2-4" => [310, 190],
                 "2-5" => [500, 180],
                 "2-6" => [70, 50],
                 "2-7" => [300, 60],
                 "2-8" => [420, 50],
                 "2-9" => [560, 40],
                 "2-10"=> [60, 420],
                 "2-11"=> [440, 380],
                 
                 "3-1" => [40, 190],
                 "3-2" => [50, 90],
                 "3-3" => [290, 110],
                 "3-4" => [280, 230],
                 "3-5" => [540, 270],
                 "3-6" => [460, 140],
                 "3-7" => [440, 30],
                 "3-8" => [310, 30],
                 "3-9" => [120, 380],
                 "3-10"=> [300, 370],
                 "3-11"=> [520, 410],
                 
                 "4-1" => [30, 260],
                 "4-2" => [240, 250],
                 "4-3" => [490, 220],
                 "4-4" => [530, 330],
                 "4-5" => [560, 450],
                 "4-6" => [320, 370],
                 "4-7" => [170, 360],
                 "4-8" => [190, 70],
                 "4-9" => [400, 60],
                 "4-10"=> [560, 80],
                 
                 "5-1" => [90, 400],
                 "5-2" => [110, 260],
                 "5-3" => [240, 270],
                 "5-4" => [490, 250],
                 "5-5" => [520, 60],
                 "5-6" => [470, 410],
                 "5-7" => [590, 380],
                 "5-8" => [230, 170],
                 "5-9" => [130, 140],
                 "5-10"=> [580, 60]
                }
    World_Pics = {"1" => "World_1",
                  "2" => "World_2",
                  "3" => "World_3",
                  "4" => "World_4",
                  "5" => "World_5"
                 }
    Number = {"1-0" => 0,
              "1-1" => 2,
              "1-2" => 4,
              "1-3" => 2,
              "1-4" => 2,
              "1-5" => 3,
              "1-6" => 1,
              "1-7" => 3,
              "1-8" => 2,
              "1-9" => 5,
              
              "2-1" => 2,
              "2-2" => 2,
              "2-3" => 2,
              "2-4" => 3,
              "2-5" => 5,
              "2-6" => 2,
              "2-7" => 3,
              "2-8" => 3,
              "2-9" => 3,
              "2-10"=> 2,
              "2-11"=> 2,
              
              "3-1" => 2,
              "3-2" => 2,
              "3-3" => 3,
              "3-4" => 2,
              "3-5" => 3,
              "3-6" => 2,
              "3-7" => 4,
              "3-8" => 2,
              "3-9" => 2,
              "3-10"=> 2,
              "3-11"=> 4,
              
              "4-1" => 2,
              "4-2" => 2,
              "4-3" => 2,
              "4-4" => 2,
              "4-5" => 6,
              "4-6" => 2,
              "4-7" => 3,
              "4-8" => 2,
              "4-9" => 2,
              "4-10"=> 3,
              
              "5-1" => 2,
              "5-2" => 2,
              "5-3" => 4,
              "5-4" => 2,
              "5-5" => 5,
              "5-6" => 2,
              "5-7" => 2,
              "5-8" => 2,
              "5-9" => 3,
              "5-10"=> 12
             }
end

module Tiles
    
    Grass = 0
    Earth = 1
    Stone = 2
    Lava = 3
    Cloud = 4
    Water = 5
    Wood = 6
    Bush = 7
    Tree = 8
    Small_Grass = 9
    Sand = 10
    Seaweed = 11
    Cave = 12
    Exterior = 13
    Interior = 14
    Shi_Water = 15
    Sea_Ruins = 16
    Ruins = 17
    Spikes = 18
    Dark_Grass = 19
    Broken_Exterior = 20
    Ruins_Back = 21
    Snow = 22
    Ice = 23
    Wall = 24
    Wall_Inside = 25
    Rice = 26
    Wheat = 27
    Fake_Earth = 28
    Window = 29
    Guard = 30
    Rock = 31
    Cactus = 32
    Sandstone = 33
    Sandstone_Inside = 34
    Keyhole = 35
    Grey_Rock = 36
    Poison = 37
    Confusion = 38
    Futuristic = 39
    Rails = 40
    Palm = 41
    
end

module Tile_Datas
    
    Tile_Void = Tile_Data.new
    
    Tile_Grass = Tile_Data.new(Tiles::Grass, true) # 0
    Tile_Earth = Tile_Data.new(Tiles::Earth, true) # 1
    Tile_Stone = Tile_Data.new(Tiles::Stone, true) # 2
    Tile_Lava = Tile_Data.new(Tiles::Lava, false, true, true, false, true, false, true) # 3
    Tile_Cloud = Tile_Data.new(Tiles::Cloud, true) # 4
    Tile_Water = Tile_Data.new(Tiles::Water, false, true, false, false, true, false, true) # 5
    Tile_Wood = Tile_Data.new(Tiles::Wood, true, false, false) # 6
    Tile_Bush = Tile_Data.new(Tiles::Bush, false, false, false) # 7
    Tile_Tree = Tile_Data.new(Tiles::Tree, true, false, false) # 8
    Tile_Small_Grass = Tile_Data.new(Tiles::Small_Grass, false, false, false) # 9
    Tile_Sand = Tile_Data.new(Tiles::Sand, true, false, false) # 10
    Tile_Seaweed = Tile_Data.new(Tiles::Seaweed, false, true, false, false, true, false, true) # 11
    Tile_Cave = Tile_Data.new(Tiles::Cave, false, false, false) # 12
    Tile_Exterior = Tile_Data.new(Tiles::Exterior, true) # 13
    Tile_Interior = Tile_Data.new(Tiles::Interior, false, false, false) # 14
    Tile_Shi_Water = Tile_Data.new(Tiles::Shi_Water, false, true, false, false, true, false, true) # 15
    Tile_Sea_Ruins = Tile_Data.new(Tiles::Sea_Ruins, true) # 16
    Tile_Ruins = Tile_Data.new(Tiles::Ruins, true) # 17
    Tile_Spikes = Tile_Data.new(Tiles::Spikes, true, false, true) # 18
    Tile_Dark_Grass = Tile_Data.new(Tiles::Dark_Grass, true) # 19
    Tile_Broken_Exterior = Tile_Data.new(Tiles::Broken_Exterior, true, false, false, false, false) # 20
    Tile_Ruins_Back = Tile_Data.new(Tiles::Ruins_Back, false, false, false) # 21
    Tile_Snow = Tile_Data.new(Tiles::Snow, true) # 22
    Tile_Ice = Tile_Data.new(Tiles::Ice, true, false, false, false, true, true) # 23
    Tile_Wall = Tile_Data.new(Tiles::Wall, true) # 24
    Tile_Wall_Inside = Tile_Data.new(Tiles::Wall_Inside, false, false, false) # 25
    Tile_Rice = Tile_Data.new(Tiles::Rice, false, true, false) # 26
    Tile_Wheat = Tile_Data.new(Tiles::Wheat, false, false, false) # 27
    Tile_Fake_Earth = Tile_Data.new(Tiles::Fake_Earth, false, false, false) # 28
    Tile_Window = Tile_Data.new(Tiles::Window, false, false, false) # 29
    Tile_Guard = Tile_Data.new(Tiles::Guard, true) # 30
    Tile_Rock = Tile_Data.new(Tiles::Rock, false, false, false) # 31
    Tile_Cactus = Tile_Data.new(Tiles::Cactus, true, false, true) # 32
    Tile_Sandstone = Tile_Data.new(Tiles::Sandstone, true) # 33
    Tile_Sandstone_Inside = Tile_Data.new(Tiles::Sandstone_Inside, false, false, false) # 34
    Tile_Keyhole = Tile_Data.new(Tiles::Keyhole, true) # 35
    Tile_Grey_Rock = Tile_Data.new(Tiles::Grey_Rock, false, false, false) # 36
    Tile_Poison = Tile_Data.new(Tiles::Poison, false, true, false, false, true, false, true) # 37
    Tile_Confusion = Tile_Data.new(Tiles::Confusion, true, false, false, false, true, false, true) # 38
    Tile_Futuristic = Tile_Data.new(Tiles::Futuristic, true) # 39
    Tile_Rails = Tile_Data.new(Tiles::Rails, true) # 40
    Tile_Palm = Tile_Data.new(Tiles::Palm, true, false, false) # 41
    
    Index = [Tile_Grass, Tile_Earth, Tile_Stone, Tile_Lava, Tile_Cloud, Tile_Water, Tile_Wood, Tile_Bush, Tile_Tree, Tile_Small_Grass, Tile_Sand, Tile_Seaweed,
             Tile_Cave, Tile_Exterior, Tile_Interior, Tile_Shi_Water, Tile_Sea_Ruins, Tile_Ruins, Tile_Spikes, Tile_Dark_Grass, Tile_Broken_Exterior, Tile_Ruins_Back,
             Tile_Snow, Tile_Ice, Tile_Wall, Tile_Wall_Inside, Tile_Rice, Tile_Wheat, Tile_Fake_Earth, Tile_Window, Tile_Guard, Tile_Rock, Tile_Cactus, Tile_Sandstone,
             Tile_Sandstone_Inside, Tile_Keyhole, Tile_Grey_Rock, Tile_Poison, Tile_Confusion, Tile_Futuristic, Tile_Rails, Tile_Palm]
    
end
