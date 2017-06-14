class Unloxhi < Enemy
    
    def activation
        @speed = 1
        @strength = 5
        @world = 5
        @score = 0
        @defense = 1000
        @lock_colors = []
        @lock_colors[0] = 0x00ffffff
        @lock_colors[1] = 0x00ff0000
        @lock_colors[2] = 0x0000ff00
        @lock_colors[3] = 0x000000ff
        @lock_state = (@param ? @param : 0)
        if !EDITOR && !SHIPEDIA && !@window.triggers[Trigger_ID::Loxhi] then
            @window.triggers[Trigger_ID::Loxhi] = 0
        end
        load_graphic("Unloxhi")
        @description = "Similar to the Loxhi, but moving.
        Can be found at all places with Loxhis."
    end
    
    def damage(value)
        super(value)
        @window.triggers[Trigger_ID::Loxhi] = @lock_state
    end
    
    def draw
        if SHIPEDIA then
            
        elsif EDITOR then
            
            @shading = @lock_colors[@lock_state] + 0xff000000
        else
            @shading = @lock_colors[@lock_state] + ((@window.triggers[Trigger_ID::Loxhi] != @lock_state) ? 0xff000000 : 0x44000000)
        end
        super()
    end
    
    def custom_mechanics
        @dangerous = (@window.triggers[Trigger_ID::Loxhi] != @lock_state)
    end
    
end
