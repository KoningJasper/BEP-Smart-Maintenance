function GatherOutput(FR_TC, components)
%{
GATHEROUTPUT Summary of this function goes here
 %}

no_components = size(components, 1);

% Calculate system failure rate
runningHourmax = size(FR_TC, 2);
systemFailureRateOverTime = zeros(runningHourmax, 1);
for i = 1 : runningHourmax
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
plot(systemFailureRateOverTime);
title('System failure-rate over running-hours');
xlabel('Running-Hours (h)');
ylabel('Failures per running hour');
xlim([0 runningHourmax]);

%figure of component failure rate
figure;
for i = 1:no_components
    hold on;
    plot(FR_TC(i, :));
end
title('Failure-rate per component running-hour'); 
legend(components(:, 2), 'Location', 'NorthWestOutside');
xlim([0 runningHourmax]);
xlabel('Time (h)');
ylabel('Failures per running-hour');
    

end

