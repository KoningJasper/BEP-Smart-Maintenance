function [ Ht, Hj ] = FailureRateT(Ht, Hj, H0, t, tp, m1, m2, theta, beta)
    %FAILURERATET FaillureRate at time t
    
    % PARAMS
    % Ht    = Hazard against time
    % Hj    = Hazard against j-th step.
    % H0    = Initial hazard of the system.
    % t     = current time.
    % tp    = Time between maintenance
    % m1    = improvement factor, as a factor of original life, 
    % 1 for no maintenance.
    % m2    = improvement factor of failed components.
    % theta = Weibull scale parameter
    % beta  = Weibull shape parameter.

    % j     = No # of times maintenance done + 1;
    j = ceil(t / tp);
    
    % Check if still on initial maintenance. 
    if(j == 1)
        m1 = 1;
    end
    
    % Check if needs to do extra step.
    if(mod(t, tp) == 0)
        % Calc R_0_j
        m2_fac  = m2^j;                                                 % m2 compounds when doing maintenance multiple times.
        H_0_j   = Hj(j);                                                % Reliability of the system at the (j-1)th state, @ j-1 equals j because matlab indexes at 1.
        Htplus0 = FailureRatePartial(H_0_j, t, j, m1, tp, theta, beta); % Calculate reliability before maintenance.
        Htplus1 = Htplus0 + m2_fac*(H0 - Htplus0);                      % Reliability after maintenance
        
        % Output
        Ht      = [Ht; t Htplus0; t Htplus1];
        Hj      = [Hj; Htplus1];
    else
        % Calc next step
        H_0_j   = Hj(j);
        Htplus1 = FailureRatePartial(H_0_j, t, j, m1, tp, theta, beta);
        
        % Output
        Ht      = [Ht; t Htplus1];
    end
end

