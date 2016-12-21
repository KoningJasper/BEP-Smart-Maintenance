function [totalCost] = ObjectFunction(Failure_Rate_Per_Task, Failure_Rate_Graphs_No_Maintenance, input, t_max, t_p, components, tasks, vesselLocation, forwardBias, maximumBias, costPerManhour, penaltyCost, timeFactorAtSea)

% PARAMS
% bool forwardBias = true geeft wanneer de oplossing niet kan wordt er
% eerst gezocht naar oplossing die verder weg zijn niet dichterbij. Bij
% false andersom.
% double maximumBias = 0<maximumBias<1; is de maximum afwijking, factor,
% die wordt afgeweken van het interval.

% Pre-Calc %
no_components = size(components, 1);
no_tasks      = size(tasks, 1);
no_time_steps = t_max/t_p;

% Pre-alloc %
maintenanceTimes      = zeros(no_components, no_tasks);     % Start times of maintenance, per component;
endTimeMaintenance    = cell(no_components, no_tasks);      % EndTimes of maintenance, per component
noComponentMainte     = ones(no_components, 1);
maintTimePerComponent = zeros(no_components, 1);
FailureRepairTimes    = cell2mat(components(:, 6));
SignificanceIndices   = cell2mat(components(:, 5));


%% Pre-check 

interval = cell2mat(input) .* cell2mat(tasks(:, 6));                        % convert ratio to Time for maintenance(h)
for i = 1:no_tasks
    no_executed_maintenance = floor(no_time_steps/interval(i));

    for j = 1:no_executed_maintenance
        t = floor(j*interval(i));
        if(t <= 1)
            t = 1;
        end
        
        % Check if location of vessel at time (t) matches the required location for the maintenance task.
        if (vesselLocation(t, 2) ~= 1)                                     %0 at sea, 1 in port, 2 in dock.
            
            % Vessel  is not at required location at time t, find new time to execute maintenance.
            ht = floor(t);
            
            % Check possible solutions later than t;
            if(forwardBias == true)
                endTime = (1 + maximumBias) * interval(i);
                
                if(j > 1)
                    if(endTime >= (maintenanceTimes(i, j-1) + tasks{i, 6}))
                        endTime = tasks{i, 6};
                    end
                    endTime = endTime + maintenanceTimes(i, j - 1);
                else
                    if(endTime >= tasks{i, 6})
                        endTime = tasks{i, 6};
                    end
                end
                t = findMaintenanceTime(ht, endTime, t_p, vesselLocation, tasks{i, 4});
            end
            
            % Check possible solutions earlier than t;
            if(t == 0 || forwardBias == false)
                startTime = floor((1 - maximumBias) * interval(i));
                if(startTime <= 0)
                    startTime = 0;
                end
                
                if(j > 1)
                    startTime = floor(startTime + maintenanceTimes(i, j - 1));
                else
                    if(startTime <= 0)
                        startTime = 0;
                    end
                end
                t = findMaintenanceTime(startTime, ht, t_p, vesselLocation, tasks{i,4});
            end
            
            % Check if new solution is not found.
            if(t == 0)
                totalCost = realmax('single');                             % Set total cost to max possible value.
                return;                                                    % Exit function.
            end
        end
        
        % Check if (newly) scheduled maintenance time exceeds given t_max.
        if(t > t_max)
            continue;
        end
        
        % Solution found.
        maintenanceTimes(i,j) = t;
        component_id = tasks{i, 7};
        endTimeMaintenance{component_id, noComponentMainte(component_id, 1)} = [t + tasks{i, 4}, i];
        noComponentMainte(component_id, 1) = noComponentMainte(component_id, 1) + 1;
        maintTimePerComponent(component_id, 1) = maintTimePerComponent(component_id, 1) + tasks{i, 4};
    end
end

%% Integrate over Time 

FailureRateOverTimePerComponent = zeros(no_components, t_max + 1);
for i = 1:no_components
    % Find end-times of relevant maintenance for component.
    endTimes = endTimeMaintenance(i, :);
    endTimes = endTimes(~cellfun('isempty', endTimes));
    FailureRateOverTimePerComponent(i, :) = Failure_Rate_Graphs_No_Maintenance(i, :);
    
    sz = size(endTimes, 2);
    times = zeros(1, sz);
    ids   = zeros(1, sz);
    for n=1:sz
        times(n) = endTimes{1, n}(1);
        ids(n)   = endTimes{1, n}(2);
    end
    
    for t = 1:sz
        time = times(t);
        id   = ids(t);
        
        % Skip if (planned) time of maintenance exceeds maximum time.
        if(time > t_max)
            continue;
        end
        
        % Recalculate failure rate of component.
        restTime  = t_max + 1 - time + 1;                                  % Time left until t_max.
        endFR     = FailureRateOverTimePerComponent(i, time);              % Value of failure-rate at end of previous maintenance cycle, and start of new maintenance cycle.
        m2        = tasks{id, 9};                                          % m2 parameter, Tsai.
        shift     = endFR + m2 * (0 - endFR);                              % Vertical shift to align failure-rate graphs.
        FailureRateOverTimePerComponent(i, time:end) = Failure_Rate_Per_Task(id, 1:restTime) + shift;
    end
end

%% Find total cost.

% Find total number of failures per component by integrating Failure-rate
% of the component.
componentFailures = zeros(no_components, 1);
for i=1:no_components
    componentFailures (i) = trapz(FailureRateOverTimePerComponent(i, :));   % Integrate
end
TotalSignificance = sum(SignificanceIndices);

Cost_CM   = SignificanceIndices .* FailureRepairTimes .* componentFailures .* timeFactorAtSea .* penaltyCost  ./ TotalSignificance;
Cost_PM   = maintTimePerComponent .* costPerManhour;
totalCost = sum(Cost_CM + Cost_PM);