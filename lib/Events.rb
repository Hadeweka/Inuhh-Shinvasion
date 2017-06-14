class Warp
    attr_reader :x, :y, :destination
    
    def initialize(image, x, y, dest)
        @image = image
        @x, @y = x, y
        @destination = dest
    end
    
    def draw
        @image.draw(@x - 50.0*Math::sin(milliseconds / 1000.0)**2, @y - 25 - 50.0*Math::sin(milliseconds / 1000.0)**2, ZOrder::Warps, 2.0*Math::sin(milliseconds / 1000.0)**2, 2.0*Math::sin(milliseconds / 1000.0)**2)
    end
    
    def update
        
    end
    
end

class Trigger_Collision
    attr_reader :x, :y
    
    def initialize(window, image, x, y, trigger)
        @window = window
        @image = image
        @x, @y = x, y
        @trigger = trigger
    end
    
    def draw
        @image.draw(@x, @y, ZOrder::Warps)
    end
    
    def update
        if (@x..@x+50) === @window.inuhh.x && (@y..@y+50) === @window.inuhh.y then
            @window.triggers[@trigger] = true
        else
            @window.triggers[@trigger] = false
        end
    end
    
end

class Spawner
    attr_reader :x, :y, :enemy, :cooldown, :range, :content, :trigger
    attr_accessor :dir
    MAXIMUM_ENEMIES = 5000
    
    def initialize(window, image, x, y, dir, enemy, cooldown, range, content=-1, trigger=nil)
        @window = window
        @image = image
        @x, @y = x, y
        @dir = dir
        @enemy = enemy
        @spawning = false
        @content = content
        @cooldown = cooldown
        @cooler = 0
        @range = range
        @trigger = trigger
    end
    
    def draw
        @image.draw(@x, @y, ZOrder::Warps)
    end
    
    def update(cam_x, cam_y)
        @cooler -= 1
        return nil unless check_range(cam_x, cam_y)
        if (!@trigger || @window.triggers[@trigger]) && @cooler <= 0 then
            return nil if @window.enemies.size >= MAXIMUM_ENEMIES
            offset = (@dir == :left ? -25 : 25)
            @window.spawn_enemy(@enemy, @x+offset, @y+49, @dir) if @content != 0 # Use wrapper methods here
            @content -= 1 if @content != 0
            @cooler = @cooldown
        end
    end
    
    def check_range(cam_x, cam_y)
        return (cam_x-50-@range .. cam_x+16*50+@range)===@x && (cam_y-50-@range .. cam_y+11*50+@range)===@y
    end
    
end

class Signpost
    attr_reader :x, :y, :message
    
    def initialize(window, image, x, y, message)
        @window = window
        @image = image
        @x, @y = x, y
        @message = message
    end
    
    def draw
        @image.draw(@x, @y, ZOrder::Warps)
    end
    
    def check_range(inuhh_x, inuhh_y)
        return (@x-25 .. @x+75) === inuhh_x && @y+49 == inuhh_y
    end
    
end

module Projectiles
    
    # Order is VERY important!
    Standard = 0
    Doom = 1
    Fire = 2
    Water = 3
    Laser = 4
    Homing = 5
    Ball = 6
    Spark = 7
    Doom_Ball = 8
    
    Last_ID = Doom_Ball
    
    INUHH = 0
    ENEMY = 1
    RAMPAGE = 2 # Damages everyone
    
    XSizes = [5, 25, 10, 5, 5, 5, 10, 5, 5]
    YSizes = [5, 25, 10, 5, 5, 5, 10, 5, 5]
    Destruction = [false, true, false, false, false, false, false, false, false]
    Inuhh_Plus = [0, 0, 0, -1, 0, 0, 0, 0, 0] # Damage Inuhh gets additionally
    Shi_Plus = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    Sounds = ["shot", "fire", "fire", "water", "laser", "shot", "fire", "laser", "shot"] # Some can be updated sometimes, like the ball one
    Drops = [nil, nil, nil, nil, nil, nil, Objects::Ball, nil, nil]
    Pics = ["Standard", "Doom", "Fire", "Water", "Laser", "Homing", "Ball", "Spark", "Doom_Ball"]
    
end
