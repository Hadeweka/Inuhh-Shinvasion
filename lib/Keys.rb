module Keys
   
  Left = [Gosu::KbLeft, Gosu::KbA]
  Right = [Gosu::KbRight, Gosu::KbD]
  Up = [Gosu::KbUp, Gosu::KbW]
  Down = [Gosu::KbDown, Gosu::KbS]
  
  Jump = [Gosu::KbUp, Gosu::KbW]
  Run = [Gosu::KbRightControl, Gosu::KbLeftControl, Gosu::KbRightShift, Gosu::KbLeftShift]
  Enter = [Gosu::KbReturn]
  Escape = [Gosu::KbEscape]
  
  ScrollDown = [Gosu::MsWheelDown]
  ScrollUp = [Gosu::MsWheelUp]
  
  ToggleHUD = [Gosu::KbSpace]
  
  Gems1 = [Gosu::Kb1]
  Gems2 = [Gosu::Kb2]
  Gems3 = [Gosu::Kb3]
  Gems4 = [Gosu::Kb4]
  Gems5 = [Gosu::Kb5]
  Gems6 = [Gosu::Kb6]
  
  UseItem = [Gosu::KbSpace]
  
  Pause = [Gosu::KbP]
  
  Help = [Gosu::KbF1]

  def self.is_down?(window, keys)
      
      keys.each do |key|
          return true if window.button_down?(key)
      end
      
      return false
      
  end
  
end