class Residuum
  attr_reader :x, :y
  attr_accessor :counter
  
  def initialize(x, y, counter, window, image)
      @x,@y,@counter = x,y,counter
      @image = image
  end
  
  def draw
      @image.draw(@x, @y, ZOrder::Mud)
  end
  
end