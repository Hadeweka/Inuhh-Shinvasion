class Collectible
    attr_reader :constant, :transform, :help, :image
    attr_accessor :x, :y
    
    def initialize(image, x, y)
        @image = image
        @x, @y = x, y
        @score = 0
        @collectibles = []
        @stats = []
        @boosts = []
        @help = nil
        @fly = false
        @shi_coin = false
        @hedgehound = false
        @constant = false
        @usable = false
        @usable_once = false
        @uses = 1
        @collection_cooldown = 0
        @own_sound = false
        @transform = false
        @text_color = 0xffffff00
    end
    
    def play_collected_sound(window, inuhh)
        window.play_sound("item") if !@own_sound
    end
    
    def play_used_sound(window, inuhh)
        
    end

    def modify_uses(uses)
        @uses = uses
    end
    
    def draw
        @image.draw(@x-25, @y-25, ZOrder::Gems)
    end
    
    def draw_in_inventory(window, inuhh)
        if @transform then
            window.font.draw(inuhh.item_amount, inuhh.x-7*(Math::log10(inuhh.item_amount).to_i+1), inuhh.y-60, ZOrder::UI, 1.5, 1.5, 0xffffff33) if !@usable_once
        else
            @image.draw(inuhh.x-22, inuhh.y-60, ZOrder::UI, 0.5, 0.5)
            window.font.draw(inuhh.item_amount, inuhh.x-7+10, inuhh.y-60, ZOrder::UI, 1.5, 1.5, 0xffffff33) if !@usable_once
        end
    end
    
    def update(window, inuhh)
        @collection_cooldown -= 1 if @collection_cooldown > 0
    end

    def lock_collection
        @collection_cooldown = 60
    end

    def locked?
        @collection_cooldown > 0
    end
    
    def give_inuhh(window, inuhh)
        if @usable_once then
            inuhh.set_item(self, @uses)
        else
            inuhh.add_item(self, @uses)
        end
    end
    
    def collect(window, inuhh) # Rewrite a little bit, to make it more compatible with new items, boosts, etc.
        display_score = true
        play_collected_sound(window, inuhh)
        @collectibles.each do |c|
            inuhh.get_collectible(c[0], c[1])
        end
        @stats.each do |s|
            inuhh.increase_stat(s[0], s[1])
        end
        @boosts.each do |b|
            inuhh.boost(b[0], b[1], b[2])
        end
        
        inuhh.fly if @fly
        give_inuhh(window, inuhh) if @usable
        
        if @shi_coin then
            if window.collected_shi_coin(@x, @y) then
                @score = 100000
            else
                inuhh.get_collectible(Objects::Shi_Coin, 1)
            end
            window.collect_shi_coin(@x, @y)
        end
        window.activate_hedgehound if @hedgehound
        if @score.is_a? Integer then
            window.messages.push([@score, @x-25, @y, 100, true, 1.0+(@score/50000.0), 1.0+(@score/50000.0), @text_color]) if display_score
            inuhh.increase_stat(Stats::Score, @score)
        else
            window.messages.push([@score, @x-25, @y, 100, true, 2.0, 2.0, @text_color]) if display_score
        end
    end
    
    def use(window, inuhh)
        play_used_sound(window, inuhh)
        return true
    end
    
end

class CollectibleGem < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = 20000
        @own_sound = true
        @collectibles.push([Objects::Gem, 1])
    end
    
    def play_collected_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("gem", 1, 0.9+rand*0.2)
    end
    
    def draw
        # Draw, slowly rotating
        @image.draw_rot(@x, @y, ZOrder::Gems, 25 * Math.sin(milliseconds / 133.7))
    end
    
end

class CollectibleCoin < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = 1000
        @phase = rand*2*Math::PI
        @own_sound = true
        @collectibles.push([Objects::Coin, 1])
    end
    
    def play_collected_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("coin", 1, 1.4+rand*0.2)
    end
    
    def draw
        @image.draw(@x-25*Math.sin(milliseconds / 133.7 + @phase), @y-25, ZOrder::Gems, 1.0*Math.sin(milliseconds / 133.7 + @phase))
    end
    
end

class CollectibleShiCoin < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @shi_coin = true
        @score = "Shi Coin"
        @own_sound = true
        @phase = rand*2*Math::PI
        @shading = 0xffffffff
    end
    
    def play_collected_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("coin", 0.8, 2.0)
        window.play_sound("coin", 0.7, 1.5)
        window.play_sound("coin", 0.6, 1.0)
    end
    
    def update(window, inuhh)
        super(window, inuhh)
        shade if window.collected_shi_coin(@x, @y)
    end
    
    def shade
        @shading = 0xff555555
    end
    
    def draw
        @image.draw(@x-25*Math.sin(milliseconds / 133.7 + @phase), @y-25, ZOrder::Gems, 1.0*Math.sin(milliseconds / 133.7 + @phase), 1.0, @shading)
    end
    
end

class CollectibleBone < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "+ 1"
        @own_sound = true
        @stats.push([Stats::Energy, 1])
        @text_color = 0xff0088ff
    end
    
    def play_collected_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("nom", 1, 1.0+rand*0.2)
    end
    
    def draw
        @image.draw_rot(@x, @y, ZOrder::Gems, 25 * Math.sin(milliseconds / 133.7))
    end
    
end

class CollectibleWing < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Wings"
        @fly = true
        @help = 55
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
end

class NPCHedgehound < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = nil
        @hedgehound = true
        @own_sound = true
        @constant = true
    end
    
end

class CollectiblePedestal < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Pedestal"
        @usable = true
        @usable_once = true
        @help = 48
        @transform = "Pedestal"
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def play_used_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("plop", 1, 1.0+rand*0.2)
    end
    
    def use(window, inuhh)
        return false if inuhh.in_air
        return false if !window.map.solid?(inuhh.x - inuhh.xsize/2, inuhh.y + 1) || !window.map.solid?(inuhh.x + inuhh.xsize/2, inuhh.y + 1)
        old_inuhh_y = inuhh.y
        inuhh.shift_up(3)
        if window.add_tile_in_passable(inuhh.x, old_inuhh_y, Tiles::Exterior) then
            if window.add_tile_in_passable(inuhh.x, old_inuhh_y-50, Tiles::Exterior) then
                window.add_tile_in_passable(inuhh.x, old_inuhh_y-100, Tiles::Exterior)
            end
        end
        super(window, inuhh)
    end
    
end

class CollectibleShistol < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Shistol"
        @usable = true
        @uses = 5
        @help = 49
        @transform = "Shistol"
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def use(window, inuhh)
        dirfac = (inuhh.dir == :left ? -1.0 : 1.0)
        window.spawn_projectile(Projectiles::Standard, inuhh.x.to_f+(Projectiles::XSizes[Projectiles::Standard]+inuhh.xsize-5)*dirfac,
                                inuhh.y.to_f-2*inuhh.ysize.to_f-Projectiles::YSizes[Projectiles::Standard],
                                10.0*dirfac, 0.0, 0.0, 0.0, Projectiles::INUHH, nil, 2)
        super(window, inuhh)
    end
    
end

class CollectibleFruit < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "1 / 3"
        @text_color = 0xffff88ff
        @own_sound = true
        @usable = false
        @collectibles.push([Objects::Fruit, 1])
    end
    
    def play_collected_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("nom", 1, 1.8+rand*0.2)
    end
    
    def collect(window, inuhh)
        @score = "#{inuhh.collectibles[Objects::Fruit]+1} / 3"
        super(window, inuhh)
    end
    
end

class CollectibleMysteriorb < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Mysteriorb"
        @shading = 0xffffffff
        @phase = 0
    end
    
    def update(window, inuhh)
        super(window, inuhh)
        if window.other_option(Other::Mysteriorb) then
            @score = 100000 if window.other_option(Other::Mysteriorb)[window.level]
            shade if window.other_option(Other::Mysteriorb)[window.level]
        end
    end
    
    def shade
        @shading = 0xff555555
    end
    
    def draw
        @image.draw(@x-25*Math.sin(milliseconds / 1337.0 + @phase), @y-25, ZOrder::Gems, 1.0*Math.sin(milliseconds / 1337.0 + @phase), 1.0, @shading)
    end
    
    def collect(window, inuhh)
        if !window.other_option(Other::Mysteriorb) then
            window.set_other_option(Other::Mysteriorb, {})
        end
        window.set_other_param(Other::Mysteriorb, window.level, true)
        super(window, inuhh)
    end
    
end

class CollectibleCompass < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Compass Piece"
        @shading = 0xffffffff
        @phase = 0
    end
    
    def update(window, inuhh)
        super(window, inuhh)
        if window.other_option(Other::Compass) then
            @score = 100000 if window.other_option(Other::Compass)[window.level]
            shade if window.other_option(Other::Compass)[window.level]
        end
    end
    
    def shade
        @shading = 0xff555555
    end
    
    def draw
        @image.draw(@x-25*Math.sin(milliseconds / 1337.0 + @phase), @y-25, ZOrder::Gems, 1.0*Math.sin(milliseconds / 1337.0 + @phase), 1.0, @shading)
    end
    
    def collect(window, inuhh)
        if !window.other_option(Other::Compass) then
            window.set_other_option(Other::Compass, {})
        end
        window.set_other_param(Other::Compass, window.level, true)
        super(window, inuhh)
    end
    
end

class DecorationDrips < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = nil
        @own_sound = true
        @constant = true
        @maxcounter = 100+rand(100)
        @counter = rand(@maxcounter)
    end
    
    def update(window, inuhh)
        super(window, inuhh)
        if @counter <= 0 then
            @counter = @maxcounter
            window.spawn_projectile(Projectiles::Water, @x, @y - 20, 0.0, 0.0, 0.0, 0.5, Projectiles::RAMPAGE, nil, 1)
        end
        @counter -= 1
    end
    
    def draw
        @image.draw(@x-25, @y-25, ZOrder::Gems, 1.0, 2.0*Math::cos(@counter/@maxcounter))
    end
    
end

class CollectibleBoots < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Boots"
        @help = 56
    end
    
    def collect(window, inuhh)
        inuhh.boost(Stats::Speed, 1, 300)
        super(window, inuhh)
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
end

class CollectibleSand < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Sand"
        @help = 51
        @usable = true
        @transform = "Pedestal"
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def use(window, inuhh)
        return false if inuhh.in_air
        return false if !window.map.solid?(inuhh.x - inuhh.xsize/2, inuhh.y + 1) || !window.map.solid?(inuhh.x + inuhh.xsize/2, inuhh.y + 1)
        old_inuhh_y = inuhh.y
        inuhh.shift_up(1)
        window.add_tile_in_passable(inuhh.x, old_inuhh_y, Tiles::Sand)
        super(window, inuhh)
    end
    
end

class CollectibleKey < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Key"
        @help = 52
        @usable = true
        @phase = 0
    end
    
    def use(window, inuhh)
        rx = inuhh.x+(inuhh.dir == :left ? -inuhh.xsize-1 : inuhh.xsize+1)
        ry = inuhh.y
        if window.map.keyhole(rx, ry) then
            window.add_tile(rx, ry, nil)
            window.play_sound("detonation", 1, 0.7)
        elsif window.map.keyhole(inuhh.x, ry+1) then
            window.add_tile(inuhh.x, ry+1, nil)
            window.play_sound("detonation", 1, 0.7)
        else
            return
        end
        super(window, inuhh)
    end
    
    def draw
        @image.draw(@x-25*Math.sin(milliseconds / 537.0 + @phase), @y-25, ZOrder::Gems, 1.0*Math.sin(milliseconds / 537.0 + @phase))
    end
    
end

class CollectibleShizooka < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Shizooka"
        @usable = true
        @help = 49
        @uses = 10
        @transform = "Shizooka"
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def use(window, inuhh)
        dirfac = (inuhh.dir == :left ? -1.0 : 1.0)
        window.spawn_projectile(Projectiles::Standard, inuhh.x.to_f+(Projectiles::XSizes[Projectiles::Standard]+inuhh.xsize-5)*dirfac,
                                inuhh.y.to_f-2*inuhh.ysize.to_f-Projectiles::YSizes[Projectiles::Standard],
                                15.0*dirfac, 0.0, 0.0, 0.02, Projectiles::INUHH, nil, 3)
        super(window, inuhh)
    end
    
end

class CollectibleGoldBone < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "+ 5"
        @stats.push([Stats::Energy, 5])
        @own_sound = true
        @text_color = 0xff0088ff
    end
    
    def play_collected_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("nom", 1, 1.4+rand*0.3)
    end
    
    def draw
        @image.draw_rot(@x, @y, ZOrder::Gems, 25 * Math.sin(milliseconds / 133.7))
    end
    
end

class CollectibleShistolPlus < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Shistol Plus"
        @usable = true
        @help = 48
        @uses = 20
        @transform = "Shistol"
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def use(window, inuhh)
        dirfac = (inuhh.dir == :left ? -1.0 : 1.0)
        window.spawn_projectile(Projectiles::Standard, inuhh.x.to_f+(Projectiles::XSizes[Projectiles::Standard]+inuhh.xsize-5)*dirfac,
                                inuhh.y.to_f-2*inuhh.ysize.to_f-Projectiles::YSizes[Projectiles::Standard],
                                10.0*dirfac, 0.0, 0.0, 0.0, Projectiles::INUHH, nil, 2)
        super(window, inuhh)
    end
    
end

class CollectibleShinegun < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Shinegun"
        @usable = true
        @help = 50
        @uses = 15
        @transform = "Shinegun"
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def use(window, inuhh)
        dirfac = (inuhh.dir == :left ? -1.0 : 1.0)
        window.spawn_projectile(Projectiles::Standard, inuhh.x.to_f+(Projectiles::XSizes[Projectiles::Standard]+inuhh.xsize-5)*dirfac,
                                inuhh.y.to_f-2*inuhh.ysize.to_f-Projectiles::YSizes[Projectiles::Standard],
                                20.0*dirfac, 0.0, 0.0, 0.0, Projectiles::INUHH, nil, 4)
        super(window, inuhh)
    end
    
end

class CollectibleShinegunPlus < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Shinegun Plus"
        @usable = true
        @help = 50
        @uses = 9000
        @transform = "Shinegun"
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def use(window, inuhh)
        dirfac = (inuhh.dir == :left ? -1.0 : 1.0)
        window.spawn_projectile(Projectiles::Standard, inuhh.x.to_f+(Projectiles::XSizes[Projectiles::Standard]+inuhh.xsize-5)*dirfac,
                                inuhh.y.to_f-2*inuhh.ysize.to_f-Projectiles::YSizes[Projectiles::Standard],
                                20.0*dirfac, 0.0, 0.0, 0.0, Projectiles::INUHH, nil, 4)
        super(window, inuhh)
    end
    
end

class CollectibleFlippers < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Flippers"
        @help = 57
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def collect(window, inuhh)
        inuhh.set_water_boost(1.5)
        super(window, inuhh)
    end
    
end

class CollectibleUltraBone < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "+ 20"
        @stats.push([Stats::Energy, 20])
        @own_sound = true
        @text_color = 0xff0088ff
    end
    
    def play_collected_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("nom", 0.5, 1.8+rand*0.3)
        window.play_sound("nom", 0.5, 1.4+rand*0.3)
        window.play_sound("nom", 0.5, 1.0+rand*0.3)
    end
    
    def draw
        @image.draw_rot(@x, @y, ZOrder::Gems, 25 * Math.sin(milliseconds / 133.7))
    end
    
end

class CollectibleBat < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Bat"
        @usable = true
        @help = 58
        @uses = 10
        @wield_dir = 1 # -1 = down, 1 = up, not in use at the moment
        @transform = "Bat"
    end
    
    def draw
        @image.draw_rot(@x, @y, ZOrder::Gems, 25 * Math.sin(milliseconds / 133.7))
    end
    
    def use(window, inuhh)
        item_used = false
        window.enemies.each do |e|	# Should run much better now... still to test, though
            bat_point_x = inuhh.x + inuhh.xsize*(inuhh.dir == :left ? -1 : 1)
            bat_point_y = inuhh.y - 2*inuhh.ysize
            diffx = -bat_point_x + e.x
            diffy = -bat_point_y + e.y - e.ysize
            angle = diffx/Math::sqrt(diffx**2.0 + diffy**2.0)
            distance = (diffx - e.xsize*angle)**2 + (diffy + e.ysize*Math::sqrt(1-angle**2))**2
            next if distance >= 20**2
            e.force_knockback((15.0*angle).to_i)
            e.kick_high(@wield_dir*20)
            item_used = true
        end
        return false if !item_used
        super(window, inuhh)
    end
    
end

class CollectibleBall < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Ball"
        @help = 59
        @usable = true
    end
    
    def draw
        @image.draw(@x-25, @y - 25, ZOrder::Gems)
    end
    
    def use(window, inuhh)
        dirfac = (inuhh.dir == :left ? -1.0 : 1.0)
        window.spawn_projectile(Projectiles::Ball, inuhh.x.to_f+(Projectiles::XSizes[Projectiles::Ball]+inuhh.xsize-5)*dirfac,
                                inuhh.y.to_f-2*inuhh.ysize.to_f-Projectiles::YSizes[Projectiles::Ball],
                                10.0*dirfac, -10.0, 0.0, 1.0, Projectiles::INUHH, nil, 3)
        super(window, inuhh)
    end
    
end

class CollectibleMagicLamp < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Magic Lamp"
        @help = 60
        @usable = true
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def use(window, inuhh)
        shinny = window.spawn_enemy(Enemies::Shinny, inuhh.x, inuhh.y - inuhh.ysize - 100, inuhh.dir)
        shinny.bind(inuhh)
        super(window, inuhh)
    end
    
end

class DecorationWarning < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = nil
        @own_sound = true
        @constant = true
    end
    
    def update(window, inuhh)
        super(window, inuhh)
    end
    
    def draw
        @image.draw(@x-25, @y-25, ZOrder::Gems)
    end
    
end

class MinigameObserver < Collectible
    
    attr_accessor :var
    
    # Swimming course minigame
    RAND_TIMER = 0
    LAST_TIMER = 1
    SHIREENS = 2
    ENEMIES = 3
    DIFFICULTY = 4
    SHIREENS_FRONT = 5
    SHIREEN_POS = 6
    MAX_X = 7
    ENEMY_LIST = 8
    ALL_ENEMIES = 9
    
    # Herbal quest minigame
    COLLECTED_ITEMS = 10
    PLACEMENT_THRESHOLD = 11
    ENEMY_THRESHOLD = 12
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = nil
        @own_sound = true
        @constant = true
        @timer = 0
        @var = []
    end
    
    def create_collectible(window, collectible, x, y)
        window.gems.push(Object_Datas::C_Index[collectible].new(window.valimgs[collectible], x, y))
    end
    
    def update(window, inuhh)
        super(window, inuhh)
        if @timer == 0 then
            world = window.level.split("-")[0].to_i
            @minigame_id = Minigames::World_Levels[world]
            
            init_minigame_w_1(window, inuhh) if @minigame_id == Minigames::Swimming_Course
            init_minigame_w_2(window, inuhh) if @minigame_id == Minigames::Herbal_Quest
            
            window.initiate_minigame(@minigame_lifes)
        end
        
        minigame_w_1(window, inuhh) if @minigame_id == Minigames::Swimming_Course
        minigame_w_2(window, inuhh) if @minigame_id == Minigames::Herbal_Quest
        
        @timer += 1
    end
    
    def init_minigame_w_1(window, inuhh)
        inuhh.manipulate_energy(3)
        @minigame_lifes = 3
        @var[RAND_TIMER] = 100 + rand(100)
        @var[LAST_TIMER] = 0
        @var[SHIREENS] = []
        @var[ENEMIES] = []
        @var[SHIREENS_FRONT] = []
        @var[SHIREEN_POS] = 0.0
        @var[MAX_X] = 1000*50 - 10*50
        if Difficulty.get == Difficulty::EASY then
            @var[ENEMY_LIST] = [Enemies::Shibmarine]
            @var[ALL_ENEMIES] = [Enemies::Shibmarine]
        elsif Difficulty.get == Difficulty::NORMAL then
            @var[ENEMY_LIST] = [Enemies::Shibmarine]*20
            @var[ALL_ENEMIES] = [Enemies::Sushi]*5 + [Enemies::Shibmarine_Z]*1
        elsif Difficulty.get == Difficulty::HARD then
            @var[ENEMY_LIST] = [Enemies::Shibmarine]*15
            @var[ALL_ENEMIES] = [Enemies::Sushi]*5 + [Enemies::Shibmarine_Z]*2
        elsif Difficulty.get == Difficulty::DOOM then
            @var[ENEMY_LIST] = [Enemies::Shibmarine]*10
            @var[ALL_ENEMIES] = [Enemies::Sushi] + [Enemies::Shibmarine_Z]
        end
    end
    
    def init_minigame_w_2(window, inuhh)
        inuhh.manipulate_energy(5)
        @minigame_lifes = 1
        @var[COLLECTED_ITEMS] = {}
        
        @var[PLACEMENT_THRESHOLD] = {}
        @var[PLACEMENT_THRESHOLD][PlantDominherb] = 10
        @var[PLACEMENT_THRESHOLD][PlantDottery] = 15
        @var[PLACEMENT_THRESHOLD][PlantShiTreeSeed] = 10
        @var[PLACEMENT_THRESHOLD][PlantDominweed] = 5
        @var[PLACEMENT_THRESHOLD][PlantNautulip] = 1
        @var[PLACEMENT_THRESHOLD][PlantNautaisy] = 10
        @var[PLACEMENT_THRESHOLD][PlantHyashiPetal] = 5
        @var[PLACEMENT_THRESHOLD][PlantShiWheat] = 5
        @var[PLACEMENT_THRESHOLD][PlantDominrose] = 5
        @var[PLACEMENT_THRESHOLD][PlantDomingrass] = 15
        
        base_score = 0
        
        enemy_thresholds = {}
        enemy_thresholds[Hyashi] = @var[PLACEMENT_THRESHOLD][PlantHyashiPetal]
        
        if Difficulty.get == Difficulty::EASY then
            enemy_thresholds[Shihog] = 5
            enemy_thresholds[Shipple] = 8
            enemy_thresholds[Shipike] = 0
            enemy_thresholds[Shitake] = 3
            enemy_thresholds[Moleshi] = 0
            enemy_thresholds[Chishi] = 5
            enemy_thresholds[Shibmarine] = 3
            enemy_thresholds[Sushi] = 0
            enemy_thresholds[Shibmarine_D] = 3
        elsif Difficulty.get == Difficulty::NORMAL then
            enemy_thresholds[Shihog] = 7
            enemy_thresholds[Shipple] = 10
            enemy_thresholds[Shipike] = 2
            enemy_thresholds[Shitake] = 5
            enemy_thresholds[Moleshi] = 0
            enemy_thresholds[Chishi] = 7
            enemy_thresholds[Shibmarine] = 5
            enemy_thresholds[Sushi] = 3
            enemy_thresholds[Shibmarine_D] = 5
        elsif Difficulty.get == Difficulty::HARD then
            enemy_thresholds[Shihog] = 10
            enemy_thresholds[Shipple] = 12
            enemy_thresholds[Shipike] = 3
            enemy_thresholds[Shitake] = 7
            enemy_thresholds[Moleshi] = 2
            enemy_thresholds[Chishi] = 10
            enemy_thresholds[Shibmarine] = 8
            enemy_thresholds[Sushi] = 5
            enemy_thresholds[Shibmarine_D] = 7
        elsif Difficulty.get == Difficulty::DOOM then
            enemy_thresholds[Shihog] = 12
            enemy_thresholds[Shipple] = 15
            enemy_thresholds[Shipike] = 5
            enemy_thresholds[Shitake] = 10
            enemy_thresholds[Moleshi] = 4
            enemy_thresholds[Chishi] = 15
            enemy_thresholds[Shibmarine] = 10
            enemy_thresholds[Sushi] = 7
            enemy_thresholds[Shibmarine_D] = 10
        end
        
        placed_items = {}
        enemy_counter = {}
        window.enemies.shuffle.each do |e|
            enemy_class = e.class
            e.stop_random_jumping
            e.force_reduction
            e.change_strength(1)
            e.force_minimal_damage
            if enemy_thresholds[enemy_class] then
                enemy_counter[enemy_class] = (enemy_counter[enemy_class] ? enemy_counter[enemy_class] + 1 : 0)
                if enemy_counter[enemy_class] > enemy_thresholds[enemy_class] then
                    e.damage(1000)
                elsif e.is_a?(Hyashi) then
                    e.set_drop(Objects::Plant_Hyashi_Petal, 1, -25)
                    e.set_custom_score(0)
                end
            end
        end
        
        temp_gems = []
        window.gems.shuffle.each do |g|
            if g.is_a?(MinigameToken) then
                tile_on = window.map.type(g.x, g.y)
                tile_down = window.map.type(g.x, g.y + 50)
                tile_up = window.map.type(g.x, g.y - 50)
                cl = nil
                if tile_down == Tiles::Tree
                    cl = PlantDominherb
                elsif tile_up == Tiles::Tree
                    cl = PlantDottery
                elsif tile_on == Tiles::Small_Grass
                    cl = PlantShiTreeSeed
                elsif tile_on == Tiles::Seaweed
                    cl = PlantDominweed
                elsif tile_down = Tiles::Stone
                    cl = PlantNautulip
                elsif tile_on == Tiles::Bush
                    cl = PlantNautaisy
                elsif tile_on == Tiles::Wheat
                    cl = PlantShiWheat
                elsif tile_down == Tiles::Water
                    cl = PlantDominrose
                elsif tile_down == Tiles::Dark_Grass
                    cl = Domingrass
                end
                next if !cl
                if placed_items[cl] then
                    if placed_items[cl] < @var[PLACEMENT_THRESHOLD][cl] then
                        c_index = Object_Datas::C_Index.index(cl)
                        v_img = window.valimgs[c_index]
                        temp_gems.push(cl.new(v_img, g.x, g.y))
                        placed_items[cl] += 1
                    end
                else
                    placed_items[cl] = 1
                    c_index = Object_Datas::C_Index.index(cl)
                    v_img = window.valimgs[c_index]
                    temp_gems.push(cl.new(v_img, g.x, g.y))
                end
            end
        end
        window.gems.reject! do |g|
            !(g.is_a?(MinigameToken))
        end
        temp_gems.each do |t|
            window.gems.push(t)
        end
    end
    
    def minigame_w_1(window, inuhh)
        if @timer == @var[LAST_TIMER] + @var[RAND_TIMER] && @var[SHIREEN_POS] + 20*50 < @var[MAX_X] then
            amount = rand(1 + (@var[SHIREEN_POS] / 100.0 / 50.0).to_i) + 1
            coords = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            [amount, 8].min.times do
                ycoord = coords.sample
                coords.delete(ycoord)
                e = window.spawn_enemy(@var[ENEMY_LIST].sample, @var[SHIREEN_POS] + 20*50, ycoord*50, :left)
                e.set_infinite_range
                e.force_minimal_damage
                e.force_reduction
                @var[ENEMIES].push(e)
            end
            @var[LAST_TIMER] += @var[0]
            @var[RAND_TIMER] = 30 + rand(100 - (@var[SHIREEN_POS] / 20.0 / 50.0).to_i)
        end
        if @timer % 1000 == 0 then
            @var[ENEMY_LIST].push(@var[ALL_ENEMIES].sample)
        end
        if rand(2000) == 0 && @var[SHIREEN_POS] + 20*50 < @var[MAX_X] then
            create_collectible(window, Objects::Sapphire, @var[SHIREEN_POS] + 20*50, rand(10)*50 + 25)
        end
        if @timer == 100 then
            1.upto(10) do |i|
                @var[SHIREENS].push(window.spawn_enemy(Enemies::Shireen, 25, i*50, :right))
                @var[SHIREENS_FRONT].push(window.spawn_enemy(Enemies::Shireen, 12*50 + 25, i*50, :right))
            end
        end
        @var[SHIREEN_POS] = @var[SHIREENS][0].x if @var[SHIREENS][0]
        @var[ENEMIES].reject! do |e|
            if @var[SHIREEN_POS] - 25 - 300 > e.x + e.xsize then
                e.damage(1000)
                true
            else
                false
            end
        end
        @var[SHIREENS_FRONT].each {|e| e.damage(1000) if e.x >= 998*50.0}
    end
    
    def minigame_w_2(window, inuhh)
        
    end
    
    def draw
        @image.draw(@x-25, @y-25, ZOrder::Gems) if EDITOR
    end
    
end

class CollectibleSapphire < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = 20000
        @own_sound = true
    end
    
    def play_collected_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("gem", 1, 0.9+rand*0.2)
    end
    
    def draw
        # Draw, slowly rotating
        @image.draw_rot(@x, @y, ZOrder::Gems, 25 * Math.sin(milliseconds / 133.7))
    end
    
end

class MinigameGoal < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = 0
        @own_sound = true
    end
    
    def play_collected_sound(window, inuhh)
        super(window, inuhh)
        window.play_sound("gem", 1, 0.9+rand*0.2)  #TODO
    end
    
    def draw
        @image.draw(@x-25, @y - 25 + 10 * Math.sin(milliseconds / 133.7), ZOrder::Gems)
    end
    
    def collect(window, inuhh)
        @score = 1250000*window.minigame_lifes
        super(window, inuhh)
        window.play_song("fanfare 1")
        window.exit_minigame
    end
    
end

class MinigameToken < Collectible
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = nil
        @own_sound = true
        @constant = true
    end
    
    def draw
        @image.draw(@x-25, @y-25, ZOrder::Gems) if EDITOR
    end
    
end

class Plant < Collectible # No real object!
    
    def initialize(image, x, y)
        @own_sound = true
        super(image, x, y)
    end
    
    def collect(window, inuhh)
        window.gems.each do |g|
            if g.is_a?(MinigameObserver) then
                vars = g.var[MinigameObserver::COLLECTED_ITEMS]
                if vars[self.class] then
                    vars[self.class] += 1
                else
                    vars[self.class] = 1
                end
                break
            end
        end
        super(window, inuhh)
    end
    
end

class PlantDominherb < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Dominherb"
    end
    
end

class PlantDottery < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Dottery"
    end
    
end

class PlantShiTreeSeed < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Shi Tree Seeds"
    end
    
end

class PlantDominweed < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Dominweed"
    end
    
end

class PlantNautulip < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Nautulip"
    end
    
end

class PlantNautaisy < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Nautaisy"
    end
    
end

class PlantHyashiPetal < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Hyashi Petals"
    end
    
end

class PlantShiWheat < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Shi Wheat"
    end
    
end

class PlantDominrose < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Dominrose"
    end
    
end

class PlantDomingrass < Plant
    
    def initialize(image, x, y)
        super(image, x, y)
        @score = "Domingrass"
    end
    
end

module Objects
    
    Coin = 0
    Gem = 1
    Shi_Coin = 2
    Bone = 3
    Wing = 4
    Hedgehound = 5
    Pedestal = 6
    Shistol = 7
    Fruit = 8
    Mysteriorb = 9
    Compass = 10
    Drips = 11
    Boots = 12
    Sand = 13
    Key = 14
    Shizooka = 15
    Gold_Bone = 16
    Shistol_Plus = 17
    Shinegun = 18
    Shinegun_Plus = 19
    Flippers = 20
    Ultra_Bone = 21
    Bat = 22
    Ball = 23
    Magic_Lamp = 24
    Warning = 25
    Minigame_Observer = 26
    Sapphire = 27
    Minigame_Goal = 28
    Minigame_Token = 29
    Plant_Dominherb = 30
    Plant_Dottery = 31
    Plant_Shi_Tree_Seed = 32
    Plant_Dominweed = 33
    Plant_Nautulip = 34
    Plant_Nautaisy = 35
    Plant_Hyashi_Petal = 36
    Plant_Shi_Wheat = 37
    Plant_Dominrose = 38
    Plant_Domingrass = 39
    
end

module Object_Datas
    
    Object_Void = Object_Data.new
    
    Object_Coin = Object_Data.new(Objects::Coin) # 0
    Object_Gem = Object_Data.new(Objects::Gem) # 1
    Object_Shi_Coin = Object_Data.new(Objects::Shi_Coin) # 2
    Object_Bone = Object_Data.new(Objects::Bone) # 3
    Object_Wing = Object_Data.new(Objects::Wing) # 4
    Object_Hedgehound = Object_Data.new(Objects::Hedgehound) # 5
    Object_Pedestal = Object_Data.new(Objects::Pedestal) # 6
    Object_Shistol = Object_Data.new(Objects::Shistol) # 7
    Object_Fruit = Object_Data.new(Objects::Fruit) # 8
    Object_Mysteriorb = Object_Data.new(Objects::Mysteriorb) # 9
    Object_Compass = Object_Data.new(Objects::Compass) # 10
    Object_Drips = Object_Data.new(Objects::Drips) # 11
    Object_Boots = Object_Data.new(Objects::Boots) # 12
    Object_Sand = Object_Data.new(Objects::Sand) # 13
    Object_Key = Object_Data.new(Objects::Key) # 14
    Object_Shizooka = Object_Data.new(Objects::Shizooka) # 15
    Object_Gold_Bone = Object_Data.new(Objects::Gold_Bone) # 16
    Object_Shistol_Plus = Object_Data.new(Objects::Shistol_Plus) # 17
    Object_Shinegun = Object_Data.new(Objects::Shinegun) # 18
    Object_Shinegun_Plus = Object_Data.new(Objects::Shinegun_Plus) # 19
    Object_Flippers = Object_Data.new(Objects::Flippers) # 20
    Object_Ultra_Bone = Object_Data.new(Objects::Ultra_Bone) # 21
    Object_Bat = Object_Data.new(Objects::Bat) # 22
    Object_Ball = Object_Data.new(Objects::Ball) # 23
    Object_Magic_Lamp = Object_Data.new(Objects::Magic_Lamp) # 24
    Object_Warning = Object_Data.new(Objects::Warning) # 25
    Object_Minigame_Observer = Object_Data.new(Objects::Minigame_Observer) # 26
    Object_Sapphire = Object_Data.new(Objects::Sapphire) # 27
    Object_Minigame_Goal = Object_Data.new(Objects::Minigame_Goal) # 28
    Object_Minigame_Token = Object_Data.new(Objects::Minigame_Token) # 29
    Object_Plant_Dominherb = Object_Data.new(Objects::Plant_Dominherb) # 30
    Object_Plant_Dottery = Object_Data.new(Objects::Plant_Dottery) # 31
    Object_Plant_Shi_Tree_Seed = Object_Data.new(Objects::Plant_Shi_Tree_Seed) # 32
    Object_Plant_Dominweed = Object_Data.new(Objects::Plant_Dominweed) # 33
    Object_Plant_Nautulip = Object_Data.new(Objects::Plant_Nautulip) # 34
    Object_Plant_Nautaisy = Object_Data.new(Objects::Plant_Nautaisy) # 35
    Object_Plant_Hyashi_Petal = Object_Data.new(Objects::Plant_Hyashi_Petal) # 36
    Object_Plant_Shi_Wheat = Object_Data.new(Objects::Plant_Shi_Wheat) # 37
    Object_Plant_Dominrose = Object_Data.new(Objects::Plant_Dominrose) # 38
    Object_Plant_Domingrass = Object_Data.new(Objects::Plant_Domingrass) # 39
    
    Index = [Object_Coin, Object_Gem, Object_Shi_Coin, Object_Bone, Object_Wing, Object_Hedgehound, Object_Pedestal, Object_Shistol, Object_Fruit, Object_Mysteriorb,
             Object_Compass, Object_Drips, Object_Boots, Object_Sand, Object_Key, Object_Shizooka, Object_Gold_Bone, Object_Shistol_Plus, Object_Shinegun,
             Object_Shinegun_Plus, Object_Flippers, Object_Ultra_Bone, Object_Bat, Object_Ball, Object_Magic_Lamp, Object_Warning, Object_Minigame_Observer,
             Object_Sapphire, Object_Minigame_Goal, Object_Minigame_Token, Object_Plant_Dominherb, Object_Plant_Dottery, Object_Plant_Shi_Tree_Seed, Object_Plant_Dominweed,
             Object_Plant_Nautulip, Object_Plant_Nautaisy, Object_Plant_Hyashi_Petal, Object_Plant_Shi_Wheat, Object_Plant_Dominrose, Object_Plant_Domingrass]
    C_Index = [CollectibleCoin, CollectibleGem, CollectibleShiCoin, CollectibleBone, CollectibleWing, NPCHedgehound, CollectiblePedestal, CollectibleShistol,
               CollectibleFruit, CollectibleMysteriorb, CollectibleCompass, DecorationDrips, CollectibleBoots, CollectibleSand, CollectibleKey, CollectibleShizooka,
               CollectibleGoldBone, CollectibleShistolPlus, CollectibleShinegun, CollectibleShinegunPlus, CollectibleFlippers, CollectibleUltraBone, CollectibleBat,
               CollectibleBall, CollectibleMagicLamp, DecorationWarning, MinigameObserver, CollectibleSapphire, MinigameGoal, MinigameToken, PlantDominherb, PlantDottery,
               PlantShiTreeSeed, PlantDominweed, PlantNautulip, PlantNautaisy, PlantHyashiPetal, PlantShiWheat, PlantDominrose, PlantDomingrass]
    N_Index = ["Coin", "Gem", "Shi_Coin", "Bone", "Wing", "Hedgehound", "Pedestal", "Shistol", "Fruit", "Mysteriorb", "Compass Piece", "Drips", "Boots", "Sand", "Key",
               "Shizooka", "Gold Bone", "Shistol Plus", "Shinegun", "Shinegun Plus", "Flippers", "Ultra Bone", "Bat", "Ball", "Magic Lamp", "Warning", "Minigame Observer",
               "Sapphire", "Minigame Goal", "Minigame Token", "Dominherb", "Dottery", "Shi Tree Seeds", "Dominweed", "Nautulip", "Nautaisy", "Hyashi Petals", "Shi Wheat",
               "Dominrose", "Domingrass"]
    
end
