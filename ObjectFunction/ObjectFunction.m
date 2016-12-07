function [ Output_Objective, plotLambda, plotObj, lambdaOverTime, maintenanceTimes] = ObjectFunction(input, t_max, t_p, components, tasks, vesselLocation, forwardBias, maximumBias)

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
plotObj          = ones(no_time_steps + 1, 1);
plotLambda       = ones(no_time_steps + 1, 1);
lambdaOverTime   = ones(no_time_steps + 1, no_components);
maintenanceTimes = ones(no_tasks, 1);                       % Times at which maintenance occurs.

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
        
        if (vesselLocation{tijdstip, 1} ~= 1)  %0 is op zee, 1 is in de haven
            % Deze planning kan dus niet omdat het schip dan op zee is.
            % Verzin een nieuwe oplossing.
            
            % Check possible solutions later than t;
            if(forwardBias == true)
                endTime = (1 + maximumBias) * interval(i);
                if(endTime >= 1)
                    endTime = tasks{i, 6};
                end
                tijdstip = findMaintenanceTime(tijdstip, endTime, t_p, vesselLocation);
            end
            
            % Check possible solutions earlier than t;
            if(tijdstip == 0 || forwardbias == false)
                startTime = (1 - maximumBias) * interval(i);
                if(startTime <= 0)
                    startTime = 0;
                end
                tijdstip = findMaintenanceTime(startTime, tijdstip, t_p, vesselLocation);
            end
            
            if(tijdstip == 0)
                % No solution found.
                Output_Objective = 0;
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
Output_Objective   = 0;
m1                 = ones(no_components, 1);
active_maintenance = zeros(no_components, no_tasks);
endTimeMaintenance = zeros(no_components, no_tasks);

for i = 2:no_time_steps + 1
    lambda_system = 1;
    
    for n = 1:no_components
        [beta, eta] = FindWeibullOfComponentById(components{n, 1}, components);
        
        component_id = components{n,1};
        %relevant_maintenance_tasks = FindTasksByComponentId(component_id, tasks);
        
        m2 = 0;
        
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
                location = vesselLocation{i, 1};
                
                if(location ~= locationOfExecution)
                    Output_Objective = 0; % Possibly reschedule.
                    return;
                end
                
                % Reduce availability with working time
                Output_Objective = Output_Objective - t_p;
                
                % End Maintenance
                if(endTimeMaintenance(n, m) == i)
                    m1(n, 1) = task{1, 8};
                    m2       = m2 + task{1, 9};
                    active_maintenance(n, m) = 0;
                end
            end
            
            
        end
        
        % Recalculate reliability
        lambda_component = 1 - FailureRateN(t_p, beta, eta, m1(n, 1), 1 - lambdaOverTime(i - 1, n));
        
        % Add (m2) jump
        if(m2 + lambda_component >= 1)
            lambda_component = 1;
        else
            lambda_component = lambda_component + m2;
        end
        
        % Calculate system reliability
        lambda_system        = lambda_system * lambda_component; 
        lambdaOverTime(i, n) = lambda_component;
    end

    Output_Objective = Output_Objective + lambda_system * t_p;
    plotLambda(i, 1) = lambda_system;
    plotObj(i, 1)    = Output_Objective;  
end

plotLambda = plotLambda(:, 1);
plotObj    = plotObj(:, 1);
