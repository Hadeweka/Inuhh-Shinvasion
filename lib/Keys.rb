module Keys
   
    Left = [KbLeft, KbA]
    Right = [KbRight, KbD]
    Up = [KbUp, KbW]
    Down = [KbDown, KbS]
    
    Jump = [KbUp, KbW]
    Run = [KbRightControl, KbLeftControl, KbRightShift, KbLeftShift]
    Enter = [KbReturn]
    Escape = [KbEscape]
    
    ScrollDown = [MsWheelDown]
    ScrollUp = [MsWheelUp]
    
    ToggleHUD = [KbSpace]
    
    Gems1 = [Kb1]
    Gems2 = [Kb2]
    Gems3 = [Kb3]
    Gems4 = [Kb4]
    Gems5 = [Kb5]
    Gems6 = [Kb6]
    
    UseItem = [KbSpace]
    
    Pause = [KbP]
    
    Help = [KbF1]

    def self.is_down?(window, keys)
        
        keys.each do |key|
            return true if window.button_down?(key)
        end
        
        return false
        
    end
    
end
