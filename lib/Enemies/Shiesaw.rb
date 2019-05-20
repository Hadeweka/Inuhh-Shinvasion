class Shiesaw < Enemy
    
    attr_reader :chain
    
    def activation
        @score = 9000
        @range = 100000
        @strength = 4
        @hp = 1
        @speed = 0
        @world = 6
        @defense = 2
        @riding = true
        @gravity = false
        @param = 0 if !@param
        @prepared = (@param % 2 == 0 ? 1 : -1)
        @chain = (@param/2).to_i
        @moving = false
        @y_0 = @y
        @jump_image = false
        if !EDITOR && !SHIPEDIA && !@window.triggers[Trigger_ID::Shiesaw + @chain] then
            @window.triggers[Trigger_ID::Shiesaw + @chain] = 0
        end
        load_graphic((@prepared > 0 ? "Shiesaw_Down" : "Shiesaw_Up"))
        @description = "Special Shi which behaves similar to the
        Shilevator but doesn't leave its position
        to rescue someone. Can go up and down and
        also be coupled with anothter Shiesaw.
        Found on Horror Island."
    end
    
    def pre_custom_mechanics
        if self == @inuhh.riding_entity then
            @vy = @prepared*3
            if would_fit(0, @prepared) then
                @window.triggers[Trigger_ID::Shiesaw + @chain] = @prepared*3
            else
                @window.triggers[Trigger_ID::Shiesaw + @chain] = @prepared
            end
        else
            @vy = 0
            if @window.triggers[Trigger_ID::Shiesaw + @chain] != 0 then
                @vy = -@window.triggers[Trigger_ID::Shiesaw + @chain]
            end
            if @y != @y_0 then
                #@vy += ((@y_0-@y)/(@y_0-@y).abs).to_i		# Nice idea for another enemy
            end
        end
        @window.triggers[Trigger_ID::Shiesaw + @chain] = 0 if !(@inuhh.riding_entity.is_a?(Shiesaw)) || @inuhh.riding_entity.chain != @chain
    end
    
end
