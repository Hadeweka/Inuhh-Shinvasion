class Carshi < Enemy
    
    def activation
        @xsize = 75
        @ysize = 50
        @world = 6
        @hp = 20
        @range = 500
        @havoc = true
        @hunting = true
        @defense = 5
        @abyss_turn = false
        @border_turn = false
        @border_jump_delay = 50
        @abyss_jump_delay = 50
        @random_jump_delay = 300
        @jump_image = false
        @hunt_max_delay = 100
        @strength = 8
        @score = 26000
        @speed = 7
        load_graphic("Carshi")
        @description = "T"
    end
    
    def at_death
        @projectile_lifetime = 20
        @projectile_owner = Projectiles::RAMPAGE
        @projectile_damage = 10
        @projectile_type = Projectiles::Fire
        detonate
    end
    
end
