class Shirge < Enemy
    
    attr_reader :c_red, :c_green, :c_blue, :fusion
    
    def activation
        @score = 17000
        @speed = 3
        @defense = 4
        @hp = 5
        @world = 6
        @strength = 6
        @charge = @param	# 0 = NONE, 1 = RED, 2 = GREEN, 3 = BLUE, 4 = R+G, 5 = G+B, 6 = B+R, 7 = R+G+B
        @c_red = [1, 4, 6, 7].index(@param) ? true : false
        @c_green = [2, 4, 5, 7].index(@param) ? true : false
        @c_blue = [3, 5, 6, 7].index(@param) ? true : false
        @shading = 0xff000000 + (@c_red ? 0x00ff0000 : 0x00000000) + (@c_green ? 0x0000ff00 : 0x00000000) + (@c_blue ? 0x000000ff : 0x00000000)
        @spike = true
        @spike_strength = 6
        @bulletproof = true
        @projectile_damage = 3
        @projectile_owner = Projectiles::RAMPAGE
        @projectile_type = Projectiles::Spark
        @projectile_lifetime = 50
        @detonation_intensity = 30
        @gravity = false
        @hunting = true
        @waterproof = true
        @border_turn = false
        @fusion = true
        @repell_counter = 0
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        load_graphic("Shirge")
        @description = "T"
    end
    
    def deactivate_fusion
        @fusion = false
    end
    
    def repell(other)
        return if @repell_counter > 0
        @hunting = false
        @speed = 6
        @repell_counter = 100
        if other.x == @x then
            @dir = (@window.enemies.index(self) < @window.enemies.index(other) ? :right : :left)
        else
            @dir = (@x < other.x ? :left : :right)
        end
        if other.y == @y then
            @vy = 0
        else
            @vy = (@y < other.y ? -@speed : @speed)
        end
    end
    
    def custom_mechanics
        if @repell_counter > 0 then
            @repell_counter -= 1
            if @repell_counter == 0 then
                @hunting = true
                @speed = 3
            end
        end
        return if !@fusion
        @window.enemies.each do |e|
            next if e == self || !e.is_a?(Shirge) || !e.fusion
            if Collider.elliptic(@xsize, @ysize, e.xsize, e.ysize, @x-e.x, @y-e.y) then
                if @c_red && e.c_red || @c_green && e.c_green || @c_blue && e.c_blue then
                    repell(e)
                    e.repell(self)
                else
                    colors = [@c_red || e.c_red, @c_green || e.c_green, @c_blue || e.c_blue]
                    new_color = case colors
                        when [false, false, false] then 0
                        when [true, false, false] then 1
                        when [false, true, false] then 2
                        when [false, false, true] then 3
                        when [true, true, false] then 4
                        when [false, true, true] then 5
                        when [true, false, true] then 6
                        when [true, true, true] then 7
                    end
                    @window.spawn_enemy(Enemies::Shirge, ((@x + e.x)/2).to_i, ((@y + e.y)/2).to_i, @dir, new_color)
                    e.detonate
                    e.deactivate_fusion
                    detonate
                    deactivate_fusion
                    break
                end
            end
        end
    end

    def move_mechanics
        super
        if @hunting then
            @vy = @speed if @inuhh.y > @y
            @vy = 0 if @inuhh.y == @y
            @vy = -@speed if @inuhh.y < @y
            @vy += rand(7) - 3
            @vx = rand(7) - 3
        end
    end

end
