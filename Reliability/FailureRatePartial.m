function [ hj ] = FailureRatePartial(h_0_j, ts, m1, theta, beta)
    %RELIABILITYPARTIAL Generates a partial sesction of the reliability graph
    % h_0_j = Initial failure rate of the system at the jth stage.
    % t     = current time.
    % j     = No # of times maintenance done + 1;
    % m1    = improvement factor, as a factor of original life, 
    % 1 for no maintenance.
    % tp    = Time between maintenance
    % theta = Weibull scale parameter
    % beta  = Weibull shape parameter.
    
    hj = h_0_j + (1/m1) * beta/theta * (((((1/m1) * (ts)) / theta)^(beta-1)));
end

