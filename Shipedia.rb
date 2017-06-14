$LOAD_PATH << "."

require 'rubygems'
require 'gosu'

include Gosu

require "lib/Level.rb"

EDITOR = false
SHIPEDIA = true

module ZOrder
    
    Background, Pics, UI = *0..2
    
end

class StdTextField < TextInput
    
    def initialize(window, font, x, y, start_text, color, size, input)
        super()
        @window, @font, @x, @y = window, font, x, y
        self.text = start_text
        @color = color
        @init_color = color
        @size = size
        @input = input
    end
    
    def filter(text)
        return text
        # Return filters for text here
    end
    
    def change_color(col)
        @color = col
    end
    
    def reset_color
        @color =  @init_color
    end
    
    def draw
        pos_x = @x + @font.text_width(@input, @size) + @font.text_width(self.text[0...self.caret_pos], @size)
        @window.draw_line(pos_x, @y, @color, pos_x, @y + @size*20, @color, 0) if milliseconds % 1000 < 500
        @font.draw(@input + self.text, @x, @y, ZOrder::UI, @size, @size, @color)
    end
    
end

class Shipedia < Window
    
    attr_reader :map
    
    TEXT_COLOR = 0xff000000
    DISABLED_COLOR = 0xffaaaaaa
    
    FRONT = 0
    LEFT = 1
    
    SORT_NAME = "SORT NAME"
    SORT_STRENGTH = "SORT STRENGTH"
    SORT_DEFENSE = "SORT DEFENSE"
    SORT_HP = "SORT HP"
    SORT_SPEED = "SORT SPEED"
    SORT_WORLD = "SORT WORLD"
    SORT_SCORE = "SORT SCORE"
    SORT_SIZE = "SORT SIZE"
    DIFF_EASY = "DIFF EASY"
    DIFF_NORMAL = "DIFF NORMAL"
    DIFF_HARD = "DIFF HARD"
    DIFF_DOOM = "DIFF DOOM"
    
    def initialize
        super(640, 480, false)
        self.caption = "Inuhh Shinvasion - Shipedia"
        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
        @input = StdTextField.new(self, @font, 0, 0, "", 0xff3399ff, 1.0, "Enemy name: ")
        Difficulty.set(Difficulty::NORMAL)
        self.text_input = @input
        @found_enemy = nil
        @map = nil
        @img = FRONT
        @shift = 0
        @smax = 0
        @tempsort = []
        @worlds = [0]
        @sort = SORT_NAME
        @valimgs = Image.load_tiles("media/game/Objects.png", 50, 50, tileable: true)
        @bg = Image.new("media/shipedia/Standard.png", tileable: true)
        @mainbg = Image.new("media/shipedia/Standard.png", tileable: true)
        init_enemies
    end
    
    def init_enemies
        @enemies = []
        0.upto(Enemy_Datas.i_index.size-1) do |i|
            @enemies[i] = Enemy_Datas.c_index[i].new(self, 0, 0, :left)
        end
    end
    
    def draw
        @font.draw("Difficulty: " + ["Easy", "Normal", "Hard", "Doom"][Difficulty.get], 5, 455, ZOrder::UI, 1.0, 1.0, 0xffff0000)
        if !@found_enemy then
            @mainbg.draw(0, 0, ZOrder::Background)
            @input.draw
            c = 0
            datas = Enemy_Datas.n_index.select{|i| @worlds.index(@enemies[Enemy_Datas.n_index.index(i)].world)}
            @smax = (datas.size/20).to_i*150
            if @sort == SORT_NAME then
                @tempsort = datas.sort
            elsif @sort == SORT_STRENGTH then
                @tempsort = datas.sort{|a,b| [@enemies[Enemy_Datas.n_index.index(b)].strength, a] <=> [@enemies[Enemy_Datas.n_index.index(a)].strength, b]}
            elsif @sort == SORT_DEFENSE then
                @tempsort = datas.sort{|a,b| [@enemies[Enemy_Datas.n_index.index(b)].defense, a] <=> [@enemies[Enemy_Datas.n_index.index(a)].defense, b]}
            elsif @sort == SORT_HP then
                @tempsort = datas.sort{|a,b| [@enemies[Enemy_Datas.n_index.index(b)].hp, a] <=> [@enemies[Enemy_Datas.n_index.index(a)].hp, b]}
            elsif @sort == SORT_SPEED then
                @tempsort = datas.sort{|a,b| [@enemies[Enemy_Datas.n_index.index(b)].speed, a] <=> [@enemies[Enemy_Datas.n_index.index(a)].speed, b]}
            elsif @sort == SORT_SCORE then
                @tempsort = datas.sort{|a,b| [@enemies[Enemy_Datas.n_index.index(b)].score, a] <=> [@enemies[Enemy_Datas.n_index.index(a)].score, b]}
            elsif @sort == SORT_SIZE then
                @tempsort = datas.sort{|a,b| [@enemies[Enemy_Datas.n_index.index(b)].xsize*(@enemies[Enemy_Datas.n_index.index(b)].ysize), a] <=> [@enemies[Enemy_Datas.n_index.index(a)].xsize*(@enemies[Enemy_Datas.n_index.index(a)].ysize), b]}
            elsif @sort == SORT_WORLD then
                @tempsort = datas.sort{|a,b| [@enemies[Enemy_Datas.n_index.index(b)].world, a] <=> [@enemies[Enemy_Datas.n_index.index(a)].world, b]}
            end
            @tempsort.each do |e|
                n_ind = Enemy_Datas.n_index.index(e)
                enemy = @enemies[n_ind]
                next if e.upcase.index(@input.text.upcase) != 0
                @font.draw(e, 20+(c/20).to_i*150+@shift, (c*20)%400+40, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)
                enemy.standing.draw((c/20).to_i*150+@shift, (c*20)%400+40, ZOrder::Pics, 10.0/enemy.xsize, 10.0/enemy.ysize)
                c += 1
            end
        else
            @bg.draw(0, 0, ZOrder::Background)
            xpos = [0, 100-@found_enemy.xsize].max
            ypos = [0, 100-@found_enemy.ysize].max
            xzoom = (@found_enemy.xsize > 100 ? 100.0/@found_enemy.xsize : 1.0)
            yzoom = (@found_enemy.ysize > 100 ? 100.0/@found_enemy.ysize : 1.0)
            attribs = ""
            if @img == FRONT then
                @found_enemy.standing.draw(xpos, ypos, ZOrder::Pics, xzoom, yzoom)
            elsif @img == LEFT
                @found_enemy.walk1.draw(xpos, ypos, ZOrder::Pics, xzoom, yzoom)
            end
            @font.draw(Enemy_Datas.n_index[Enemy_Datas.c_index.index(@found_enemy.class)], 210, 10, ZOrder::UI, 2.0, 2.0, TEXT_COLOR)
            @font.draw("HP:", 210, 50, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)
            @font.draw("STRENGTH:", 210, 70, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)
            @font.draw("DEFENSE:", 210, 90, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)
            @font.draw("SPEED:", 210, 110, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)
            @font.draw("SCORE:", 210, 130, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)
            @font.draw("LEVEL:", 210, 150, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)
            @font.draw(@found_enemy.hp, 320, 50, ZOrder::UI, 1.0, 1.0, 0xff0000ff)
            sstring = @found_enemy.strength.to_s
            sstring += (" / " + @found_enemy.mindamage.to_s) if @found_enemy.mindamage
            @font.draw(sstring, 320, 70, ZOrder::UI, 1.0, 1.0, 0xff00ff00)
            dstring = @found_enemy.defense.to_s
            dstring += (" / " + @found_enemy.reduction.to_s) if @found_enemy.reduction
            @font.draw(dstring, 320, 90, ZOrder::UI, 1.0, 1.0, 0xff00ff00)
            @font.draw(@found_enemy.speed, 320, 110, ZOrder::UI, 1.0, 1.0, 0xff00ff00)
            @font.draw(@found_enemy.score, 320, 130, ZOrder::UI, 1.0, 1.0, 0xffff0000)
            @font.draw((@found_enemy.score < 5000 ? 1 : (@found_enemy.score < 10000 ? 2 : 3)), 320, 150, ZOrder::UI, 1.0, 1.0, 0xffff0000)
            @font.draw("WATERPROOF", 450, 50, ZOrder::UI, 1.0, 1.0, (@found_enemy.waterproof ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("HUNTING", 450, 70, ZOrder::UI, 1.0, 1.0, (@found_enemy.hunting ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("BOSS", 450, 90, ZOrder::UI, 1.0, 1.0, (@found_enemy.boss ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("FLOATING", 450, 110, ZOrder::UI, 1.0, 1.0, (!@found_enemy.gravity ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("SHOOTING", 450, 130, ZOrder::UI, 1.0, 1.0, (@found_enemy.projectile ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("INVISIBLE", 450, 150, ZOrder::UI, 1.0, 1.0, (@found_enemy.invisible ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("PROTECTED", 450, 170, ZOrder::UI, 1.0, 1.0, (@found_enemy.spike ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("KNOCKBACK", 450, 190, ZOrder::UI, 1.0, 1.0, (@found_enemy.knockback > 0 ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("GHOSTLIKE", 450, 210, ZOrder::UI, 1.0, 1.0, (@found_enemy.through ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("SHICIDAL", 450, 230, ZOrder::UI, 1.0, 1.0, (@found_enemy.havoc ? TEXT_COLOR : DISABLED_COLOR))
            @font.draw("DROPS:", 20, 220, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)
            if @found_enemy.drop then
                @valimgs[@found_enemy.drop].draw(20, 255, ZOrder::Pics)
                
                @font.draw(Object_Datas::N_Index[@found_enemy.drop], 100, 270, ZOrder::UI, 1.0, 1.0, 0xff990099)
            else
                @font.draw("NONE", 20, 240, ZOrder::UI, 1.0, 1.0, DISABLED_COLOR)
            end
            c = 0
            @found_enemy.description.split("\n").each do |t|
                @font.draw(t.strip, 20, 320+c*20, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)
                c += 1
            end
        end
    end
    
    def reset
        @found_enemy = nil
        self.text_input = @input
    end
    
    def update
        
    end
    
    def button_down(id)
        if id == KbEscape || (id == KbBackspace && @found_enemy) then
            if @found_enemy then
                reset
            else
                close
            end
        end
        if @found_enemy then
            if id == KbLeft || id == KbDown then
                @img = LEFT
            end
            if id == KbRight || id == KbUp then
                @img = FRONT
            end
            if id == KbD then
                @found_enemy = @enemies[Enemy_Datas.n_index.index(@tempsort[(@tempsort.index(Enemy_Datas.n_index[@enemies.index(@found_enemy)]) + 1) % @tempsort.size])]
            end
            if id == KbA then
                @found_enemy = @enemies[Enemy_Datas.n_index.index(@tempsort[(@tempsort.index(Enemy_Datas.n_index[@enemies.index(@found_enemy)]) - 1) % @tempsort.size])]
            end
        else
            if id == MsWheelDown then
                @shift -= 50
                @shift = -@smax if @shift < -@smax
            end
            if id == MsWheelUp then
                @shift += 50
                @shift = 0 if @shift > 0
            end
        end
        if id == KbTab && !@found_enemy then
            choice = nil
            use_choice = true
            Enemy_Datas.n_index.each do |e|
                next unless @worlds.index(@enemies[Enemy_Datas.n_index.index(e)].world)
                next if e.upcase.index(@input.text.upcase) != 0
                if choice then
                    use_choice = false
                else
                    choice = e
                end
            end
            @input.text = choice if use_choice
        end
        if id == KbReturn && !@found_enemy then
            if @input.text.upcase == PASSWORD_WORLD_1 then
                @worlds.push(1) if !@worlds.index(1)
            elsif @input.text.upcase == PASSWORD_WORLD_2 then
                @worlds.push(1) if !@worlds.index(1)
                @worlds.push(2) if !@worlds.index(2)
            elsif @input.text.upcase == PASSWORD_WORLD_3 then
                @worlds.push(1) if !@worlds.index(1)
                @worlds.push(2) if !@worlds.index(2)
                @worlds.push(3) if !@worlds.index(3)
            elsif @input.text.upcase == PASSWORD_WORLD_4 then
                @worlds.push(1) if !@worlds.index(1)
                @worlds.push(2) if !@worlds.index(2)
                @worlds.push(3) if !@worlds.index(3)
                @worlds.push(4) if !@worlds.index(4)
            elsif @input.text.upcase == PASSWORD_WORLD_5 then
                @worlds.push(1) if !@worlds.index(1)
                @worlds.push(2) if !@worlds.index(2)
                @worlds.push(3) if !@worlds.index(3)
                @worlds.push(4) if !@worlds.index(4)
                @worlds.push(5) if !@worlds.index(5)
            elsif @input.text.upcase == "DEBUG" && Debug::ON then
                @worlds = [-1, 0, 1, 2, 3, 4, 5, 6]
            elsif @input.text.upcase == SORT_NAME then
                @sort = SORT_NAME
            elsif @input.text.upcase == SORT_STRENGTH then
                @sort = SORT_STRENGTH
            elsif @input.text.upcase == SORT_DEFENSE then
                @sort = SORT_DEFENSE
            elsif @input.text.upcase == SORT_HP then
                @sort = SORT_HP
            elsif @input.text.upcase == SORT_SIZE then
                @sort = SORT_SIZE
            elsif @input.text.upcase == SORT_SPEED then
                @sort = SORT_SPEED
            elsif @input.text.upcase == SORT_SCORE then
                @sort = SORT_SCORE
            elsif @input.text.upcase == SORT_WORLD then
                @sort = SORT_WORLD
            elsif @input.text.upcase == DIFF_EASY then
                Difficulty.set(Difficulty::EASY)
                init_enemies
            elsif @input.text.upcase == DIFF_NORMAL then
                Difficulty.set(Difficulty::NORMAL)
                init_enemies
            elsif @input.text.upcase == DIFF_HARD then
                Difficulty.set(Difficulty::HARD)
                init_enemies
            elsif @input.text.upcase == DIFF_DOOM then
                Difficulty.set(Difficulty::DOOM)
                init_enemies
            else
                Enemy_Datas.n_index.each do |e|
                    next unless @worlds.index(@enemies[Enemy_Datas.n_index.index(e)].world)
                    self.text_input = nil if e.upcase == @input.text.upcase
                    @found_enemy = @enemies[Enemy_Datas.n_index.index(e)] if e.upcase == @input.text.upcase
                end
            end
        end
    end
    
end

begin
    
    Shipedia.new.show
    
rescue Exception => exc
    
    f = File.open("log.txt", "a")
    f.puts "Error in Shipedia.rb at #{Time.now}:"
    f.puts exc.inspect
    f.puts exc.backtrace
    f.puts ""
    f.close
    raise exc
    
end
