-- Server-side callbacks for qbx_divegear
lib.callback.register('qbx_divegear:fillTank', function(source, cb)
    -- Server-side validation for tank refill can be added here
    cb(true)
end)
