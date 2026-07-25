function RegisterItems()
    plsr.Inventory.Items:RegisterUse('camping_chair', 'Animations', function(source, itemData)
        TriggerClientEvent('Animations:Client:CampChair', source)
    end)

    plsr.Inventory.Items:RegisterUse('beanbag', 'Animations', function(source, itemData)
        TriggerClientEvent('Animations:Client:BeanBag', source)
    end)

    plsr.Inventory.Items:RegisterUse('binoculars', 'Animations', function(source, itemData)
        TriggerClientEvent('Animations:Client:Binoculars', source)
    end)

    plsr.Inventory.Items:RegisterUse('camera', 'Animations', function(source, itemData)
        TriggerClientEvent('Animations:Client:Camera', source)
    end)
end