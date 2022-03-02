class Shitomium < Enemy
    
    def activation
        @hp = (Difficulty.get == Difficulty::EASY ? 6 : (Difficulty.get < Difficulty::DOOM ? 8 : 10))
        @maxhp = @hp
        @boss = true
        @score = 45000
        @xsize = 100
        @ysize = 100
        @world = 3
        @shield_image = Image.new("media/special/Shield100100.png", tileable: true)
        @mindamage = (Difficulty.get >= Difficulty::NORMAL ? (Difficulty.get == Difficulty::DOOM ? 5 : 3) : 1)
        @reduction = 1
        @strength = (Difficulty.get >= Difficulty::NORMAL ? (Difficulty.get == Difficulty::DOOM ? 10 : 5) : 3)
        @speed = 1
        @shilectrons = []
        @respawn_delay = 200
        @max_shilectrons = 0
        @drop = Objects::Key if SHIPEDIA
        @gravity = false
        @hunting = true
        @border_turn = false
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        @range = 100000
        load_graphic("Shitomium")
        @description = "Impressive and very strong Shi with many dangerous
        traits. Hovers in air, hunts its enemies and summons
        Shilectrons to guard it if in danger, which are
        pushed to higher energy levels if attacked.
        Resides in the Temple of Dyunteh."
    end
    
    def try_to_jump
        
    end
    
    def move_mechanics
        super
        @vy = @speed if @inuhh.y > @y
        @vy = -@speed if @inuhh.y < @y
        @vy = 10*@speed if @inuhh.y - @y > 200
        @vy = 20*@speed if @inuhh.y - @y > 1000
    end
    
    def custom_mechanics
        @respawn_delay -= 1 if @shilectrons.size == 0
        if @respawn_delay <= 0 && @shilectrons.size == 0 then
            mshi = @max_shilectrons
            if mshi > 2 then
                0.upto(2-1) do |i|
                    @shilectrons.push(@window.spawn_enemy(Enemies::Shilectron, @x, @y-@ysize+25, :left))
                    @shilectrons[-1].bind(self, 150.0, 2.0*Math::PI/2.0*i.to_f, 100*2.0*Math::PI, 3, 3)
                    @shilectrons[-1].set_no_harm_time(50)
                end
                mshi -= 2
                if mshi > 8 then
                    0.upto(8-1) do |i|
                        @shilectrons.push(@window.spawn_enemy(Enemies::Shilectron, @x, @y-@ysize+25, :left))
                        @shilectrons[-1].bind(self, 200.0, 2.0*Math::PI/8.0*i.to_f, 200*2.0*Math::PI, 2, 2)
                        @shilectrons[-1].set_no_harm_time(50)
                    end
                    mshi -= 8
                    0.upto(mshi-1) do |i|
                        @shilectrons.push(@window.spawn_enemy(Enemies::Shilectron, @x, @y-@ysize+25, :left))
                        @shilectrons[-1].bind(self, 250.0, 2.0*Math::PI/mshi.to_f*i.to_f, 300*2.0*Math::PI, 1, 1)
                        @shilectrons[-1].set_no_harm_time(50)
                    end
                else
                    0.upto(mshi-1) do |i|
                        @shilectrons.push(@window.spawn_enemy(Enemies::Shilectron, @x, @y-@ysize+25, :left))
                        @shilectrons[-1].bind(self, 200.0, 2.0*Math::PI/mshi.to_f*i.to_f, 200*2.0*Math::PI, 2, 2)
                        @shilectrons[-1].set_no_harm_time(50)
                    end
                end
            else
                0.upto(mshi-1) do |i|
                    @shilectrons.push(@window.spawn_enemy(Enemies::Shilectron, @x, @y-@ysize+25, :left))
                    @shilectrons[-1].bind(self, 150.0, 2.0*Math::PI/mshi.to_f*i.to_f, 100*2.0*Math::PI, 3, 3)
                    @shilectrons[-1].set_no_harm_time(50)
                end
            end
            @respawn_delay = 200
        end
        @shilectrons.reject! do |s|
            s.turn_to(@dir) if Difficulty.get >= Difficulty::HARD
            s.hp <= 0
        end
        @defense = (@shilectrons.size == 0 ? 0 : 1000)
    end
    
    def damage(value)
        super(value)
        @respawn_delay = 0 if @shilectrons.size == 0 || value > @defense
        @max_shilectrons = [0, 1, 2, 3, 4, 6, 8, 10, 14, 18][[@maxhp-@hp,9].min]
    end
    
    def at_death
        super
        @shilectrons.reject! do |e|
            e.damage(1000)
            true
        end
        drop = Object_Datas::C_Index[Objects::Key].new(@window.valimgs[Objects::Key], @inuhh.x, @inuhh.y)
        drop.collect(@window, @inuhh)
    end
    
    def draw
        super()
        @shield_image.draw(@x-@xsize-100, @y-2*@ysize-100, ZOrder::Enemies) if @defense > 0
    end
    
end
