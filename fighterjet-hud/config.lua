Config = {
    Speed = "knots", -- knots/kilometers/miles
    Altitude = "feet", -- feet/meters
    Vehicles = { -- add vehicles that you want
        {
            model = "besra", -- plane model
            color = "orange", -- green/orange/red/blue
            retractableGear = true, -- defines if plane has a retractable or not
            vtol = false -- defines if plane has a vtol or not
        },
        {
            model = "lazer",
            color = "green",
            retractableGear = true,
            vtol = false
        },
        {
            model = "hydra",
            color = "red",
            retractableGear = true,
            vtol = true
        },
        {
            model = "stunt",
            color = "blue",
            retractableGear = false,
            vtol = false
        },
    },
    OnlyFirstPerson = false, -- displays HUD only in first person mode
    DisableRadar = true, -- disables minimap/radar inside the plane
    StallWarning = true, -- enables stall warning (text and sound)
    AltitudeWarning = true, -- enables altitude warning (text and sound)
    AltitudeWarningHeigth = 50, -- sets the altitude under the altitude warning will turn on
    Weapons = { -- don't touch unless you know what you're doing
        [-494786007] = "machinegun",
        [-821520672] = "missiles",
    },
}