VANILLA = true

PASSWORD_WORLD_1 = "HEDGEHOUND"
PASSWORD_WORLD_2 = "SHIVABA"
PASSWORD_WORLD_3 = "DYUNTEH"
PASSWORD_WORLD_4 = "DEGEE"
PASSWORD_WORLD_5 = "AROMTHARAG"
PASSWORD_WORLD_6 = "KIMUHH"
PASSWORD_WORLD_7 = "DAQUELLEN"

module Difficulty
    
    EASY = 0
    NORMAL = 1
    HARD = 2
    DOOM = 3
    
    def self.set(value)
        @@difficulty = value
    end
    
    def self.get
        return @@difficulty
    end
    
end

module Exit_Timers  # In 1/60 seconds
    
    Times = {"1-0-1" => {"!1-3-1" => 100},
             "7-1-1" => {"7-1-2" => 60*60*1},
             "7-1-2" => {"7-1-3" => 60*60*3, "!7-2-1" => 60*60*2.5}}
     
end

module Minigames
    
    Test = 0
    Swimming_Course = 1
    Herbal_Quest = 2
    
    World_Levels = [nil, Swimming_Course, Herbal_Quest, Test, Test, Test, Test]
    World_Unlock_Req = [nil, 9*100, 11*100, 11*100, 10*100, 10*100, 10*100]
    World_Level_ID = [nil, nil, nil, nil, nil, nil, nil] # Will be 1-10 and 2-12
    
    Gem_Cost = {Test => 1, Swimming_Course => 10, Herbal_Quest => 0}	# Gems per game
    Gem_Factor = {Test => 1.0, Swimming_Course => 0.4, Herbal_Quest => 0.1}	# Gems per Sapphire score
    Help_Entry = {Test => 0, Swimming_Course => 62, Herbal_Quest => 63}
    
    # General rule:
    # - Costs for one play should equal G score
    
    Rating_Strings = ["J\n\n> Do you even try?",
                      "I\n\n> Maybe you should practise more.",
                      "H\n\n> Not completely terrible.",
                      "G\n\n> It can get better.",
                      "F\n\n> Not too bad.",
                      "E\n\n> It was a solid try.",
                      "D\n\n> Nice one!",
                      "C\n\n> Well done!",
                      "B\n\n> Astounding!",
                      "A\n\n> A perfect run!"]
    
    def self.rating(score, world)
        thresholds = []
        if world == 1 then
            thresholds = [0, 100000, 250000, 500000, 750000, 1000000, 2000000, 3000000, 4000000, 5000000]
        elsif world == 2 then
            thresholds = [0, 100000, 250000, 500000, 750000, 1000000, 2000000, 3000000, 4000000, 5000000]
        end
        found_index = 0
        9.downto(0) do |i|
            if score >= thresholds[i] then
                found_index = i
                break
            end
        end
        return Rating_Strings[found_index]
    end
    
end

module Stats
    
    Score = 0
    Lifes = 1
    Max_Lifes = 2
    Energy = 3
    Max_Energy = 4
    Strength = 5
    Defense = 6
    Speed = 7
    
end

module Other
    
    Mysteriorb = 0
    Compass = 1
    Statistics = 2
    
end

module Statistics
    
    Enemies_Jumped = 0
    Level_Deaths = 1
    Max_Combo = 2
    Golden_Chishi = 3
    Minigame_Ratings = 4
    # More to follow
    
end

module Trigger_ID # Use high values to add parameters to it
    
    Loxhi = 100
    Shiesaw = 200
    Collapshi = 300
    
end

module Strings
    
    One_Life = "Inuhh + 1"
    Title = "Inuhh Shinvasion"
    Title_Debug = "Inuhh Shinvasion Debug Mode - FPS: "
    Easy = "Easy :-)"
    Normal = "Normal :-|"
    Hard = "Hard :-<"
    Doom = "D00M X-("
    Easy_R = "Easy"
    Normal_R = "Normal"
    Hard_R = "Hard"
    Doom_R = "Doom"
    Name_Input = "Name: "
    Coins = " Coins"
    Congratulations = "@Congratulations!"
    Game_Over = "@    Game Over!"
    Minigame_Over = "Minigame over!"
    Minigame_Score = "Score: "
    Minigame_Rating = "Rating: "
    Start_Game = "Start game"
    Achievements = "Achievements"
    Shi_Coins = " Shi Coins"
    Enter_Name = "Please enter your name."
    Welcome = "Welcome to Inuhh 4, "
    Select_Difficulty = "Please select your difficulty."
    Choice = "Your choice: "
    Gem_Select = " Gems => "
    Gem_Life = " Life:"
    Gem_Lifes = " Lifes:"
    Gem_Press = "Press "
    Paused = "PAUSED"
    Main_Coins = "Coins: "
    Hedge_Shop = "---SHOP---"
    Hedge_Energy = "1   -   Max Energy+1"
    Hedge_Lifes = "2   -   Min Lifes+1"
    Hedge_Strength = "3   -   Strength+1"
    Hedge_Defense = "4	-	Defense+1"
    Hedge_Shi_Coins = " Shi Coins)"
    Hedge_Own_Shi_Coins = "Shi Coins: "
    Hedge_Mysteriorbs = "(5 Mysteriorbs)"
    Hedge_Unknown_Mysteriorbs = "(? Mysteriorbs)"
    Hedge_Compass = "(4 Compass p.)"
    Hedge_Unknown_Compass = "(? Compass p.)"
    Continue = "Press Enter to continue."
    Info = "---INFO---"
    Loading = "Loading..."
    
    A_Difficulty = "Difficulty:"
    A_Archetype = "Archetype:"
    A_Game_Beaten = "Game beaten:"
    A_Game_Progress = "Game progress:"
    A_Score = "Score:"
    A_Shi_Coins = "Shi Coins:"
    A_Compass_Pieces = "Compass pieces:"
    A_Mysteriorbs = "Mysteriorbs:"
    A_Smashed_Shi = "Shi smashed:"
    A_Perfect_Levels = "Perfect levels:"
    A_Highest_Combo = "Highest combo:"
    A_Golden_Chishi = "Golden Chishi:"
    A_Perfect_Minigames = "Perfect minigames:"
    
    H_Score = "Score: "
    H_Lifes = "Lifes: "
    H_Coins = "Coins: "
    H_Gems = "Gems: "
    H_Shi_Coins = "Shi Coins: "
    H_Highscore = "Highscore: "
    H_Rating = "Rating: "
    
    M_Gems_Needed = "Costs: "
    M_Gems_Needed_2 = " Gems"
    M_Gems_Okay = "Press 'Return' to play"
    M_Gems_Not_Okay = "Too few gems to play."
    
    Yes = "Yes"
    No = "No"
    Unknown = "???"
    
end

module Milestones
    
    Game_Done = 0
    Game_100_Percent = 1
    All_Shi_Coins = 2
    All_Compass_Pieces = 3
    All_Mysteriorbs = 4
    Highscore = 5
    Shi_Massacre = 6
    Invincible = 7
    Combo_Breaker = 8
    Gold_Eye = 9
    Minigame_Nerd = 10
    
end

module Archetypes
    
    Balance = ["Balance", 0xffffffff]
    
    Bulky = ["Bulky", 0xff00ff00]
    Pseudo_Cat = ["Pseudo Cat", 0xffffff00]
    Berserk = ["Berserk", 0xffff0000]
    Armored = ["Armored", 0xff0000ff]
    
    Relentless = ["Relentless", 0xff88ff00]
    Tank = ["Tank", 0xff888800]
    Fortress = ["Fortress", 0xff008888]
    
    Glass_Cannon = ["Glass Cannon", 0xffff8800]
    Cautious = ["Cautious", 0xff888888]
    
    Stronghold = ["Stronghold", 0xff880088]
    
end

module Pics
    
    Folder_Game = "media/game/"
    Folder_Forms = "media/forms/"
    Folder_Projectiles = "media/projectiles/"
    Folder_Worldmap = "media/worldmap/"
    Folder_Events = "media/events/"
    Folder_HUD = "media/hud/"
    Folder_Boxes = "media/boxes/"
    Folder_Editor = "media/editor/"
    Folder_Pics = "media/pics/"
    Folder_Achievements = "media/achievements/"
    Folder_Bars = "media/bars/"
    Folder_Special = "media/special/"
    Folder_BG = "media/bg/"
    Folder_Levels = "media/levels/"
    
    Inuhh = Folder_Game + "Inuhh.png"
    
    World_Inuhh = Folder_Worldmap + "Start.png"
    Tileset = Folder_Game + "Tileset.png"
    Anim_Tileset = Folder_Game + "Anim_Tileset.png"
    Objects = Folder_Game + "Objects.png"
    Warp = Folder_Events + "Warp.png"
    Final = Folder_Events + "FinalWarp.png"
    Secret = Folder_Events + "SecretWarp.png"
    Signpost = Folder_Events + "SignPost.png"
    Life = Folder_HUD + "Life.png"
    Minigame_Life = Folder_HUD + "Minigame_Life.png"
    Energy = Folder_HUD + "Energy.png"
    Strength = Folder_HUD + "Strength.png"
    Defense = Folder_HUD + "Defense.png"
    Textbox = Folder_Boxes + "Textbox.png"
    Signbox = Folder_Boxes + "Signbox.png"
    Shopbox = Folder_Boxes + "Shopbox.png"
    Editor_Enemies = Folder_Editor + "Icons.png"
    Title = Folder_Pics + "Title.png"
    Name_Input = Folder_Pics + "Name_Input.png"
    Achievements = Folder_Pics + "Achievements.png"
    Milestones = Folder_Achievements + "Milestones.png"
    Difficulty_Easy = Folder_Pics + "Easy.png"
    Difficulty_Normal = Folder_Pics + "Normal.png"
    Difficulty_Hard = Folder_Pics + "Hard.png"
    Difficulty_Doom = Folder_Pics + "Doom.png"
    Credits = Folder_Pics + "Credits.png"
    Notyet = Folder_Achievements + "Notyet.png"
    Strength_Bar = Folder_Bars + "Strength_Bar.png"
    Speed_Bar = Folder_Bars + "Speed_Bar.png"
    Boss_Bar = Folder_Bars + "Boss_Bar.png"
    World_Icons = Folder_Worldmap + "World_Icons.png"
    Level_Index = Folder_Worldmap + "Level_Index.png"
    Level_Index_Cleared = Folder_Worldmap + "Level_Index_Cleared.png"
    Level_Index_Minigame = Folder_Worldmap + "Level_Index_Minigame.png"
    Arrows = Folder_Worldmap + "Arrows.png"
    Drunken = Folder_Special + "Drunken.png"
    Perfect = Folder_Worldmap + "Perfect.png"
    Spawner = Folder_Events + "Spawner.png"
    
    Append_Projectiles = "_Projectile.png"
    
end

module Media
    
    Folder_Sounds = "media/sounds/"
    Folder_Songs = "media/songs/"
    Folder_Players = "players/"
    
    Messages = "media/Messages.txt"
    
end

module Final
    
    Early_Time = "@time o' Clock?!? Are you kidding me?
    Go to sleep already!"
    
    Normal_Time = "Don't waste your time here!"
    
    You_Did = "Oh, you did already. Dang."
    
    Text = "
    @minimal_delay
    
    It is done: Inuhh defeated the powerful
    
    Admiral Aromtharag. Now the peace can return
    
    to Oynabaku again, at least for some time.
    
    The remaining Shi surrendered and retreated
    
    to the Yunada. They left the earth in fear of
    
    their empire, but also of Inuhh.
    
    Inuhh himself stole a Turboshi to get back
    
    to earth.
    
    
    
    Still some questions remain...
    
    
    
    
    
    ---Credits---
    
    
    
    #Programming:
    HDWK
    
    
    
    #Graphics:
    HDWK and Silke (thank you!)
    
    
    
    #Music:
    IF THIS GAME HAD SOME!
    
    
    
    #Level design:
    HDWK
    
    
    
    #Overworld:
    HDWK
    
    
    
    #Sound effects:
    HDWK
    
    
    
    #Shi design:
    HDWK
    
    
    
    #Arrogance:
    HDWK
    
    
    
    #Pointless showmanship:
    HDWK
    
    
    
    #Stupid credits nobody reads:
    HDWK
    
    
    
    #HDWK:
    His parents
    
    
    
    #Testing:
    You
    
    
    
    #Special thanks:
    You, because you're testing this stuff.
    
    Silke (again) for the dog sprites.
    
    
    @minimal_delay
    
    @minimal_delay
    
    #Secret info:
    You can skip this stuff with Escape.
    Also you can scroll up and down
    by using your mouse wheel.
    
    @very_long_delay
    
    #Really secret info:
    Have you discovered all secrets yet?
    Try to do it, in the next version of
    this game you won't regret it!
    
    @rather_short_delay
    
    Now quit this stuff!
    I've said everything!
    
    @rather_short_delay
    
    Really!!!
    
    @even_longer_delay
    
    I see. You are one of THOSE people...
    Maybe I could put some satanic messages
    here... backwards, of course.
    
    @rather_short_delay
    
    Seriously, here is NOTHING!
    You're just wasting your time here.
    Play the game to 100% if you didn't
    do that already.
    @100_p_comment
    
    @rather_short_delay
    
    Go out and hug trees.
    I'll include a weather query in the
    next version, I swear! Just to
    find a cause to kick you outta here!
    
    @rather_short_delay
    
    Look. It's @time o' Clock.
    @t_comment
    
    @even_longer_delay
    
    ???: 'Just give up.'
    
    @even_longer_delay
    
    ???: 'There is nothing you can do 
      right now.'
      
    @even_longer_delay
    
    ???: 'It didn't go well then, 
      why should it now?'
      
    @even_longer_delay
    
    ???: 'You saw those ruins.'
    
    @even_longer_delay
    
    ???: 'You don't know what you're 
      messing with.'
      
    @even_longer_delay
    
    ???: 'You don't know WHOM you're 
      messing with.'
    
    @even_longer_delay
    
    ???: 'You need to know where 
      to stop.'

    @even_longer_delay
    
    ???: 'You won't succeed.
      Stop right now and accept it!'
       
    "
end

module Debug
    
    ON = false	# Please don't activate this
    
    def self.output(text)
        puts "[DEBUG] "+text.to_s if ON
    end
    
end
