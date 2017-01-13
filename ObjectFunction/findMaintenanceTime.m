function time = findMaintenanceTime(startTime, endTime, idealTime, duration, requiredLocation, availableDuration)
    % PARAMS
    % startTime       = start time of the search window.
    % endTime         = end time of search window.
    % idealTime       = wanted time.
    % tp              = timestep
    % vesselLocations = location of vessel over time.
    % duration        = duration of maintenance task.
    
    maxTime           = size(availableDuration, 1);
    if(endTime > maxTime)
        endTime = maxTime;
    end
    
    if(startTime <= 1)
        startTime = 1;
    end
            
    [rows, ~] = find(availableDuration(startTime:endTime, requiredLocation + 1) >= duration);

    % Select solution with least possible difference with the ideal time
    times     = rows + startTime;
    diffIdeal = abs(times - idealTime);
    [~,I]     = min(diffIdeal);
    time      = times(I);
end
