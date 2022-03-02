class Projectile < Entity
  attr_reader :broken, :owner, :type, :x, :y, :vx, :vy
  attr_accessor :damage
  
  def initialize(type, x, y, vx, vy, ax, ay, owner, lifetime, damage, window, image, silent=false)
      super()
      @type = type
      @xsize, @ysize = Projectiles::XSizes[type], Projectiles::YSizes[type]
      @x, @y = x, y+2*@ysize
      @vx, @vy = vx, vy
      @ax, @ay = ax, ay
      @ax0 = ax
      @ay0 = ay
      @owner = owner
      @destruction = Projectiles::Destruction[type]
      @drop = Projectiles::Drops[type]
      @lifetime = lifetime
      @damage = damage
      @window = window
      @map = @window.map
      @image = image
      if (@window.inuhh.x - @x).abs < 500 && (@window.inuhh.y - @y).abs < 400 && !silent then
          @window.play_sound(Projectiles::Sounds[type], 1, 0.9+rand*0.2)
      end
  end
  
  def break # Please do not use it private... causes are obvious. Rename could fix this.
      return if @broken
      @broken = true
      @window.gems.push(Object_Datas::C_Index[@drop].new(@window.valimgs[@drop], @x, @y)) if @drop
  end
  
  def destroy
      @drop = nil
      @broken = true
  end
  
  def break_particle # Better use this
      return if @broken
      @broken = true
      @window.gems.push(Object_Datas::C_Index[@drop].new(@window.valimgs[@drop], @x, @y)) if @drop
  end
  
  def check_enemies
      @window.enemies.each do |e|
          if @owner != Projectiles::ENEMY && Collider.test_collision(self, e) then
              hit = e.at_shot(self)
              dv = [@damage - e.defense, 0].max + Projectiles::Shi_Plus[@type]
              dv = 0 if !hit
              dv = 0 if e.bulletproof
              dv = 0 if e.waterproof && @type == Projectiles::Water
              if !e.waterproof || @type != Projectiles::Water then
                  #@x >= e.x ? e.force_knockback(-10-dv) : e.force_knockback(10+dv)
                  @vx > 0 ? e.force_knockback(10+dv) : e.force_knockback(-10-dv)
              end
              dv = e.reduction if e.reduction && dv > e.reduction
              if e.invul == 0 then
                  e.damage(dv)
                  @window.messages.push([dv, e.x-e.xsize+10, e.y-e.ysize-30, 20, true, 2.0+(dv-1)/30.0, 2.0+(dv-1)/30.0, 0xff00ff00]) if (!e.waterproof || @type != Projectiles::Water)
              end
              @damage = 0
              if @owner == Projectiles::INUHH then
                  if !e.living then
                      value = e.score
                      @window.messages.push([value, e.x-e.xsize, e.y-e.ysize, 100, true, 2.0+(value/50000.0), 2.0+(value/50000.0), 0xffffff00])
                      @window.inuhh.increase_stat(Stats::Score, value)
                      @window.play_sound("smash")
                      @window.residues.push(Residuum.new(e.x-e.xsize, e.y-2*e.ysize, (e.boss ? 200 : 50), @window, e.mud))
                  end
              end
              @broken = true if !@destruction || @damage == 0
          end
      end
  end
  
  def would_fit(offs_x, offs_y) # Automatically destroys projectiles and map tiles
      expr = true
      return would_fit_maxi(offs_x, offs_y) if @xsize >= 25 || @ysize >= 25
      sx = @xsize
      sy = @ysize
      0.upto((@ysize/sy).floor) do |t|
          ((-@xsize/(2*sx))+1).floor.upto((@xsize/(2*sx)).floor) do |u|
              edge_y = t == 0 ? 0 : 1
              edge_x = 0
              rx = @x + offs_x + sx - (@xsize>25 ? 25 : 0) + u*2*sx - edge_x
              ry = @y + offs_y - 2*sy*(t) + edge_y
              expr &&= !@map.solid?(rx, ry)
              expr &&= !@map.solid?(rx+1, ry)
              test_wall(rx, ry)
              test_wall(rx+1, ry)
          end
      end
      return expr
  end
  
  def would_fit_maxi(offs_x, offs_y)
      # Check at the center/top and center/bottom for map collisions
      expr = true
      0.upto((@ysize/25).floor) do |t|
          ((-@xsize/50)+1).floor.upto((@xsize/50).floor) do |u|
              edge_y = t == 0 ? 0 : 1
              edge_x = 0
              rx = @x + offs_x + 25 - (@xsize>25 ? 25 : 0) + u*50 - edge_x
              ry = @y + offs_y - 50*(t) + edge_y
              expr &&= !@map.solid?(rx, ry)
              expr &&= !@map.solid?(rx - 49, ry)
              test_wall(rx, ry)
              test_wall(rx - 49, ry)
          end
      end
      return expr
  end
  
  def test_wall(nx, ny)
      if @map.solid?(nx, ny) then
          if !@map.bulletproof(nx, ny) || @destruction then
              @window.add_tile(nx, ny, nil)
              @window.play_sound("detonation", 1, 1.3) if !@destruction || rand(100) == 0
              @damage -= 1
          end
          break_particle if !@destruction || @damage == 0
      end
  end
  
  def update
      if @type == Projectiles::Homing then
          @ax = (@window.inuhh.x < @x ? -1.0 : 1.0)*@ax0
          @ay = (@window.inuhh.y < @y ? -1.0 : 1.0)*@ay0
      end
      @vx += @ax
      @vy += @ay
      if would_fit(@vx, @vy) then
          @x += @vx
          @y += @vy
      end
      @lifetime -= 1 if @lifetime
      break_particle if @lifetime && @lifetime <= 0
      break_particle if @damage <= 0
      check_enemies
  end
  
  def draw
      return if @broken
      if @vx <= 0 then
          offs_x = -@xsize
          factor = 1.0
      else
          offs_x = @xsize
          factor = -1.0
      end
      @image.draw(@x + offs_x - factor, @y - @ysize*2 + 1 - factor, ZOrder::Foreground, factor, 1.0)
  end
  
end