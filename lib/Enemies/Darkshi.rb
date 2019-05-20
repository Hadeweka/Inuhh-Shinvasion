class Darkshi < Enemy
    
    def activation
        @score = 13000
        @strength = 3
        @defense = 5
        @speed = 4
        @hp = 6
        @world = 6
        @inventory = 0
        @criminal = true
        @nearest = nil
        @border_turn = false
        @abyss_turn = false
        @abyss_jump_delay = 1
        @border_jump_delay = 3
        load_graphic("Darkshi")
        @description = "T"
    end
    
    def at_collision
        @inventory += @inuhh.steal_coins((Difficulty.get > Difficulty::EASY ? 50 : 40))
        if @inventory > 0 then
            @dodge_range = 0.1
            @speed = 5
            @drop_count = @inventory
            @drop = Objects::Coin
        end
    end
    
    def move_mechanics
        if @nearest then
            if @hunt_delay >= @hunt_max_delay then
                if @dodge then
                    if @nearest.x - @x < -100*@dodge_range then
                        @dir = (@inventory > 0 || @nearest.is_a?(Polishi) ? :right : :left) if @vy == 0 || @air_control || @waterproof
                    elsif @nearest.x - @x > 100*@dodge_range
                        @dir = (@inventory > 0 || @nearest.is_a?(Polishi) ? :left : :right) if @vy == 0 || @air_control || @waterproof
                    end
                else
                    @dir = (@nearest.x < @x ? :left : :right)
                end
                @hunt_delay = 0
            end
            @hunt_delay += 1
        end
        super()
    end
    
    def custom_mechanics
        @nearest = nil if @nearest && @nearest != @inuhh && !@nearest.living
        @window.enemies.each do |e|
            next unless e.is_a?(Polishi)
            if !@nearest || (e.x-@x)**2+(e.y-@y)**2 < (@nearest.x-@x)**2+(@nearest.y-@y)**2 then
                @nearest = e
            end
        end
        if !@nearest || (@inuhh.x-@x)**2+(@inuhh.y-@y)**2 < (@nearest.x-@x)**2+(@nearest.y-@y)**2 then
            @nearest = @inuhh
        end
    end
    
end
