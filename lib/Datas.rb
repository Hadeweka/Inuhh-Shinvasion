FILE_VERSION = "F.0.0.1"

class TD
    attr_reader :tile, :water, :lethal, :solid, :foreground, :bulletproof, :ice, :animation
    
    def initialize(tile=nil, solid=false, water=false, lethal=false, foreground=false, bulletproof=true, ice=false, animation=false)
        @tile = tile
        @solid = solid
        @water = water
        @lethal = lethal
        @foreground = foreground
        @bulletproof = bulletproof
        @ice = ice
        @animation = animation
    end
    
    def marshal_dump
        [@tile, @solid, @water, @lethal, @foreground, @bulletproof, @ice, @animation]
    end
    
    def marshal_load(data)
        @tile,@solid,@water,@lethal,@foreground,@bulletproof,@ice,@animation = *data
    end
    
end

class OD
    attr_reader :type
    
    def initialize(type=nil)
        @type = type
    end
    
    def marshal_dump
        @type
    end
    
    def marshal_load(data)
        @type = data
    end
    
end

class ED
    attr_reader :type
    
    def initialize(type=nil)
        @type = type
    end
    
    def marshal_dump
        @type
    end
    
    def marshal_load(data)
        @type = data
    end
    
end

class SD
    attr_reader :type
    
    def initialize(type=nil)
        @type = type
    end
    
    def marshal_dump
        @type
    end
    
    def marshal_load(data)
        @type = data
    end
    
end

class TrD
    attr_reader :type
    
    def initialize(type=nil)
        @type = type
    end
    
    def marshal_dump
        @type
    end
    
    def marshal_load(data)
        @type = data
    end
    
end

class WD
    attr_reader :destination
    
    def initialize(destination=nil)
        @destination = destination
    end
    
    def marshal_dump
        array = []
        @destination.each_char do |c|
            array.push([c])
        end
        return array
    end
    
    def marshal_load(data)
        if data.is_a? String then
            @destination = data
        else
            @destination = data.join
        end
    end
    
end

class ID
    attr_reader :text
    
    def initialize(text=nil)
        @text = text
    end
    
    def marshal_dump
        @text
    end
    
    def marshal_load(data)
        @text = data
    end
    
end

class Entity
    attr_reader :xsize, :ysize, :box
    attr_accessor :x, :y
    
    def initialize
        @x = 0
        @y = 0
        @xsize = 25
        @ysize = 25
        @box = Collider::ELLIPTIC
    end
    
end

Tile_Data = TD
Object_Data = OD
Enemy_Data = ED
Spawner_Data = SD
Trigger_Data = TrD
Warp_Data = WD
Info_Data = ID
