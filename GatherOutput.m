function GatherOutput(FRT, FR0, input, t_max, t_p, components, Tasks, vesselLoc, forwardBias, maximumBias, MCH, PCH, timeFactorAtSea)
%{
GATHEROUTPUT Summary of this function goes here
    Detailed explanation goes here

    PARAMS
    bool forwardBias = true geeft wanneer de oplossing niet kan wordt er
    eerst gezocht naar oplossing die verder weg zijn niet dichterbij. Bij
    false andersom.
    double maximumBias = 0<maximumBias<1; is de maximum afwijking, factor,
    die wordt afgeweken van het interval.


 %}

    % Pre-Calc %
    no_components = size(components, 1);
    no_tasks      = size(Tasks, 1);
    no_time_steps = t_max/t_p;

    % Pre-alloc %
    maintenanceTimes      = zeros(no_components, no_tasks);                 % Start times of maintenance, per component;
    endTimeMaintenance    = cell(no_components, no_tasks);                  % EndTimes of maintenance, per component
    noComponentMainte     = ones(no_components, 1);                         %
    maintTimePerComponent = zeros(no_components, 1);                        %
%     FailureRepairTimes    = cell2mat(components(:, 6));                     %
%     SignificanceIndices   = cell2mat(components(:, 5));                     %

    %% check
    
    interval = cell2mat(input) .* cell2mat(Tasks(:, 6));                    % in time(h)
    
    for i = 1:no_tasks               
        no_executed_maintenance = floor(no_time_steps/interval(i));         %how many times will a task be executed

        % check if time of maintance is possible
        for j = 1:no_executed_maintenance                                   
            tijdstip = floor(j*interval(i));
            if(tijdstip <= 1)                                               %Time check t > 0
                tijdstip = 1;
            end

            if (vesselLoc(tijdstip, 2) ~= 1)                                %0 is at sea, 1 is in port, so if answer gives a 1 the schedule is not possible. 
                ht = floor(tijdstip);
                
                % Check possible solutions later than t;
                if(forwardBias == true)
                    endTime = (1 + maximumBias) * interval(i);

                    if(j > 1)
                        if(endTime >= (maintenanceTimes(i, j-1) + Tasks{i, 6}))
                            endTime = Tasks{i, 6};
                        end
                        endTime = endTime + maintenanceTimes(i, j - 1);
                    else
                        if(endTime >= Tasks{i, 6})
                            endTime = Tasks{i, 6};
                        end
                    end
                    tijdstip = findMaintenanceTime(ht, endTime, t_p, vesselLoc, Tasks{i, 4});
                end

                % Check possible solutions earlier than t;
                if(forwardBias == false)
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
                    tijdstip = findMaintenanceTime(startTime, ht, t_p, vesselLoc, Tasks{i,4});
                end

%{
                if(tijdstip == 0)
                   totalCost = realmax('single');
                   return;
                    
                else
                    % Solution found.
                    maintenanceTimes(i,j) = tijdstip;
                    component_id = Tasks{i, 7};
                    endTimeMaintenance{component_id, noComponentMainte(component_id, 1)} = [tijdstip + Tasks{i, 4}, i];
                    noComponentMainte(component_id, 1) = noComponentMainte(component_id, 1) + 1;
                    maintTimePerComponent(component_id, 1) = maintTimePerComponent(component_id, 1) + Tasks{i, 4};
                end
            else
%}
                % This time is valid.
                maintenanceTimes(i, j) = tijdstip;
                component_id = Tasks{i, 7};
                endTimeMaintenance{component_id, noComponentMainte(component_id, 1)} = [tijdstip + Tasks{i, 4}, i];
                noComponentMainte(component_id, 1) = noComponentMainte(component_id, 1) + 1;
                maintTimePerComponent(component_id, 1) = maintTimePerComponent(component_id, 1) + Tasks{i, 4};
            end
        end
    end

   %% Integrate over Time %
    FR_TC = zeros(no_components, t_max + 1);                                 %failureRate over time of each component(FR_TC)
    
    for i = 1:no_components
        endTimes = endTimeMaintenance(i, :);
        endTimes = endTimes(~cellfun('isempty', endTimes));

        FR_TC(i, :) = FR0(i, :);

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

            if(time > t_max)                                                %saftey check if times(t) is bigger as t_max
                continue;
            end

            rest_time = t_max + 1 - time + 1;
            shift     = FR_TC(i, time);
            m2        = Tasks{id, 9};
            shift     = shift + m2 * (0 - shift);
            FR_TC(i, time:end) = FRT(id, 1:rest_time) + shift;
        end
    end

 %{
 %Find total cost.
    componentFailures = zeros(no_components, 1);
    for i=1:no_components
        componentFailures (i) = trapz(FailureRateOverTimePerComponent(i, :)); % Integrate
    end
    TotalSignificance = sum(SignificanceIndices);

    Cost_CM   = SignificanceIndices .* FailureRepairTimes .*
    componentFailures .* timeFactorAtSea .* PCH  ./ TotalSignificance; %
    Cost_PM   = maintTimePerComponent .* MCH;
    totalCost = sum(Cost_CM + Cost_PM);

 %}

    systemFailureRateOverTime = zeros(t_max, 1);
    for i = 1 : t_max
        systemFailureRateT = 1;
        for n=1:no_components
            systemFailureRateT = systemFailureRateT * (1 - FR_TC(n, i));
        end
        systemFailureRateT = 1 - systemFailureRateT;
        systemFailureRateOverTime(i, 1) = systemFailureRateT;      
    end
    
  %% making figures with results
  
% figure of total system failure rate
figure;
title('System failure-rate');
plot(systemFailureRateOverTime);
xlabel('Time (h)');
ylabel('Failures per hour');
xlim([0 t_max]);

%figure of component failure rate
figure;
title('Failure-rate per component'); 
for i = 1:no_components
    hold on;
    plot(FR_TC(i, :));
end

legend(components(:, 2), 'Location', 'NorthWestOutside');
xlim([0 t_max]);
xlabel('Time (h)');
ylabel('Failures per hour');
    

end

