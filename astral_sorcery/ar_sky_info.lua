-- Define global variables
VERSION_STR_ASTRAL_SORCERY = 'astralsorcery-1.16-1.16.5-1.13.12'
NAME_ENVIRONMENT_DETECTOR = 'environmentDetector'
NAME_CHAT_BOX = 'chatBox'
NAME_AR_CONTROLLER = 'arController'
CMD_DRAW = '!sky_draw'
CMD_CLEAR = '!sky_clear'
TIME_MINECRAFT_DAY_TICK = 0
TIME_MINECRAFT_NIGHT_TICK = 12000
INTERVAL_MINECRAFT_DAY_TICK = 24000
INTERVAL_SOLAR_ECLIPSE_DAY = 36
INTERVAL_MAIN_LOOP_SLEEP_SECONDS = 1

-- Construct constellation to moon id table
CONSTELLATION_TABLE = {
    ['Discidia'] = { 0, 5, 6, 7 },
    ['Armara'] = { 2, 3, 4, 5, 6 },
    ['Vicio'] = { 3, 4, 5, 6, 7 },
    ['Aevitas'] = { 2, 3, 4, 5, 6 },
    ['Evorsio'] = { 2, 3, 4, 5, 6 },
    ['Lucerna'] = { 0, 4, 5, 6, 7 },
    ['Mineralis'] = { 0, 1, 2, 3, 7 },
    ['Octans'] = { 2, 3, 4, 5, 6 },
    ['Bootes'] = { 0, 1, 2, 3, 7 },
    ['Fornax'] = { 0, 4, 5, 6, 7 },
    ['Gelu'] = { 2, 3, 4 },
    ['Ulteria'] = { 0, 2, 7 },
    ['Alcara'] = { 0, 4 },
    ['Vorux'] = { 5, 6, 7 }
}

-- Construct moon id to constellation table
INVERTED_CONSTALLATION_TABLE = { [0]={}, [1]={}, [2]={}, [3]={}, [4]={}, [5]={}, [6]={}, [7]={} }
for constellation, moonIdTable in pairs( CONSTELLATION_TABLE ) do
    for _, moonId in pairs( moonIdTable ) do
        table.insert( INVERTED_CONSTALLATION_TABLE[ moonId ], constellation )
    end
end

SPECIAL_CONSTELLATION_TABLE = {
    'Horologium',
    'Pelotrio'
}

function draw( peripheralEnvironmentDetector, peripheralArController, firstSolarEclipseDate )

    -- Clear the ar screen
    peripheralArController.clear()

    -- Get today date
    local todayDate = math.floor( peripheralEnvironmentDetector.getTime() / INTERVAL_MINECRAFT_DAY_TICK )
    local currentTime = peripheralEnvironmentDetector.getTime() % INTERVAL_MINECRAFT_DAY_TICK

    -- Draw today date
    peripheralArController.drawItemIcon( 'minecraft:clock', -20, 5 )
    peripheralArController.drawRightboundString( 'Date (day) : ' .. todayDate, -20, 5, 0xFFFFFF )
    peripheralArController.drawRightboundString( 'Time (tick) : ' .. currentTime, -20, 15, 0xFFFFFF )

    -- Get weather
    local weather = 'Unknown'
    if peripheralEnvironmentDetector.isSunny() then
        weather = 'Clear'
    elseif peripheralEnvironmentDetector.isRaining() then
        weather = 'Rain'
    elseif peripheralEnvironmentDetector.isThunder() then
        weather = 'Storm'
    end

    -- Draw weather
    peripheralArController.drawItemIcon( 'minecraft:sunflower', -20, 22 )
    peripheralArController.drawRightboundString( 'Weather : ' .. weather, -20, 27, 0xFFFFFF )

    -- Get moon
    local moonId = peripheralEnvironmentDetector.getMoonId()
    local moonName = peripheralEnvironmentDetector.getMoonName()
    local availableConstellationStr = table.concat( INVERTED_CONSTALLATION_TABLE[ moonId ], ', ' )

    -- Draw moon and constellation
    peripheralArController.drawItemIcon( 'astralsorcery:perk_seal', -20, 39 )
    peripheralArController.drawRightboundString( 'Moon (id/name) : ' .. moonId .. '/' .. moonName, -20, 39, 0xFFFFFF )
    peripheralArController.drawRightboundString( 'Constellation : ' .. availableConstellationStr, -20, 49, 0xFFFFFF )

    -- WIP
    -- Compute Horologium availability

end

function main()

    -- Display program description and note messages
    print( 'This program visualizes the sky information including today date, ' ..
        'current time, weather, moon phase and today available constallations via an AR Goggles.\n' ..
        '(Tested with ' .. VERSION_STR_ASTRAL_SORCERY .. ')' )

    -- Bind an environment detector peripheral
    local peripheralEnvironmentDetector = peripheral.find( NAME_ENVIRONMENT_DETECTOR )
    if peripheralEnvironmentDetector == nil then
        error( 'Cannot find ' .. NAME_ENVIRONMENT_DETECTOR .. '.' )
        do return end
    end

    -- Bind a chat box peripheral
    local peripheralChatBoxController = peripheral.find( NAME_CHAT_BOX )
    if peripheralChatBoxController == nil then
        error( 'Cannot find ' .. NAME_CHAT_BOX .. '.' )
        do return end
    end

    -- Bind an ar controller peripheral
    local peripheralArController = peripheral.find( NAME_AR_CONTROLLER )
    if peripheralArController == nil then
        error( 'Cannot find ' .. NAME_AR_CONTROLLER .. '.' )
        do return end
    end

    -- Disable relative mode
    peripheralArController.setRelativeMode( false )

    -- Get the date of solar eclipse
    print( 'Please input the date of solar eclipse (input any string, if you don\'t know): ' )
    local firstSolarEclipseDate = tonumber(read())

    -- Validate given date
    if firstSolarEclipseDate ~= nil then

        -- Try convert to number
        if firstSolarEclipseDate < 0 then
            error( 'The date cannot be negative number.' )
            do return end
        end

        -- Find the first date of solar eclipse
        firstSolarEclipseDate = firstSolarEclipseDate % INTERVAL_SOLAR_ECLIPSE_DAY
    end

    print( 'To use this program, bind the AR Goggles to the AR Controller and type these commands in the chat box.\n' ..
        '1. !sky_draw : Redraw the sky information.\n' ..
        '2. !sky_clear : Clear the screen.' )

    local event, username, message

    while true do
        
        event, username, message = os.pullEvent("chat")

        -- Parse chat message to command
        if message == CMD_CLEAR then
            peripheralArController.clear()
        elseif message == CMD_DRAW then
            draw( peripheralEnvironmentDetector, peripheralArController, firstSolarEclipseDate )
        end

        -- I still have a performance concern for this program, so a little sleep here
        sleep( INTERVAL_MAIN_LOOP_SLEEP_SECONDS )

    end

end

main()