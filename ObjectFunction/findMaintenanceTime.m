function time = findMaintenanceTime(startTime, endTime, idealTime, tp, vesselLocations, duration)
    % PARAMS
    % startTime       = start time of the search window.
    % endTime         = end time of search window.
    % idealTime       = wanted time.
    % tp              = timestep
    % vesselLocations = location of vessel over time.
    % duration        = duration of maintenance task.
    
    time              = 0;
    availableDuration = 0;
    maxTime           = size(vesselLocations, 1);
    solutions         = [];
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
            time = i - duration + 1;
            solutions(end + 1) = time;
            % If first possible solution is desired insert: 'return;'
        end
    end
    
    % Select solution with least possible difference with the ideal time
    diffIdeal = abs(solutions - idealTime);
    [~,I] = min(diffIdeal);
    time = solutions(I);
end
