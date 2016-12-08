function [Rt, Rj] = ReliabilityT(Rt, Rj, R0, t, ts, tp, j, m1, m2, theta, beta)
    % RELIABILITYT Reliability at time t.
    
    % PARAMS
    % Rt    = Reliability against time
    % Rj    = Reliability against j-th step.
    % R0    = Initial reliability of the system.
    % t     = current time.
    % tp    = Time between maintenance
    % j     = Number of times maintenace has been done + 1;
    % m1    = improvement factor, as a factor of original life, 
    % 1 for no maintenance.
    % m2    = improvement factor of failed components.
    % theta = Weibull scale parameter
    % beta  = Weibull shape parameter.
    
    % Check if still on initial maintenance. 
    if(j == 1)
        m1 = 1;
    end
    
    % Check if needs to do extra step.
    if(mod(t, tp) == 0)
        % Calc R_0_j
        m2_fac  = m2^j;  % m2 compounds when doing maintenance multiple times.
        R_0_j   = Rj(j); % Reliability of the system at the (j-1)th state, @ j-1 equals j because matlab indexes at 1.
        Rtplus0 = ReliabilityPartial(R_0_j, ts, m1, theta, beta); % Calculate reliability before maintenance.
        Rtplus1 = Rtplus0 + m2_fac*(R0 - Rtplus0); % Reliability after maintenance
        
        % Output
        Rt      = [Rt; t Rtplus0; t Rtplus1];
        Rj      = [Rj; Rtplus1];
    else
        % Calc next step
        R_0_j   = Rj(j);
        Rtplus1 = ReliabilityPartial(R_0_j, ts, m1, theta, beta);
        
        % Output
        Rt      = [Rt; t Rtplus1];
    end
end

