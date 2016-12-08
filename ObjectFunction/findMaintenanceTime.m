function time = findMaintenanceTime(startTime, endTime, tp, vesselLocations, duration)
    % PARAMS
    % startTime       = start time.
    % endTime         = end time of search window.
    % tp              = timestep
    % vesselLocations = location of vessel over time.
    % duration        = duration of maintenance task.
    
    time              = 0;
    availableDuration = 0;
    maxTime           = size(vesselLocations, 1);
    
    if(endTime > maxTime)
        endTime = maxTime;
    end
    
    if(startTime <= 1)
        startTime = 1;
    end
    
    for i=startTime:tp:endTime
        if(vesselLocations(i, 2) == 1)
            availableDuration = availableDuration + 1;
        else 
            availableDuration = 0;
        end
        
        if(availableDuration >= duration)
            time = i - availableDuration + 1;
            % If first possible solution is desired insert: 'return;'
        end
    end
end
