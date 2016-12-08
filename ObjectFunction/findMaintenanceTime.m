function time = findMaintenanceTime(startTime, endTime, tp, vesselLocations)
    % PARAMS
    % startTime       = start time.
    % endTime         = end time of search window.
    % tp              = timestep
    % vesselLocations = location of vessel over time.
    
    time = 0;
    for i=startTime:tp:endTime
        if(vesselLocations{i, 1} == 1)
            time = i;
        end
    end
end