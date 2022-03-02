class World_Inuhh
    
  def initialize(window, x, y)
      @window = window
      @x,@y = x,y
      @image = Image.new(Pics::World_Inuhh, tileable: true)
  end
  
  def move(x, y)
      @x,@y = x,y
  end
  
  def draw
      @image.draw(@x, @y, ZOrder::Player, 0.5, 0.5)
  end
  
end