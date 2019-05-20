class Shithe < Enemy
    
    def activation
        @speed = @param == 1 ? 5 : 1
        @strength = 5
        @defense = 3
        @world = 7
        @hp = 6
        @score = 13000
        @synced_animation_delay = (Difficulty.get > Difficulty::NORMAL ? 7 : 5)
        @spike_strength = 10
        load_graphic("Shithe")
        @description = "A slow Shi with a dangerous scythe. Be careful whether it
                        it has the scythe above it or before it. Sometimes fast.
                        Lives in the Season Mountains and cuts down bushes."
    end

  def custom_mechanics
    @spike = (@cur_image == @walk1)
    if @map.type(@x + (@dir == :left ? -1 : 1)*(@xsize+5), @y) == Tiles::Tree then
      @window.play_sound("laser", 1, 0.2)
      @window.add_tile(@x + (@dir == :left ? -1 : 1)*(@xsize+5), @y, nil)
    end
  end
    
end
