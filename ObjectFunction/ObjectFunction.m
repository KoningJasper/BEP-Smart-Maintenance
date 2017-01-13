function [totalCost, Cost_CM, Cost_PM, FailureRateOverTimePerComponent, maintCalStart, endTimeMaintenance] = ObjectFunction(Failure_Rate_Per_Task, Failure_Rate_Graphs_No_Maintenance, input, t_max, t_p, components, tasks, vesselLocation, forwardBias, maximumBias, maximumBiasAbsolute, costPerManhour, penaltyCost, timeFactorAtSea, runningHours, availableDuration)
% PARAMS
% bool forwardBias = true geeft wanneer de oplossing niet kan wordt er
% eerst gezocht naar oplossing die verder weg zijn niet dichterbij. Bij
% false andersom.
% double maximumBias = 0<maximumBias<1; is de maximum afwijking, factor,
% die wordt afgeweken van het interval.

% Pre-Calc %
no_components = size(components, 1);
no_tasks      = size(tasks, 1);

% Pre-alloc %
maintCalStart         = zeros(no_tasks, 0);     % Start times of maintenance, per task, in calendar hours.
endTimeTask           = zeros(no_tasks, 1);     % Last end time of maintenance for this task, in running hours.
endTimeMaintenance    = cell(no_components, 1);      % EndTimes of maintenance, per component, in running hours.
endTimeMaintenance(:,:) = {0};
endTimeCalendar       = zeros(no_components, 1);     % EndTimes of maintenance, per component, in calendar hours.
noComponentMainte     = ones(no_components, 1);
maintTimePerComponent = zeros(no_components, 1);
FailureRepairTimes    = cell2mat(components(:, 6));
SignificanceIndices   = cell2mat(components(:, 5));


%% Pre-check 
maxRunningHours         = runningHours(end);
runningHoursMaintenance = cell2mat(input) .* cell2mat(tasks(:, 6));        % convert ratio to running hours for maintenance (h)
for i = 1:no_tasks
    no_executed_maintenance = floor(maxRunningHours/runningHoursMaintenance(i));
    
    % Execute loop a minimum of once.
    if(no_executed_maintenance == 0)
        no_executed_maintenance = 1;
    end
    
    j = 1;
    while j <= no_executed_maintenance
        component_id = tasks{i, 7};
        reqLocation  = tasks{i, 3};
        % Find time to execute maintenance based on running hours tally.
        runningHoursToFind = floor(runningHoursMaintenance(i));
        if(j > 1)
            runningHoursToFind = floor(endTimeTask(i) + runningHoursMaintenance(i));
        end
        if(runningHoursToFind > maxRunningHours)
            runningHoursToFind = maxRunningHours;
        end
        t = find(runningHours == runningHoursToFind);
        t = t(end); % Only get last one.
        
        if(t <= 1)
            t = 1;
        end
        
        maxCalendarTimeSinceMaint = tasks{i, 5} * 7 * 24;
        maxTimeSinceMaint         = tasks{i, 6};
        
        if(j > 1)
            calendarTimeSinceMaint = t - endTimeCalendar(component_id, j - 1);
            timeSinceMaint         = runningHoursToFind - endTimeMaintenance{component_id, j - 1}(1);
        else
            calendarTimeSinceMaint = t;
            timeSinceMaint         = runningHoursToFind;
        end
        
        % Check if location of vessel at time (t) matches the required location for the maintenance task.
        %0 at sea, 1 in port, 2 in dock.
        if (vesselLocation(t, 2) ~= reqLocation || calendarTimeSinceMaint > maxCalendarTimeSinceMaint || timeSinceMaint > maxTimeSinceMaint)
            ideal = t;
            
            % Increase the number of times maintenance is done.
            if(calendarTimeSinceMaint > maxCalendarTimeSinceMaint || timeSinceMaint > maxTimeSinceMaint)
                no_executed_maintenance = no_executed_maintenance + 1;
                
                if(calendarTimeSinceMaint > maxCalendarTimeSinceMaint)
                    ideal = t + maxCalendarTimeSinceMaint;
                elseif(timeSinceMaint > maxTimeSinceMaint)
                    ideal = t + maxTimeSinceMaint;
                end
            end
            
            % Vessel is not at required location at time t or exceed max time, find new time to execute maintenance.
            ht = floor(t);
            
            % Check possible solutions later than t;
            if(forwardBias == true && calendarTimeSinceMaint < maxCalendarTimeSinceMaint && timeSinceMaint < maxTimeSinceMaint)
                if(j > 1)
                    % Establish maxima
                    % Not first maintenance.
                    if((1 + maximumBias) * runningHoursMaintenance(i) >= maximumBiasAbsolute)
                        rhsToFind = floor(runningHours(maintCalStart(i, j - 1)) + (1 + maximumBias) * runningHoursMaintenance(i));
                    else
                        rhsToFind = floor(runningHours(maintCalStart(i, j - 1)) + runningHoursMaintenance(i) + maximumBiasAbsolute);
                    end
                    ts = find(runningHours >= rhsToFind);
                    if(size(ts, 1) >= 1)
                        maxBias = ts(1);
                    else
                        maxBias = realmax('single');
                    end
                    maxCal = maintCalStart(i, j - 1) + maxCalendarTimeSinceMaint;
                    rhsToFind = runningHours(maintCalStart(i, j - 1)) + maxTimeSinceMaint;
                    ts = find(runningHours >= rhsToFind);
                    if(size(ts, 1) >= 1)
                        maxRunning = ts(1);
                    else
                        maxRunning = realmax('single');
                    end
                else
                    % Initial maxima
                    % First maintenance.
                    if((1 + maximumBias) * runningHoursMaintenance(i) >= maximumBiasAbsolute)
                        rhsToFind = floor((1 + maximumBias) * runningHoursMaintenance(i));
                    else
                        rhsToFind = floor(runningHoursMaintenance(i) + maximumBiasAbsolute);
                    end
                    ts = find(runningHours >= rhsToFind);
                    if(size(ts, 1) >= 1)
                        maxBias = ts(1);
                    else
                        maxBias = realmax('single');
                    end
                    maxCal = maxCalendarTimeSinceMaint;
                    rhsToFind = maxTimeSinceMaint;
                    ts = find(runningHours >= rhsToFind);
                    if(size(ts, 1) >= 1)
                        maxRunning = ts(1);
                    else
                        maxRunning = realmax('single');
                    end
                end
                
                endTime = min([maxBias, maxCal, maxRunning]); % Select the minimum of the maximum deviations.
                t = findMaintenanceTime(ht, endTime, ideal, tasks{i, 4}, reqLocation, availableDuration); % Find a new schedule time.
            end
            
            % Check possible solutions earlier than t;
            if(isempty(t) || t == 0 || forwardBias == false || (calendarTimeSinceMaint > maxCalendarTimeSinceMaint || timeSinceMaint > maxTimeSinceMaint))
                % Check what is larger absolute or relative bias, and use
                % the larger one.
                if(j > 1)
                    % Establish maxima
                    % Not first maintenance.
                    if((1 + maximumBias) * runningHoursMaintenance(i) >= maximumBiasAbsolute)
                        rhsToFind = floor(runningHours(maintCalStart(i, j - 1)) - (1 - maximumBias) * runningHoursMaintenance(i));
                    else
                        rhsToFind = floor(runningHours(maintCalStart(i, j - 1)) + runningHoursMaintenance(i) - maximumBiasAbsolute);
                    end
                    ts = find(runningHours >= rhsToFind);
                    if(size(ts, 1) >= 1)
                        maxBias = ts(1);
                    else
                        maxBias = runningHours(maintCalStart(i, j - 1));
                    end
                else
                    if((1 + maximumBias) * runningHoursMaintenance(i) >= maximumBiasAbsolute)
                        rhsToFind = floor((1 - maximumBias) * runningHoursMaintenance(i));
                    else
                        rhsToFind = floor(runningHoursMaintenance(i) - maximumBiasAbsolute);
                    end
                    ts = find(runningHours >= rhsToFind);
                    if(size(ts, 1) >= 1)
                        maxBias = ts(1);
                    else
                        maxBias = 0;
                    end
                end
                startTime = maxBias; % min([maxBias]);
                endTime   = ht;
                
                % Adjust endTime if it exceeds maximum.
                if(calendarTimeSinceMaint > maxCalendarTimeSinceMaint || timeSinceMaint > maxTimeSinceMaint)
                    if(timeSinceMaint > maxTimeSinceMaint)
                        ts = find(runningHours <= maxTimeSinceMaint);
                        if(size(ts, 1) >= 1)
                            endTime = ts(end);
                        end
                    end
                    
                    lastMaint = 0;
                    if(j > 1)
                        lastMaint = endTimeCalendar(component_id, j - 1);
                    end
                    
                    if((endTime - lastMaint) > maxCalendarTimeSinceMaint)
                        endTime = lastMaint + maxCalendarTimeSinceMaint;
                    end
                end
                t = findMaintenanceTime(startTime + 1, endTime, ideal, tasks{i,4}, reqLocation, availableDuration);
            end
            
            % Check if new solution is not found.
            if(t == 0)
                totalCost = realmax('single');                             % Set total cost to max possible value.
                return;                                                    % Exit function.
            end
        end
        
        % Check if (newly) scheduled maintenance time exceeds given t_max.
        if(isempty(t) || t > t_max)
            break;
        end
        
        % Solution found.
        maintCalStart(i,j) = t;
        
        % Find time in runninghours.
        endTimeCalendar(component_id, j) = t + tasks{i, 4};
        tRH = runningHours(t) + 1;
        endTimeTask(i) = tRH;
        endTimeMaintenance{component_id, noComponentMainte(component_id, 1)} = [tRH + 1, i];
        noComponentMainte(component_id, 1) = noComponentMainte(component_id, 1) + 1;
        maintTimePerComponent(component_id, 1) = maintTimePerComponent(component_id, 1) + tasks{i, 4};
        
        j = j + 1;
    end
end

%% Integrate over Time 
PartCostPerComponent = zeros(no_components, 1);
FailureRateOverTimePerComponent = zeros(no_components, maxRunningHours + 1);
componentFailures = zeros(no_components, 1);
for i = 1:no_components
    % Find end-times of relevant maintenance for component.
    endTimes = endTimeMaintenance(i, :);
    endTimes = endTimes(~cellfun('isempty', endTimes));
    endTimes = endTimes(~cellfun(@(x) ~x(1), endTimes));
    FailureRateOverTimePerComponent(i, :) = Failure_Rate_Graphs_No_Maintenance(i, :);
       
    % Separate ids and times.
    ends  = [endTimes{:}];
    lt    = length(ends);
    times = ends(1:2:lt);
    ids   = ends(2:2:lt);
    
    for t = 1:(lt / 2)
        time = times(t);
        id   = ids(t);
        
        % Skip if (planned) time of maintenance exceeds maximum time.
        if(time > maxRunningHours)
            continue;
        end
        
        % Recalculate failure rate of component.
        restTime  = maxRunningHours + 1 - time + 1;                        % Time left until t_max.
        endFR     = FailureRateOverTimePerComponent(i, time);              % Value of failure-rate at end of previous maintenance cycle, and start of new maintenance cycle.
        m2        = tasks{id, 9};                                          % m2 parameter, Tsai.
        shift     = endFR + m2 * (0 - endFR);                              % Vertical shift to align failure-rate graphs.
        FailureRateOverTimePerComponent(i, time:end) = Failure_Rate_Per_Task(id, 1:restTime) + shift;
        PartCostPerComponent(i) = PartCostPerComponent(i) + tasks{id, 10}; % Add part costs.
    end
    
    % Find total number of failures per component by integrating Failure-rate
    % of the component.
    componentFailures(i) = trapz(FailureRateOverTimePerComponent(i, :));   % Integrate
end

%% Find total cost.
TotalSignificance = sum(SignificanceIndices);

Cost_CM   = SignificanceIndices ./ TotalSignificance .* FailureRepairTimes .* componentFailures .* timeFactorAtSea .* penaltyCost + componentFailures .* cell2mat(components(:,7)); 
Cost_PM   = maintTimePerComponent .* costPerManhour + PartCostPerComponent;
totalCost = sum(Cost_CM + Cost_PM);