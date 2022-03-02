class Enemy < Entity
    attr_reader :strength, :score, :spike, :mud, :living, :drop, :boss, :hp, :spike_strength, :maxhp, :z, :defense, :standing, :walk1, :walk2, :jump, :speed,
            :waterproof, :hunting, :description, :gravity, :projectile, :invisible, :knockback, :through, :world, :reduction, :mindamage, :minsdamage, :riding,
            :destiny, :drop_count, :dir, :jumping, :vy, :param, :bulletproof, :dangerous, :invul, :drop_shift, :havoc, :criminal, :transparent
    attr_accessor :dir, :crash_detonation
    
    def initialize(window, x, y, dir, param=nil)
        super()
        @param = param
        @living = true
        @boss = false
        @damage_counter = 0
        @enemy_plus_damage = 0
        @spike_strength = 0
        @invisible = false
        @dangerous = true
        @no_knockback = false
        @play_charge_sound = false
        @havoc = false
        @world = 0
        @transparent = false
        @x, @y = x, y
        @z = 0
        @vz = 0
        @vx = 0
        @dir = dir
        @strength = 1
        @defense = 0
        @hp = 1
        @maxhp = @hp
        @tics = 0
        @score = 0
        @speed = 2
        @xsize = 25
        @ysize = 25
        @knockback = 0
        @destiny = false
        @fleeing = false
        @through = false
        @invul = 0
        @fuse_counter = false
        @fuse_time = 255
        @detonation_intensity = 20
        @detonation_speed = 10.0
        @gravity_detonation = 0.1
        @detonation_acc = 0.0
        @dir_set = false
        @projectile = false
        @projectile_reload = 0
        @projectile_delay = 0
        @projectile_damage = 1
        @projectile_offset = [0.0, 0.0]
        @projectile_mechanics = [0.0, 0.0, 0.0, 0.0]
        @projectile_lifetime = nil
        @projectile_owner = Projectiles::ENEMY
        @projectile_type = Projectiles::Standard
        @dodge_range = 1
        @dodge = true
        @criminal = false # Polishi will hunt all criminals
        @anim_delay = 175
        @knockback_vx = 0
        @crash_detonation = false
        @riding = false
        @reduction = false # Minimum damage possible to enemy
        @mindamage = false # Minimum damage inflicted by enemy
        @mindamage = 1 if Difficulty.get > Difficulty::HARD
        @minsdamage = false
        @minsdamage = 1 if Difficulty.get > Difficulty::HARD
        # Random shoot ?
        @spike = false
        @detonated = false
        @moving = true
        @gravity = true
        @air_control = false
        @waterproof = false
        @bulletproof = false
        @random_jump_delay = nil
        @abyss_jump_delay = nil
        @border_jump_delay = nil
        @jump_speed = -15
        @abyss_turn = true
        @border_turn = true
        @shading = 0xffffffff
        @hunting = false
        @hunt_max_delay = 0
        @hunt_delay = 0
        @drop = nil
        @drop_count = 1
        @drop_shift = 0
        @sound_on = true
        @jump_image = true
        @window = window
        @jumping = false
        @synced_timer = 0
        @synced_animation_delay = false
        @description = ""
        @vy = 0 # Vertical velocity
        @range = 200 # Range of interaction outside of camera
        @map = @window.map
        @inuhh = @window.inuhh if !SHIPEDIA && !EDITOR
        general_activation
        activation
    end
    
    def kick_high(value)
        @vy = -value if !@no_knockback && @gravity
    end
    
    def general_activation
        
    end
    
    def activation
        
    end
    
    def extend_range
        @range *= 100
    end
    
    def stop_random_jumping
        @random_jump_delay = nil
    end
    
    def chase_inuhh
        @hunting = true
        @border_turn = false
        @abyss_turn = false
    end
    
    def load_graphic(name, graphicxsize=@xsize, graphicysize=@ysize)
        @standing, @walk1, @walk2, @jump, @mud = *Image.load_tiles("media/enemies/#{name}.png", 2*graphicxsize, 2*graphicysize, tileable: true)
        @cur_image = @walk1
        @loaded_graphic = name
    end
    
    def load_mod_graphic(mod_folder, name)
        @standing, @walk1, @walk2, @jump, @mud = *Image.load_tiles("mods/#{mod_folder}/media/enemies/#{name}.png", 2*@xsize, 2*@ysize, tileable: true)
        @cur_image = @walk1
    end
    
    def damage(value)
        @hp -= value
        @invul = 20
        @cur_image = @jump
        @damage_counter = 20
        if @hp <= 0 then
            @hp = 0
            @living = false
        elsif (@inuhh.x - @x) < 320 && (@inuhh.y - @y) < 240 then
            if value > 0 then
                @window.play_sound("shi cry #{rand(5)+1}", 1.0 + (value - 1)*0.05, 1.0 - (@xsize >= 50 && @ysize >= 50 ? 0.25 : 0.0))
            elsif @sound_on
                @window.play_sound("guard")
            end
        end
        @sound_on = true
    end
    
    def draw
        return if @invisible && !EDITOR
        # Flip vertically when facing to the left.
        if @dir == :left then
            offs_x = -@xsize
            factor = 1.0
        else
            offs_x = @xsize
            factor = -1.0
        end
        if EDITOR then
            @cur_image = @standing if !@moving && !@dir_set
            @cur_image.draw(@x + offs_x, @y - @ysize*2 + 1, ZOrder::Enemies, factor, 1.0, @shading)
        else
            distance = 200.0
            factor = 1.0 if !@moving && !@dir_set
            zxsize = @xsize*1.0/(1.0 + @z/distance)
            zysize = @ysize*1.0/(1.0 + @z/distance)
            zord = (@z < 0 ? ZOrder::Foreground : ZOrder::Enemies)
            @cur_image.draw(@x - factor*zxsize, @y - zysize*2 + 1 + zysize-@ysize, zord, factor*zxsize/@xsize, zysize/@ysize, @shading)
        end
    end
    
    # Could the object be placed at x + offs_x/y + offs_y without being stuck?
    def would_fit(offs_x, offs_y)
        return true if @through
        # Check at the center/top and center/bottom for map collisions
        expr = true
        0.upto((@ysize/25).floor) do |t|
            ((-@xsize/50)+1).floor.upto((@xsize/50).floor) do |u|
                edge_y = t == 0 ? 0 : 1
                edge_x = 0
                edge_x = -25 if (@xsize / 25).to_i % 2 == 1 && @xsize > 25	# Works for xsizes 25, 75 and n*50, others MAYBE won't work
                expr &&= !@map.solid?(@x + offs_x + 25 - (@xsize>25 ? 25 : 0) + u*50 - edge_x, @y + offs_y - 50*(t) + edge_y)
                expr &&= !@map.solid?(@x + offs_x - 24 - (@xsize>25 ? 25 : 0) + u*50 - edge_x, @y + offs_y - 50*(t) + edge_y)
            end
        end
        detonate if @crash_detonation && !expr
        return expr
    end
    
    def set_drop(drop, drop_count, drop_shift = 0)
        @drop = drop
        @drop_count = drop_count
        @drop_shift = drop_shift
    end
    
    def set_infinite_range
        @range = 100000
    end
    
    def force_minimal_damage(value = @strength)
        @mindamage = value
    end
    
    def change_strength(value)
        @strength = value
        @spike_strength = value
    end
    
    def force_reduction(value = 1)
        @reduction = value
    end
    
    def set_custom_score(value)
        @score = value
    end
    
    def force_knockback(s, d=0)
        if !@no_knockback then
            @knockback_vx = s
        else
            @window.play_sound("guard")
        end
    end
    
    def check_range(cam_x, cam_y)
        return (cam_x-50-@range .. cam_x+16*50+@range)===@x && (cam_y-50-@range .. cam_y+11*50+@range)===@y
    end
    
    def update(cam_x, cam_y)
        @synced_timer += @synced_animation_delay if @synced_animation_delay
        @tics += 1
        @invul -= 1 if @invul > 0
        @inuhh = @window.inuhh
        return nil unless check_range(cam_x, cam_y)
        pre_custom_mechanics
        jump_mechanics
        water_mechanics
        move_mechanics
        knockback_mechanics
        gravity_mechanics
        z_mechanics
        projectile_mechanics
        fuse_mechanics
        custom_mechanics
        @damage_counter -= 1
    end
    
    def pre_custom_mechanics
        
    end
    
    def custom_mechanics
        
    end
    
    def projectile_mechanics
        return if !@projectile
        @window.play_sound("charge", 0.5, 1.0) if @projectile_delay == (@projectile_reload - @play_charge_sound) if @play_charge_sound
        @projectile_delay += 1
        dirfac = (@dir == :left ? -1.0 : 1.0)
        if @projectile_delay >= @projectile_reload then
            @projectile_delay = 0
            shoot_projectile
        end
    end
    
    def shoot_projectile
        dirfac = (@dir == :left ? -1.0 : 1.0)
        @window.spawn_projectile(@projectile_type, @x.to_f+(Projectiles::XSizes[@projectile_type]+@xsize)*dirfac+@projectile_offset[0]*dirfac,
                                 @y.to_f-@ysize.to_f-Projectiles::YSizes[@projectile_type]+@projectile_offset[1],
                                 @projectile_mechanics[0]*dirfac+@speed*dirfac.to_f, @projectile_mechanics[1],
                                 *@projectile_mechanics[2..3], @projectile_owner, @projectile_lifetime, @projectile_damage)
    end
    
    def gravity_mechanics
        @vy += 1 if @gravity
        @vy = [@vy, 3].min if @map.water(@x, @y)
        # Vertical movement
        if @vy > 0 then
            @vy.to_i.times { if would_fit(0, 1) then @y += 1 else @vy = 0 end }
        end
        if @vy < 0 then
            (-@vy).to_i.times { if would_fit(0, -1) then @y -= 1 else @vy = 0 end }
        end
    end
    
    def z_mechanics
        if @vz > 0 then
            @vz.floor.times { @z += 1 }
        end
        if @vz < 0 then
            (-@vz).floor.times { @z -= 1 }
        end
        @z = [100, @z].min
        @living = false if @z < -100
    end
    
    def water_mechanics
        if @map.water(@x, @y, true) then
            damage(1) if !@waterproof
        end
    end
    
    def random_jump(delay)
        ret = false
        if delay && rand(delay) == 0 then
            try_to_jump
            ret = true
        end
        return ret
    end
    
    def jump_mechanics
        @jumping = false if !would_fit(0, 1)
        random_jump(@random_jump_delay)
    end
    
    def sub_move_mechanics
        abyss_mechanics
        border_mechanics if !@through
    end
    
    def knockback_mechanics
        if @knockback_vx != 0 && @havoc then
            @window.enemies.each do |e|
                next if e == self
                if Collider.test_collision(self, e) then
                    if e.invul == 0 then
                        dv = [@strength + @enemy_plus_damage - e.defense, 0].max
                        e.damage(dv)
                        fuse(1) if @crash_detonation
                        @knockback_vx -= (@knockback_vx/@knockback_vx.abs).to_i if @knockback_vx != 0
                        @window.messages.push([dv, e.x-e.xsize+10, e.y-e.ysize-30, 20, true, 2.0+(dv-1)/30.0, 2.0+(dv-1)/30.0, 0xff00ff00])
                        if !e.living then
                            value = e.score
                            @window.messages.push([value, e.x-e.xsize, e.y-e.ysize, 100, true, 2.0+(value/50000.0), 2.0+(value/50000.0), 0xffffff00])
                            @window.inuhh.increase_stat(Stats::Score, value)
                            @window.play_sound("smash")
                            @window.residues.push(Residuum.new(e.x-e.xsize, e.y-2*e.ysize, (e.boss ? 200 : 50), @window, e.mud))
                        end
                    end
                end
            end
        end
        @knockback_vx += (@knockback_vx > 0 ? -1 : 1) if @knockback_vx != 0 && (!@gravity || !would_fit(0, 1))
    end
    
    def move_mechanics
        if @hunting then
            if @hunt_delay >= @hunt_max_delay then
                if @dodge then
                    if @inuhh.x - @x < -100*@dodge_range then
                        @dir = :left if @vy == 0 || @air_control || @waterproof
                    elsif @inuhh.x - @x > 100*@dodge_range
                        @dir = :right if @vy == 0 || @air_control || @waterproof
                    end
                else
                    @dir = (@inuhh.x < @x ? :left : :right)
                end
                @hunt_delay = 0
            end
            @hunt_delay += 1
        end
        if @fleeing then
            if @dodge then
                if @inuhh.x - @x < -100*@dodge_range then
                    @dir = :right if @vy == 0 || @air_control || @waterproof
                elsif @inuhh.x - @x > 100*@dodge_range
                    @dir = :left if @vy == 0 || @air_control || @waterproof
                end
            else
                @dir = (@inuhh.x < @x ? :right : :left)
            end
        end
        move_x = (@dir == :left ? -1 : 1)*@speed + @vx
        move_x = 0 if !@moving
        move_x /= 2.5 if @map.water(@x, @y) && !@waterproof && (move_x / 2.5).abs >= 1.0
        if (move_x == 0 && !@dir_set)
            @cur_image = @standing if @damage_counter <= 0
        else
            if @synced_animation_delay then
                @cur_image = ((@synced_timer / @anim_delay).floor % 2 == 0 || move_x == 0) ? @walk1 : @walk2 if @damage_counter <= 0
            else
                @cur_image = ((milliseconds / @anim_delay).floor % 2 == 0 || move_x == 0) ? @walk1 : @walk2 if @damage_counter <= 0
            end
        end
        if (@vy < 0) && @jump_image
            @cur_image = @jump
        end
        if move_x > 0 then
            @dir = :right if @vy == 0 || @air_control
            (move_x).to_i.times do
                if would_fit(1, 0) then @x += 1 end
                sub_move_mechanics
            end
        end
        if move_x < 0 then
            @dir = :left if @vy == 0 || @air_control
            (-move_x).to_i.times do
                if would_fit(-1, 0) then @x -= 1 end
                sub_move_mechanics
            end
        end
        if @knockback_vx > 0 then
            (@knockback_vx).times do
                #if would_fit(1, 0) then @x += 1 end
                if would_fit(1, 0) then
                    @x += 1
                else
                    @knockback_vx /= -2
                    @knockback_vx = @knockback_vx.to_i
                end
            end
        end
        if @knockback_vx < 0 then
            (-@knockback_vx).times do
                #if would_fit(-1, 0) then @x -= 1 end
                if would_fit(-1, 0) then
                    @x -= 1
                else
                    @knockback_vx /= -2
                    @knockback_vx = @knockback_vx.to_i
                end
            end
        end
    end
    
    def switch_dir
        @dir = (@dir == :left ? :right : :left) if !would_fit(0, 1) || !@gravity || @air_control
    end
            
    def border_mechanics
        if (!would_fit(1, 0) && @dir == :right) || (!would_fit(-1, 0) && @dir == :left) then
            @hunt_delay = @hunt_max_delay
            if !@border_jump_delay then
                switch_dir if @border_turn && @vy == 0
            elsif !random_jump(@border_jump_delay) then
                switch_dir if @border_turn && @vy == 0
            end
        end
    end
    
    def abyss_mechanics
        if would_fit((@dir == :left ? -@xsize : @xsize), 1) && !@jumping then
            if !@abyss_jump_delay || @vy != 0 || (@hunting && @inuhh.y > @y) || !random_jump(@abyss_jump_delay) then
                switch_dir if @abyss_turn
            end
        end
    end
    
    def try_to_jump
        if @map.solid?(@x - @xsize + 1, @y + 1) || @map.solid?(@x + @xsize - 1, @y + 1) then
            @vy = @jump_speed
            @window.play_sound("jump") if !@air_control && would_fit(0, -1) && (@inuhh.x - @x).abs <= 320 && (@inuhh.y - @y).abs < 240
            @vy += 8 if @map.water(@x, @y)
            @jumping = true
        end
    end
    
    def at_death
        
    end
    
    def at_shot(projectile)
        return true
    end
    
    def at_jumped_on
        
    end
    
    def at_collision
        return false
    end
    
    def fuse(time = nil)
        @range = 10000
        if time then
            @fuse_time = time
        end
        @fuse_counter = @fuse_time if !@fuse_counter
    end
    
    def detonate
        return if @detonated
        @detonated = true
        grav = (@gravity_detonation ? @gravity_detonation : 0.0)
        max = @detonation_intensity
        acc = @detonation_acc
        det_speed = @detonation_speed
        0.upto(max-1) do |i|
            theta = 2.0*Math::PI * (i.to_f/max.to_f)
            @window.spawn_projectile(@projectile_type, @x.to_f+(Projectiles::XSizes[@projectile_type]+@xsize*Math::cos(theta)),
                                     @y.to_f-@ysize.to_f-Projectiles::YSizes[@projectile_type]+@ysize*Math::sin(theta),
                                     det_speed*Math::cos(theta), det_speed*Math::sin(theta),
                                     acc*Math::cos(theta), grav+acc*Math::sin(theta), @projectile_owner, @projectile_lifetime, @projectile_damage, true)
        end
        damage(1000)
        @window.play_sound("detonation", 1, 0.9+rand*0.2)
    end
    
    def fuse_mechanics
        @fuse_counter -= 1 if @fuse_counter
        detonate if @fuse_counter == 0
    end
    
    def force_jump(height)
        @vy = -height
    end            
end

Dir.glob('./lib/Enemies/*') { |f| require f }

module Enemies
    
    Chishi = 0
    Daishi = 1
    Gasshi = 2
    Shipike = 3
    Enershi = 4
    Shiroplane = 5
    Shibmarine = 6
    Shilo = 7
    Neshi = 8
    Watershi = 9
    Shibmarine_D = 10
    Kamigasshi = 11
    Chishi_X = 12
    Chishi_Y = 13
    Shihog = 14
    Shistol = 15
    Shizooka = 16
    Gattershi = 17
    Grasshi = 18
    Shitomium = 19
    Shilectron = 20
    Takashi = 21
    Yasushi = 22
    Gammarine = 23
    Shitake = 24
    Shipple = 25
    Moleshi = 26
    Shitor = 27
    Shiparrow = 28
    Shipectral = 29
    Koroshi = 30
    Invinshi = 31
    Sushi = 32
    Daishi_X = 33
    Daishi_Y = 34
    Khashi = 35
    Shiturn = 36
    Pushi = 37
    TNShi = 38
    Nukeshi = 39
    Elashi = 40
    Shilat = 41
    Platisshi = 42
    Shireen = 43
    Shirror = 44
    Boxhi = 45
    Shicavator = 46
    Shimalaya = 47
    Shirill = 48
    Parashi = 49
    Shief = 50
    Shillar = 51
    Shicopter = 52
    Shirse = 53
    Shiteor = 54
    Shitizen = 55
    Shitraw = 56
    Shilevator = 57
    Shibmarine_Z = 58
    Shignite = 59
    Quarshi = 60
    Quanshi = 61
    Shitar = 62
    Mayshi = 63
    Shimmy = 64
    Shilopard = 65
    Poltershi = 66
    Demolishi = 67
    Shiredder = 68
    Extashi = 69
    Shilato = 70
    Climbshi = 71
    Shicicle = 72
    Rampashi = 73
    Turboshi = 74
    Shireball = 75
    Erupshi = 76
    Shivvy = 77
    Reapshi = 78
    Shiborg = 79
    Shinegun = 80
    Shi_52 = 81
    Shinamite = 82
    Hovershi = 83
    Shirman = 84
    Raishi = 85
    Multishi = 86
    Targeshi = 87
    Shiprinkler = 88
    Hyashi = 89
    Shidacea = 90
    Treashi = 91
    Launshi = 92
    Loxhi = 93
    Unloxhi = 94
    Comm_Araphaw = 95
    Comm_Unhorqh = 96
    Comm_Irnovel = 97
    Adm_Aromtharag = 98
    Shinsaw = 99
    Shindulum = 100
    Pacshi = 101
    Shishire = 102
    Lunarshi = 103
    Wereshi = 104
    Kanibashi = 105
    Shirpedo = 106
    Shirgantua = 107
    Shiwing = 108
    Shiesaw = 109
    Railshi = 110
    Collapshi = 111
    Shistnut = 112
    Shiranha = 113
    Avalanshi = 114
    Sledshi = 115
    Shinertia = 116
    Shiryumov = 117
    Shinge = 118
    Baskeshi = 119
    Carshi = 120
    Locomoshi = 121
    Carriashi = 122
    Darkshi = 123
    Polishi = 124
    Shippuku = 125
    Shopshi = 126
    Shiladdin = 127
    Shinny = 128
    Electrishi = 129
    Shirge = 130
    Fisshi = 131
    Shill = 132
    Cocoshi = 133
    Shifeguard = 134
    Shillowisp = 135
    Illushi = 136
    Tutenshi = 137
    Shirath = 138
    Shindelier = 139
    Big_Shi = 140
    Shicore = 141
    Agent_Dio_e = 142
    
    def self.register(nr)
        return Enemy_Datas.free_number + nr
    end
    
end

module Enemy_Datas
    
    Enemy_Void = Enemy_Data.new
    
    Enemy_Chishi = Enemy_Data.new(Enemies::Chishi) # 0
    Enemy_Daishi = Enemy_Data.new(Enemies::Daishi) # 1
    Enemy_Gasshi = Enemy_Data.new(Enemies::Gasshi) # 2
    Enemy_Shipike = Enemy_Data.new(Enemies::Shipike) # 3
    Enemy_Enershi = Enemy_Data.new(Enemies::Enershi) # 4
    Enemy_Shiroplane = Enemy_Data.new(Enemies::Shiroplane) # 5
    Enemy_Shibmarine = Enemy_Data.new(Enemies::Shibmarine) # 6
    Enemy_Shilo = Enemy_Data.new(Enemies::Shilo) # 7
    Enemy_Neshi = Enemy_Data.new(Enemies::Neshi) # 8
    Enemy_Watershi = Enemy_Data.new(Enemies::Watershi) # 9
    Enemy_Shibmarine_D = Enemy_Data.new(Enemies::Shibmarine_D) # 10
    Enemy_Kamigasshi = Enemy_Data.new(Enemies::Kamigasshi) # 11
    Enemy_Chishi_X = Enemy_Data.new(Enemies::Chishi_X) # 12
    Enemy_Chishi_Y = Enemy_Data.new(Enemies::Chishi_Y) # 13
    Enemy_Shihog = Enemy_Data.new(Enemies::Shihog) # 14
    Enemy_Shistol = Enemy_Data.new(Enemies::Shistol) # 15
    Enemy_Shizooka = Enemy_Data.new(Enemies::Shizooka) # 16
    Enemy_Gattershi = Enemy_Data.new(Enemies::Gattershi) # 17
    Enemy_Grasshi = Enemy_Data.new(Enemies::Grasshi) # 18
    Enemy_Shitomium = Enemy_Data.new(Enemies::Shitomium) # 19
    Enemy_Shilectron = Enemy_Data.new(Enemies::Shilectron) # 20
    Enemy_Takashi = Enemy_Data.new(Enemies::Takashi) # 21
    Enemy_Yasushi = Enemy_Data.new(Enemies::Yasushi) # 22
    Enemy_Gammarine = Enemy_Data.new(Enemies::Gammarine) # 23
    Enemy_Shitake = Enemy_Data.new(Enemies::Shitake) # 24
    Enemy_Shipple = Enemy_Data.new(Enemies::Shipple) # 25
    Enemy_Moleshi = Enemy_Data.new(Enemies::Moleshi) # 26
    Enemy_Shitor = Enemy_Data.new(Enemies::Shitor) # 27
    Enemy_Shiparrow = Enemy_Data.new(Enemies::Shiparrow) # 28
    Enemy_Shipectral = Enemy_Data.new(Enemies::Shipectral) # 29
    Enemy_Koroshi = Enemy_Data.new(Enemies::Koroshi) # 30
    Enemy_Invinshi = Enemy_Data.new(Enemies::Invinshi) # 31
    Enemy_Sushi = Enemy_Data.new(Enemies::Sushi) # 32
    Enemy_Daishi_X = Enemy_Data.new(Enemies::Daishi_X) # 33
    Enemy_Daishi_Y = Enemy_Data.new(Enemies::Daishi_Y) # 34
    Enemy_Khashi = Enemy_Data.new(Enemies::Khashi) # 35
    Enemy_Shiturn = Enemy_Data.new(Enemies::Shiturn) # 36
    Enemy_Pushi = Enemy_Data.new(Enemies::Pushi) # 37
    Enemy_TNShi = Enemy_Data.new(Enemies::TNShi) # 38
    Enemy_Nukeshi = Enemy_Data.new(Enemies::Nukeshi) # 39
    Enemy_Elashi = Enemy_Data.new(Enemies::Elashi) # 40
    Enemy_Shilat = Enemy_Data.new(Enemies::Shilat) # 41
    Enemy_Platisshi = Enemy_Data.new(Enemies::Platisshi) # 42
    Enemy_Shireen = Enemy_Data.new(Enemies::Shireen) # 43
    Enemy_Shirror = Enemy_Data.new(Enemies::Shirror) # 44
    Enemy_Boxhi = Enemy_Data.new(Enemies::Boxhi) # 45
    Enemy_Shicavator = Enemy_Data.new(Enemies::Shicavator) # 46
    Enemy_Shimalaya = Enemy_Data.new(Enemies::Shimalaya) # 47
    Enemy_Shirill = Enemy_Data.new(Enemies::Shirill) # 48
    Enemy_Parashi = Enemy_Data.new(Enemies::Parashi) # 49
    Enemy_Shief = Enemy_Data.new(Enemies::Shief) # 50
    Enemy_Shillar = Enemy_Data.new(Enemies::Shillar) # 51
    Enemy_Shicopter = Enemy_Data.new(Enemies::Shicopter) # 52
    Enemy_Shirse = Enemy_Data.new(Enemies::Shirse) # 53
    Enemy_Shiteor = Enemy_Data.new(Enemies::Shiteor) # 54
    Enemy_Shitizen = Enemy_Data.new(Enemies::Shitizen) # 55
    Enemy_Shitraw = Enemy_Data.new(Enemies::Shitraw) # 56
    Enemy_Shilevator = Enemy_Data.new(Enemies::Shilevator) # 57
    Enemy_Shibmarine_Z = Enemy_Data.new(Enemies::Shibmarine_Z) # 58
    Enemy_Shignite = Enemy_Data.new(Enemies::Shignite) # 59
    Enemy_Quarshi = Enemy_Data.new(Enemies::Quarshi) # 60
    Enemy_Quanshi = Enemy_Data.new(Enemies::Quanshi) # 61
    Enemy_Shitar = Enemy_Data.new(Enemies::Shitar) # 62
    Enemy_Mayshi = Enemy_Data.new(Enemies::Mayshi) # 63
    Enemy_Shimmy = Enemy_Data.new(Enemies::Shimmy) # 64
    Enemy_Shilopard = Enemy_Data.new(Enemies::Shilopard) # 65
    Enemy_Poltershi = Enemy_Data.new(Enemies::Poltershi) # 66
    Enemy_Demolishi = Enemy_Data.new(Enemies::Demolishi) # 67
    Enemy_Shiredder = Enemy_Data.new(Enemies::Shiredder) # 68
    Enemy_Extashi = Enemy_Data.new(Enemies::Extashi) # 69
    Enemy_Shilato = Enemy_Data.new(Enemies::Shilato) # 70
    Enemy_Climbshi = Enemy_Data.new(Enemies::Climbshi) # 71
    Enemy_Shicicle = Enemy_Data.new(Enemies::Shicicle) # 72
    Enemy_Rampashi = Enemy_Data.new(Enemies::Rampashi) # 73
    Enemy_Turboshi = Enemy_Data.new(Enemies::Turboshi) # 74
    Enemy_Shireball = Enemy_Data.new(Enemies::Shireball) # 75
    Enemy_Erupshi = Enemy_Data.new(Enemies::Erupshi) # 76
    Enemy_Shivvy = Enemy_Data.new(Enemies::Shivvy) # 77
    Enemy_Reapshi = Enemy_Data.new(Enemies::Reapshi) # 78
    Enemy_Shiborg = Enemy_Data.new(Enemies::Shiborg) # 79
    Enemy_Shinegun = Enemy_Data.new(Enemies::Shinegun) # 80
    Enemy_Shi_52 = Enemy_Data.new(Enemies::Shi_52) # 81
    Enemy_Shinamite = Enemy_Data.new(Enemies::Shinamite) # 82
    Enemy_Hovershi = Enemy_Data.new(Enemies::Hovershi) # 83
    Enemy_Shirman = Enemy_Data.new(Enemies::Shirman) # 84
    Enemy_Raishi = Enemy_Data.new(Enemies::Raishi) # 85
    Enemy_Multishi = Enemy_Data.new(Enemies::Multishi) # 86
    Enemy_Targeshi = Enemy_Data.new(Enemies::Targeshi) # 87
    Enemy_Shiprinkler = Enemy_Data.new(Enemies::Shiprinkler) # 88
    Enemy_Hyashi = Enemy_Data.new(Enemies::Hyashi) # 89
    Enemy_Shidacea = Enemy_Data.new(Enemies::Shidacea) # 90
    Enemy_Treashi = Enemy_Data.new(Enemies::Treashi) # 91
    Enemy_Launshi = Enemy_Data.new(Enemies::Launshi) # 92
    Enemy_Loxhi = Enemy_Data.new(Enemies::Loxhi) # 93
    Enemy_Unloxhi = Enemy_Data.new(Enemies::Unloxhi) # 94
    Enemy_Comm_Araphaw = Enemy_Data.new(Enemies::Comm_Araphaw) # 95
    Enemy_Comm_Unhorqh = Enemy_Data.new(Enemies::Comm_Unhorqh) # 96
    Enemy_Comm_Irnovel = Enemy_Data.new(Enemies::Comm_Irnovel) # 97
    Enemy_Adm_Aromtharag = Enemy_Data.new(Enemies::Adm_Aromtharag) # 98
    Enemy_Shinsaw = Enemy_Data.new(Enemies::Shinsaw) # 99
    Enemy_Shindulum = Enemy_Data.new(Enemies::Shindulum) # 100
    Enemy_Pacshi = Enemy_Data.new(Enemies::Pacshi) # 101
    Enemy_Shishire = Enemy_Data.new(Enemies::Shishire) # 102
    Enemy_Lunarshi = Enemy_Data.new(Enemies::Lunarshi) # 103
    Enemy_Wereshi = Enemy_Data.new(Enemies::Wereshi) # 104
    Enemy_Kanibashi = Enemy_Data.new(Enemies::Kanibashi) # 105
    Enemy_Shirpedo = Enemy_Data.new(Enemies::Shirpedo) # 106
    Enemy_Shirgantua = Enemy_Data.new(Enemies::Shirgantua) # 107
    Enemy_Shiwing = Enemy_Data.new(Enemies::Shiwing) # 108
    Enemy_Shiesaw = Enemy_Data.new(Enemies::Shiesaw) # 109
    Enemy_Railshi = Enemy_Data.new(Enemies::Railshi) # 110
    Enemy_Collapshi = Enemy_Data.new(Enemies::Collapshi) # 111
    Enemy_Shistnut = Enemy_Data.new(Enemies::Shistnut) # 112
    Enemy_Shiranha = Enemy_Data.new(Enemies::Shiranha) # 113
    Enemy_Avalanshi = Enemy_Data.new(Enemies::Avalanshi) # 114
    Enemy_Sledshi = Enemy_Data.new(Enemies::Sledshi) # 115
    Enemy_Shinertia = Enemy_Data.new(Enemies::Shinertia) # 116
    Enemy_Shiryumov = Enemy_Data.new(Enemies::Shiryumov) # 117
    Enemy_Shinge = Enemy_Data.new(Enemies::Shinge) # 118
    Enemy_Baskeshi = Enemy_Data.new(Enemies::Baskeshi) # 119
    Enemy_Carshi = Enemy_Data.new(Enemies::Carshi) # 120
    Enemy_Locomoshi = Enemy_Data.new(Enemies::Locomoshi) # 121
    Enemy_Carriashi = Enemy_Data.new(Enemies::Carriashi) # 122
    Enemy_Darkshi = Enemy_Data.new(Enemies::Darkshi) # 123
    Enemy_Polishi = Enemy_Data.new(Enemies::Polishi) # 124
    Enemy_Shippuku = Enemy_Data.new(Enemies::Shippuku) # 125
    Enemy_Shopshi = Enemy_Data.new(Enemies::Shopshi) # 126
    Enemy_Shiladdin = Enemy_Data.new(Enemies::Shiladdin) # 127
    Enemy_Shinny = Enemy_Data.new(Enemies::Shinny) # 128
    Enemy_Electrishi = Enemy_Data.new(Enemies::Electrishi) # 129
    Enemy_Shirge = Enemy_Data.new(Enemies::Shirge) # 130
    Enemy_Fisshi = Enemy_Data.new(Enemies::Fisshi) # 131
    Enemy_Shill = Enemy_Data.new(Enemies::Shill) # 132
    Enemy_Cocoshi = Enemy_Data.new(Enemies::Cocoshi) # 133
    Enemy_Shifeguard = Enemy_Data.new(Enemies::Shifeguard) # 134
    Enemy_Shillowisp = Enemy_Data.new(Enemies::Shillowisp) # 135
    Enemy_Illushi = Enemy_Data.new(Enemies::Illushi) # 136
    Enemy_Tutenshi = Enemy_Data.new(Enemies::Tutenshi) # 137
    Enemy_Shirath = Enemy_Data.new(Enemies::Shirath) # 138
    Enemy_Shindelier = Enemy_Data.new(Enemies::Shindelier) # 139
    Enemy_Big_Shi = Enemy_Data.new(Enemies::Big_Shi) # 140
    Enemy_Shicore = Enemy_Data.new(Enemies::Shicore) # 141
    Enemy_Agent_Dio_e = Enemy_Data.new(Enemies::Agent_Dio_e) # 142
    
    def self.i_index
        return @@i_index
    end
    
    def self.c_index
        return @@c_index
    end
    
    def self.n_index
        return @@n_index
    end
    
    def self.editor_pics
        return @@editor_pics
    end
    
    def self.free_number
        return @@i_index.size
    end
    
    def self.add_enemy(enemy_data, enemy_class, enemy_name)
        @@i_index.push(enemy_data)
        @@c_index.push(enemy_class)
        @@n_index.push(enemy_name)
    end
    
    def self.add_editor_pics(file_name)
        @@editor_pics.push(file_name)
    end
    
    def self.add_mod_editor_pics(mod, name)
        @@editor_pics.push("mods/#{mod}/media/editor/#{name}.png")
    end
    
    def self.activate
        @@i_index = [Enemy_Chishi, Enemy_Daishi, Enemy_Gasshi, Enemy_Shipike, Enemy_Enershi, Enemy_Shiroplane, Enemy_Shibmarine, Enemy_Shilo, Enemy_Neshi,
                     Enemy_Watershi, Enemy_Shibmarine_D, Enemy_Kamigasshi, Enemy_Chishi_X, Enemy_Chishi_Y, Enemy_Shihog, Enemy_Shistol, Enemy_Shizooka,
                     Enemy_Gattershi, Enemy_Grasshi, Enemy_Shitomium, Enemy_Shilectron, Enemy_Takashi, Enemy_Yasushi, Enemy_Gammarine, Enemy_Shitake,
                     Enemy_Shipple, Enemy_Moleshi, Enemy_Shitor, Enemy_Shiparrow, Enemy_Shipectral, Enemy_Koroshi, Enemy_Invinshi, Enemy_Sushi, Enemy_Daishi_X,
                     Enemy_Daishi_Y, Enemy_Khashi, Enemy_Shiturn, Enemy_Pushi, Enemy_TNShi, Enemy_Nukeshi, Enemy_Elashi, Enemy_Shilat, Enemy_Platisshi,
                     Enemy_Shireen, Enemy_Shirror, Enemy_Boxhi, Enemy_Shicavator, Enemy_Shimalaya, Enemy_Shirill, Enemy_Parashi, Enemy_Shief, Enemy_Shillar,
                     Enemy_Shicopter, Enemy_Shirse, Enemy_Shiteor, Enemy_Shitizen, Enemy_Shitraw, Enemy_Shilevator, Enemy_Shibmarine_Z, Enemy_Shignite,
                     Enemy_Quarshi, Enemy_Quanshi, Enemy_Shitar, Enemy_Mayshi, Enemy_Shimmy, Enemy_Shilopard, Enemy_Poltershi, Enemy_Demolishi, Enemy_Shiredder,
                     Enemy_Extashi, Enemy_Shilato, Enemy_Climbshi, Enemy_Shicicle, Enemy_Rampashi, Enemy_Turboshi, Enemy_Shireball, Enemy_Erupshi, Enemy_Shivvy,
                     Enemy_Reapshi, Enemy_Shiborg, Enemy_Shinegun, Enemy_Shi_52, Enemy_Shinamite, Enemy_Hovershi, Enemy_Shirman, Enemy_Raishi, Enemy_Multishi,
                     Enemy_Targeshi, Enemy_Shiprinkler, Enemy_Hyashi, Enemy_Shidacea, Enemy_Treashi, Enemy_Launshi, Enemy_Loxhi, Enemy_Unloxhi, Enemy_Comm_Araphaw,
                     Enemy_Comm_Unhorqh, Enemy_Comm_Irnovel, Enemy_Adm_Aromtharag, Enemy_Shinsaw, Enemy_Shindulum, Enemy_Pacshi, Enemy_Shishire, Enemy_Lunarshi,
                     Enemy_Wereshi, Enemy_Kanibashi] # IDs
        @@c_index = [Chishi, Daishi, Gasshi, Shipike, Enershi, Shiroplane, Shibmarine, Shilo, Neshi, Watershi, Shibmarine_D, Kamigasshi, Chishi_X, Chishi_Y, Shihog,
                     Shistol, Shizooka, Gattershi, Grasshi, Shitomium, Shilectron, Takashi, Yasushi, Gammarine, Shitake, Shipple, Moleshi, Shitor, Shiparrow,
                     Shipectral, Koroshi, Invinshi, Sushi, Daishi_X, Daishi_Y, Khashi, Shiturn, Pushi, TNShi, Nukeshi, Elashi, Shilat, Platisshi, Shireen,
                     Shirror, Boxhi, Shicavator, Shimalaya, Shirill, Parashi, Shief, Shillar, Shicopter, Shirse, Shiteor, Shitizen, Shitraw, Shilevator,
                     Shibmarine_Z, Shignite, Quarshi, Quanshi, Shitar, Mayshi, Shimmy, Shilopard, Poltershi, Demolishi, Shiredder, Extashi, Shilato, Climbshi,
                     Shicicle, Rampashi, Turboshi, Shireball, Erupshi, Shivvy, Reapshi, Shiborg, Shinegun, Shi_52, Shinamite, Hovershi, Shirman, Raishi, Multishi,
                     Targeshi, Shiprinkler, Hyashi, Shidacea, Treashi, Launshi, Loxhi, Unloxhi, Comm_Araphaw, Comm_Unhorqh, Comm_Irnovel, Adm_Aromtharag, Shinsaw,
                     Shindulum, Pacshi, Shishire, Lunarshi, Wereshi, Kanibashi] # Classes
        @@n_index = ["Chishi", "Daishi", "Gasshi", "Shipike", "Enershi", "Shiroplane", "Shibmarine", "Shilo", "Neshi", "Watershi", "Shibmarine D",
                     "Kamigasshi", "Chishi X", "Chishi Y", "Shihog", "Shistol", "Shizooka", "Gattershi", "Grasshi", "Shitomium", "Shilectron",
                     "Takashi", "Yasushi", "Gammarine", "Shitake", "Shipple", "Moleshi", "Shitor", "Shiparrow", "Shipectral", "Koroshi", "Invinshi",
                     "Sushi", "Daishi X", "Daishi Y", "Khashi", "Shiturn", "Pushi", "TNShi", "Nukeshi", "Elashi", "Shilat", "Platisshi", "Shireen",
                     "Shirror", "Boxhi", "Shicavator", "Shimalaya", "Shirill", "Parashi", "Shief", "Shillar", "Shicopter", "Shirse", "Shiteor", "Shitizen",
                     "Shitraw", "Shilevator", "Shibmarine Z", "Shignite", "Quarshi", "Quanshi", "Shitar", "Mayshi", "Shimmy", "Shilopard", "Poltershi",
                     "Demolishi", "Shiredder", "Extashi", "Shilato", "Climbshi", "Shicicle", "Rampashi", "Turboshi", "Shireball", "Erupshi", "Shivvy",
                     "Reapshi", "Shiborg", "Shinegun", "Shi-52", "Shinamite", "Hovershi", "Shirman", "Raishi", "Multishi", "Targeshi", "Shiprinkler",
                     "Hyashi", "Shidacea", "Treashi", "Launshi", "Loxhi", "Unloxhi", "Cm. Araphaw", "Cm. Unhorqh", "Cm. Irnovel", "Ad. Aromtharag", "Shinsaw",
                     "Shindulum", "Pacshi", "Shishire", "Lunarshi", "Wereshi", "Kanibashi"] # Names
        @@editor_pics = [Pics::Editor_Enemies]
    end
    
    self.activate
    
end

