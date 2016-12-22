function [RunningHoursOverTime] = GetRunningHoursTally(VesselLoc, t_p)
    %GETRUNNINGHOURSTALLY Gets the tally of running hours of the vessel
    %   Detailed explanation goes here
    maxSize = size(VesselLoc, 1);
    RunningHoursOverTime = zeros(maxSize, 1);
    for i=2:maxSize
        if(VesselLoc(i, 2) == 0)
            RunningHoursOverTime(i) = RunningHoursOverTime(i - 1) + t_p;
        else
            RunningHoursOverTime(i) = RunningHoursOverTime(i - 1);
        end
    end
end