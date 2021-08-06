-- Define global variables
SIDE_TABLE = rs.getSides()
TYPE_ENERGIZING_ORB = 'powah:energizing_orb'

function main()

    -- Display program description
    term.setTextColor( colors.green )
    print( 'This program automates an energizing orb (Powah) process by ' ..
        'pulling recipe valid items from an adjacent inventory.\n' ..
        '[NOTE]\n' ..
        '1. The program recognizes the recipe from an existing item in ' ..
        'the energizing orb OR from the first recipe valid item in an ' ..
        'adjacent inventory.\n' ..
        '2. The program will wait until the correct items being inserted in, ' ..
        'in case that there are missing items for a current recipe.' )
    term.setTextColor( colors.white )

    -- Get energizing orb peripheral side from user
    print( 'Please input an energizing orb side ( ' .. table.concat( SIDE_TABLE, ', ' ) .. '): ' )
    local sideEnergizingOrb = read()
    if not ( peripheral.isPresent( sideEnergizingOrb ) and peripheral.getType( sideEnergizingOrb ) == TYPE_ENERGIZING_ORB ) then
        error( 'Invalid energizing orb side. Please check the peripheral side and type again.' )
        do return end
    end

    -- Get input inventory peripheral side from user
    print( 'Please input an input inventory side ( ' .. table.concat( SIDE_TABLE, ', ' ) .. '): ' )
    local sideInputInventory = read()
    if not peripheral.isPresent( sideInputInventory ) then
        error( 'Invalid input inventory side. Please check the peripheral side and type again.' )
        do return end
    end

    -- Get output inventory peripheral side from user
    print( 'Please input an output inventory side ( ' .. table.concat( SIDE_TABLE, ', ' ) .. '): ' )
    local sideOutputInventory = read()
    if not peripheral.isPresent( sideOutputInventory ) then
        error( 'Invalid output inventory side. Please check the peripheral side and type again.' )
        do return end
    end

    -- Bind an energizing orb peripheral
    local peripheralEnergizingOrb = peripheral.wrap( sideEnergizingOrb )

    while true do

        -- Just input some item in energizing orb to break the loop (WIP)
        if next( peripheralEnergizingOrb.list() ) then
            print('something in!')
            break
        end

    end

end

main()