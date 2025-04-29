
config = {

    grav = 128,

    p = {

        flap = {

            tolWeak = 64 * 0.6,
            tolHalt = 999, 
    
            halt = 16,
            strength = 64,
            mult = 2,
        },

        move = {

            max = 64,
        },

        charge = {

            -- charge time to
            toCharge = 0.2,
            toAttack = 0.6,
            buffer = 0.2,
            
            -- gravity scale while charging
            graScale = 2.5,
        },

        attack = {

            speed = 64 * 3,
            distance = 8 * 12,
        },

        stunDur = 0.5,

        terminal = 64,
    }
}

-- post init

config.p.attack.time = config.p.attack.distance / config.p.attack.speed
