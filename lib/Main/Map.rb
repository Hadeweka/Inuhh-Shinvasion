# Map class holds and draws tiles and gems.
class Map
  attr_reader :width, :height, :gems, :initial_enemies, :player_yield, :warps, :spawners, :triggers, :signposts, :tileset, :warp_imgs

  def initialize(window, filename, section)
    # Load 60x60 tiles, 5px overlap in all four directions.
    @window = window
    @tileset = Image.load_tiles(Pics::Tileset, 60, 60, tileable: true)
    @anim_tileset = Image.load_tiles(Pics::Anim_Tileset, 60, 60, tileable: true)
    @valimgs = Image.load_tiles(Pics::Objects, 50, 50, tileable: true)
    warp_img = Image.new(Pics::Warp, tileable: true)
    final_warp_img = Image.new(Pics::Final, tileable: true)
    secret_warp_img = Image.new(Pics::Secret, tileable: true)

    @warp_imgs = [warp_img, final_warp_img, secret_warp_img]

    signpost_img = Image.new(Pics::Signpost, tileable: true)

    @gems = []

    #filename = "test.iwf"
    lines = File.readlines(filename).map {|line| line.chomp}
    f = File.open(filename, "r")
    @check = Marshal.load(f)
    while @check != section do
      @check = Marshal.load(f)
    end
    first = Marshal.load(f)
    if first.is_a? String then
      @version = first
      @width = Marshal.load(f)
    else
      @width = first
    end
    @height = Marshal.load(f)

    @initial_enemies = []
    @player_yield = []

    @spawners = []
    @triggers = []
    @signposts = []
    @warps = []

    @tiles = []
    @ftiles = []

    0.upto(@width-1) do |x|
      @tiles[x] = []
      @ftiles[x] = []
    end
    0.upto(@width-1) do |x|
      0.upto(@height-1) do |y|
        d = Marshal.load(f)
        if d.is_a? Array then # Custom behaviour tiles will follow soon.
          @tiles[d[0]][d[1]]=d[2].tile
        else
          add_tile(x, y, d)
        end
      end
    end
    pinp = Marshal.load(f)
    @player_yield = [pinp[0] * 50 + 25, pinp[1] * 50 + 49, pinp[2]]
    inp = Marshal.load(f)
    while inp != "END" do
      if inp[3] == "G" then
        @gems.push(Object_Datas::C_Index[inp[2].type].new(@valimgs[inp[2].type], inp[0] * 50 + 25, inp[1] * 50 + 25))
      elsif inp[3] == "E" then
        if inp[2].is_a? Integer then
          dirs = [:right, :left]
          @initial_enemies.push([inp[0] * 50 + 25, inp[1] * 50 + 49, inp[2], dirs[inp[4]], inp[5]])
        else # Old format, only for compability
          @initial_enemies.push([inp[0] * 50 + 25, inp[1] * 50 + 49, inp[2].type, inp[4]])
        end
      elsif inp[3] == "W" then
        if inp[2].is_a? Array then
          dest = inp[2].join
          warppic = (dest[0] == "!" ? (!Level::Story.index((dest[1..-1].split("-"))[0..1].join("-")) ? secret_warp_img : final_warp_img) : warp_img)
          @warps.push(Warp.new(warppic, inp[0] * 50 + 25, inp[1] * 50 + 49, dest))
        else # Old format, not supported anymore.
          @warps.push(Warp.new((inp[2].destination[0] == "!" ? final_warp_img : warp_img), inp[0] * 50 + 25, inp[1] * 50 + 49, inp[2].destination))
        end
      elsif inp[3] == "S" then
        @spawners.push([inp[0] * 50, inp[1] * 50, inp[2], inp[4], inp[5], inp[6], inp[7], inp[8]])
      elsif inp[3] == "P" then
        @signposts.push([inp[0] * 50, inp[1] * 50, inp[2]])
      elsif inp[3] == "F" then
        add_fg_tile(inp[0], inp[1], inp[2])
      end
      inp = Marshal.load(f)
    end
    f.close
  end

  def add_tile(x, y, tile)
    @tiles[x][y] = tile
  end

  def add_fg_tile(x, y, tile)
    @ftiles[x][y] = tile
  end

  def draw(camx, camy)
    # Very primitive drawing function:
    # Draws all the tiles, some off-screen, some on-screen.
    (camx..camx+15).each do |x|
      if @tiles[x] then
        (camy..camy+10).each do |y|
          tile = @tiles[x][y]
          if tile then
            anim = Tile_Datas::Index[tile].animation
            # Draw the tile with an offset (tile images have some overlap)
            # Scrolling is implemented here just as in the game objects.
            if anim && (milliseconds+x*100-y*77) % 1000> 500 then
              @anim_tileset[tile].draw(x * 50 - 5, y * 50 - 5, ZOrder::Tiles)
            else
              @tileset[tile].draw(x * 50 - 5, y * 50 - 5, ZOrder::Tiles)
            end
          end
          if @ftiles[x][y] then
            @tileset[@ftiles[x][y]].draw(x * 50, y * 50 - 5, ZOrder::Foreground)
          end
        end
      end
    end
  end

  # Solid at a given pixel position?
  def solid?(x, y)
    return true if x < 0 || y < 0 || x >= @width*50
    return false if !@tiles[(x / 50).floor][(y / 50).floor]
    return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].solid
  end

  def keyhole(x, y)
    return false if invalid(x, y)
    return false if !@tiles[(x / 50).floor][(y / 50).floor]
    return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].tile == Tiles::Keyhole
  end

  def invalid(x, y)
    return true if x < 0 || y < 0 || x >= @width*50 || y >= @height*50
  end

  def lethal(x, y)
    return true if y > @height*50+50
    return false if invalid(x, y)
    return false if !@tiles[(x / 50).floor][(y / 50).floor]
    return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].lethal
  end

  def water(x, y, shi_friendly=false)
    return false if invalid(x, y)
    return false if !@tiles[(x / 50).floor][(y / 50).floor]
    return false if shi_friendly && Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].tile == Tiles::Shi_Water
    return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].water
  end

  def poison(x, y)
    return false if !@tiles[(x / 50).floor][(y / 50).floor]
    return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].tile == Tiles::Poison
  end

  def bulletproof(x, y)
    return true if invalid(x, y)
    return true if !@tiles[(x / 50).floor][(y / 50).floor]
    return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].bulletproof
  end

  def ice(x, y)
    return false if invalid(x, y)
    return false if !@tiles[(x / 50).floor][(y / 50).floor]
    return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].ice
  end

  def type(x, y)
    return nil if invalid(x, y)
    return nil if !@tiles[(x / 50).floor][(y / 50).floor]
    return @tiles[(x / 50).floor][(y / 50).floor]
  end

end