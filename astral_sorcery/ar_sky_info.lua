-- Define global variables
VERSION_STR_ASTRAL_SORCERY = 'astralsorcery-1.16-1.16.5-1.13.12'
NAME_ENVIRONMENT_DETECTOR = 'environmentDetector'
NAME_AR_CONTROLLER = 'arController'
INTERVAL_MAIN_LOOP_SLEEP_SECONDS = 0.25

CONSTELLATION_TABLE = {
    ['discidia'] = { 0, 5, 6, 7 },
    ['armara'] = { 2, 3, 4, 5, 6 },
    ['vicio'] = { 3, 4, 5, 6, 7 },
    ['aevitas'] = { 2, 3, 4, 5, 6 },
    ['evorsio'] = { 2, 3, 4, 5, 6 },
    ['lucerna'] = { 0, 4, 5, 6, 7 },
    ['mineralis'] = { 0, 1, 2, 3, 7 },
    ['octans'] = { 2, 3, 4, 5, 6 },
    ['bootes'] = { 0, 1, 2, 3, 7 },
    ['fornax'] = { 0, 4, 5, 6, 7 },
    ['gelu'] = { 2, 3, 4 },
    ['ulteria'] = { 0, 2, 7 },
    ['alcara'] = { 0, 4 },
    ['vorux'] = { 5, 6, 7 }
}

SPECIAL_CONSTELLATION_TABLE = {
    'horologium',
    'pelotrio'
}

function main()

    -- Bind an environment detector peripheral
    local peripheralEnvironmentDetector = peripheral.find( NAME_ENVIRONMENT_DETECTOR )
    if peripheralEnvironmentDetector == nil then
        error( 'Cannot find ' .. NAME_ENVIRONMENT_DETECTOR .. '.' )
        do return end
    end

    -- Bind an ar controller peripheral
    local peripheralArController = peripheral.find( NAME_AR_CONTROLLER )
    if peripheralArController == nil then
        error( 'Cannot find ' .. NAME_AR_CONTROLLER .. '.' )
        do return end
    end

    while true do



        -- For the sake of server performance, so a little sleep here
        sleep(INTERVAL_MAIN_LOOP_SLEEP_SECONDS)

    end

end

main()