function [ totalCostSystem, plotReliability, plotTotalCost, reliabilityOverTime, maintenanceTimes, maintenanceTimePerComponent, hazardOverTime, plotHazard] = ObjectFunction(input, t_max, t_p, components, tasks, vesselLocation, forwardBias, maximumBias, costPerManhour, penaltyCost, timeFactorAtSea)

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
plotTotalCost       = zeros(no_time_steps + 1, 1);
plotReliability     = ones(no_time_steps + 1, 1);
plotHazard          = zeros(no_time_steps + 1, 1);
reliabilityOverTime = ones(no_time_steps + 1, no_components);
hazardOverTime      = zeros(no_time_steps + 1, no_components);
maintenanceTimes    = ones(no_tasks, 1);                       % Times at which maintenance occurs.
maintenanceTimePerComponent = zeros(no_components, 1);  % maintenace times per component.
totalCostSystem     = 0;

% Pre-check %
interval = cell2mat(input) .* cell2mat(tasks(:, 6)); % in tijd (h)
for i = 1:no_tasks
    no_executed_maintenance = floor(no_time_steps/interval(i));

    for j = 1:no_executed_maintenance
        tijdstip = floor(j*interval(i));
        if(tijdstip <= 1)
            tijdstip = 1;
        end
        
        if(tijdstip > t_max)
            continue;
        end
        
        if (vesselLocation(tijdstip, 2) ~= 1)  %0 is op zee, 1 is in de haven
            % Deze planning kan dus niet omdat het schip dan op zee is.
            % Verzin een nieuwe oplossing.
            
            ht = floor(tijdstip);
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
                tijdstip = findMaintenanceTime(ht, endTime, t_p, vesselLocation, tasks{i, 4});
            end
            
            % Check possible solutions earlier than t;
            if(tijdstip == 0 || forwardBias == false)
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
                tijdstip = findMaintenanceTime(startTime, ht, t_p, vesselLocation, tasks{i,4});
            end
            
            if(tijdstip == 0)
                return;
            else
                % Solution found.
                maintenanceTimes(i,j) = tijdstip;
            end
        else
            % This time is valid.
            maintenanceTimes(i, j) = tijdstip;
        end
    end
end

% Integrate over Time %
m1                 = ones(no_components, 1);            % m1 per component, Tsai.
active_maintenance = zeros(no_components, no_tasks);    % Whether maintenance is active or not.
endTimeMaintenance = zeros(no_components, no_tasks);    % EndTimes of maintenance, per component, per task.
RjPerComponent     = ones(no_components, 1);            % Reliability per component, per j-step.
HjPerComponent     = zeros(no_components, 1);           % Hazard per component, per j-step.

for i = 2:no_time_steps + 1
    reliabilitySystem = 1;
    hazardSystem      = 0;
    
    for n = 1:no_components
        [beta, eta] = FindWeibullOfComponentById(components{n, 1}, components);
        
        component_id = components{n,1};
        %relevant_maintenance_tasks = FindTasksByComponentId(component_id, tasks);
        
        m2 = 0;
        
        sumTaskDuration = 0;
        sumPartCost     = 0;
        
        for m = 1:no_tasks
            task                  = tasks(m, :);
            locationOfExecution   = task{1,3};
            affected_component_id = task{1, 7};
            
            % Empty check
            if(isempty(task{1,1}))
                continue;
            end;
                     
            % Check correct component
            if(component_id ~= affected_component_id)
                continue;
            end
                                
            % Start maintenance
            if(any(maintenanceTimes(m, :) == i))
                active_maintenance(n, m) = 1;
                endTimeMaintenance(n, m) = i + task{1, 4};
            end
            
            % Maintenance is ongoing.
            if(active_maintenance(n, m) == 1)
                 % Check location
                location = vesselLocation(i, 2);
                
                sumTaskDuration = sumTaskDuration + t_p;
                                
                % End Maintenance
                if(endTimeMaintenance(n, m) == i)
                    maintenanceTimePerComponent(n, size(maintenanceTimePerComponent(n, :), 2) + 1) = i;
                    m1(n, 1)                 = task{1, 8};
                    m2                       = m2 + task{1, 9};
                    active_maintenance(n, m) = 0;
                    sumPartCost              = task{1, 10};
                end
                
                % Check if still active and location.
                if(active_maintenance(n, m) == 1 && location ~= locationOfExecution)
                    return;
                end
            end
            
            
        end
        
        % Recalculate reliability
        j   = size(RjPerComponent(n, :), 2); % j-th
        tms = maintenanceTimePerComponent(n, :)';
        
        if(j == 1)
            ts = i; % Time since last maintenance.
        else
            ts = i - tms(end); % Time since last maintenance.
        end     
        
        tm = tms(end); % Time of next maintenance
        
        if(tm == 0)
            j = 1;
            [Rt, Rj] = ReliabilityT([], RjPerComponent(n, :)', 1, i, ts, i + 1, j, m1(n, 1), m2, eta, beta);
            [Ht, Hj] = FailureRateT([], HjPerComponent(n, :)', 0, i, ts, i + 1, j, m1(n, 1), m2, eta, beta);
        else
            [Rt, Rj] = ReliabilityT([], RjPerComponent(n, :)', 1, i, ts, tm, j, m1(n, 1), m2, eta, beta);            
            [Ht, Hj] = FailureRateT([], HjPerComponent(n, :)', 0, i, ts, tm, j, m1(n, 1), m2, eta, beta);
        end

        reliabilityComponent = Rt(end, 2);
        for k=1:size(Rj, 1)
            RjPerComponent(n, k) = Rj(k);
        end
        
        hazardComponent = Ht(end, 2);
        for k=1:size(Hj, 1)
            HjPerComponent(n, k) = Hj(k);
        end
        
        % Calculate system reliability and hazard
        PMCostComponent           = sumTaskDuration * costPerManhour + sumPartCost;
        
        timeFactor = 1;
        if(vesselLocation(i, 2) == 0)
            timeFactor = timeFactorAtSea;
        end
        
        CMCostComponent           = hazardComponent * t_p * (sumTaskDuration * (timeFactor) * (costPerManhour + penaltyCost) + sumPartCost);
        TotalCostComponent        = PMCostComponent + CMCostComponent;
        totalCostSystem           = totalCostSystem + TotalCostComponent;
        reliabilitySystem         = reliabilitySystem * reliabilityComponent; 
        hazardSystem              = hazardSystem + hazardComponent;
        reliabilityOverTime(i, n) = reliabilityComponent;
        hazardOverTime(i, n)      = hazardComponent;
    end
    
    plotTotalCost(i, 1)   = totalCostSystem;
    plotReliability(i, 1) = reliabilitySystem;
    plotHazard(i, 1)      = hazardSystem;
end