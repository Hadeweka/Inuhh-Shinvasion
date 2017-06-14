class Shirill < Enemy
    
    def activation
        @speed = 0
        @hp = 2
        @strength = (Difficulty.get > Difficulty::HARD ? 3 : 2)
        @defense = 0
        @world = 3
        @score = 5000
        @range = 400
        @moving = false
        @spike_strength = 2
        @spike = true
        @gravity = false
        @dir_set = true
        @drilling = false
        load_graphic("Shirill")
        @speed = 2 if SHIPEDIA
        @gravity = true if SHIPEDIA
        @description = "Special form of the Moleshi.
        Drills through the earth to chase its
        unaware prey from below.
        Very rare Shi of the Westton Mountain."
    end
    
    def pre_custom_mechanics
        if (@inuhh.x - @x).abs < 50 && (0..500) === -(@inuhh.y - @y) && !@gravity then
            @drilling = true
            @speed = 2
            @vy = -20
            @moving = true
            @gravity = true
        end
        if !would_fit(0, -1) && @drilling then
            @window.add_tile(@x, @y-1-2*@ysize, nil)
            @vy = -20
        end
        @drilling = false if @drilling && @vy == 0
        @spike = @drilling
    end
    
    def draw
        @dir = [:left,:right][rand(2)] if @drilling
        super
    end
    
end
