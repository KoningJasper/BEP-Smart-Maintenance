function [ Rj ] = ReliabilityPartial(R_0_j, ts, m1, theta, beta)
    %RELIABILITYPARTIAL Generates a partial sesction of the reliability graph
    % R_0_j = as defined in formula (4) of the Tsai paper.
    % t     = current time.
    % j     = No # of times maintenance done + 1;
    % m1    = improvement factor, as a factor of original life, 
    % 1 for no maintenance.
    % tp    = Time between maintenance
    % theta = Weibull scale parameter
    % beta  = Weibull shape parameter.
    
    Rj = R_0_j * exp(-((((1/m1) * (ts)) / theta)^beta));
end

