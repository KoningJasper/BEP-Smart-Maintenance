function availableDurations = BuildAvailableDuration( VesselLocations )
	%BUILDAVAILABLEDURATION Builds matrix of available durations
    t_max = size(VesselLocations, 1);
    availableDurations = zeros(t_max, 4);
    for t=2:t_max
        for loc=0:3
            if(VesselLocations(t, 2) == loc)
                availableDurations(t, loc + 1) = availableDurations(t - 1, loc + 1) + 1;
            else
                availableDurations(t, 1) = 0;
            end
        end
    end
end

