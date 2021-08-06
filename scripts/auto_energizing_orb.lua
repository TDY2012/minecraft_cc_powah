-- Define global variables
SIDE_TABLE = rs.getSides()
TYPE_ENERGIZING_ORB = 'powah:energizing_orb'
INTERVAL_MAIN_LOOP_SLEEP_SECONDS = 0.25

--[[
    [NOTE]
    You can modify the available recipes here, but keep in mind that this table
    should be 1-1 mapping invertible.
]] --
RECIPE_TABLE = {
    ['powah:dry_ice'] = { 'minecraft:blue_ice', 'minecraft:blue_ice' },
    ['powah:crystal_nitro'] = { 'minecraft:nether_star', 'minecraft:redstone_block', 'minecraft:redstone_block', 'powah:blazing_crystal_block' },
    ['powah:steel_energized'] = { 'minecraft:iron_ingot', 'minecraft:gold_ingot' },
    ['powah:crystal_blazing'] = { 'minecraft:blaze_rod' },
    ['powah:crystal_niotic'] = { 'minecraft:diamond' },
    ['powah:charged_snowball'] = { 'minecraft:snowball' },
    ['powah:ender_core'] = { 'minecraft:ender_eye', 'powah:dielectric_casing', 'powah:capacitor_basic_tiny' },
    ['powah:crystal_spirited'] = { 'minecraft:emerald' }
}

-- Construct material to crafting item table
INVERTED_RECIPE_TABLE = { }
for craftingItem, materialItemTable in pairs( RECIPE_TABLE ) do
    for _, materialItem in pairs( materialItemTable ) do
        INVERTED_RECIPE_TABLE[ materialItem ] = craftingItem
    end
end

-- Construct material table
MATERIAL_TABLE = { }
for materialItem, _ in pairs( INVERTED_RECIPE_TABLE ) do
    table.insert( MATERIAL_TABLE, materialItem )
end

-- This function simply shallow copies given table
function tableCopy( t )
    local ret = {}

    for k, v in pairs(t) do
        ret[k] = v
    end

    return ret
end

-- This function returns the first occurance index of a given element in the table or -1 if there is none
function tableFind( t, s )
    local ret = -1

    for k, v in pairs(t) do
        if v == s then
            ret = k
            break
        end
    end

    return ret
end

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

    -- Bind an energizing orb peripheral and input inventory
    local peripheralEnergizingOrb = peripheral.wrap( sideEnergizingOrb )
    local peripheralInputInventory = peripheral.wrap( sideInputInventory )

    -- Main loop
    while true do

        -- Get existing item table in energizing orb and input inventory
        local existingItemTable = peripheralEnergizingOrb.list()
        local inputItemTable = peripheralInputInventory.list()

        -- Check if the output slot (1) of the energizing orb is not empty
        if existingItemTable[1] ~= nil then

            -- Push item from output slot to the output inventory
            print('Removing "' .. existingItemTable[1].name .. '" from an energizing orb.')
            peripheralEnergizingOrb.pushItems( sideOutputInventory, 1 )

        end

        -- Initialize variables for crafting recipe checking
        local slotIndex = 2
        local craftingItem = ''
        local expectingItemTable = {}

        -- From slot 2 to 7 of an energizing orb
        while slotIndex <= 7 do

            -- Check if there is an existing item in the current slot and if it is a part of any recipe
            if existingItemTable[ slotIndex ] ~= nil and INVERTED_RECIPE_TABLE[ existingItemTable[ slotIndex ].name ] ~= nil then

                -- If so, map it to get the crafting item and expecting item table
                craftingItem = INVERTED_RECIPE_TABLE[ existingItemTable[ slotIndex ].name ]
                expectingItemTable = tableCopy( RECIPE_TABLE[ craftingItem ] )
                break

            end

            slotIndex = slotIndex + 1
        end

        -- If a recipe is detected, try fetch missing items
        if craftingItem ~= '' then

            print( 'Crafting "' .. craftingItem .. '".' )

            -- From last checked slot to 7 of an energizing orb
            while slotIndex <= 7 do

                -- Remove expecting item which is already existed in an energizing orb
                if existingItemTable[ slotIndex ] ~= nil then
                    table.remove( expectingItemTable, tableFind( expectingItemTable, existingItemTable[ slotIndex ].name ) )
                end

                slotIndex = slotIndex + 1

            end

            -- Fetch all expecting items which are not in an energizing orb by looking throught the input inventory
            for inputInventorySlotIndex, inputItem in pairs( inputItemTable ) do
                for expectingItemIndex, expectingItem in pairs( expectingItemTable ) do

                    -- If found the expecting item, just put it in the energizing orb and remove from the expecting table
                    if inputItem.name == expectingItem then
                        peripheralEnergizingOrb.pullItems( sideInputInventory, inputInventorySlotIndex, 1 )
                        table.remove( expectingItemTable, expectingItemIndex )
                        break
                    end

                end
            end

        -- Otherwise, find new recipe to craft by looking for a material item in the input inventory
        else

            print( 'Searching for material item.' )

            -- Initialize a flag which signals a material item finding
            local isFoundMaterialItem = false

            -- Fetch all material items which through the input inventory
            for inputInventorySlotIndex, inputItem in pairs( inputItemTable ) do

                for _, materialItem in pairs( MATERIAL_TABLE ) do

                    -- If found the material item, just put it in the energizing orb
                    if inputItem.name == materialItem then
                        isFoundMaterialItem = true
                        peripheralEnergizingOrb.pullItems( sideInputInventory, inputInventorySlotIndex, 1 )
                        break
                    end

                end

                -- If found the material item, stop searching through input inventory
                if isFoundMaterialItem then
                    break
                end
            end

        end

        -- I still have a performance concern for this program, so a little sleep here
        sleep( INTERVAL_MAIN_LOOP_SLEEP_SECONDS )

    end

end

main()