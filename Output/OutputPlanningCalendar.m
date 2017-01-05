function [ output_args ] = OutputPlanningCalendar(startCalTimes, t_p, VesselLoc, Tasks)
    %OUTPUT Summary of this function goes here
    %   Detailed explanation goes here
    
    % Date black magics.
    c            = clock;
    dayCount     = ceil(size(VesselLoc, 1) / t_p / 24);
    today        = datenum(datetime('today'));
    endDate      = addtodate(today, dayCount, 'day');
    dateDiff     = endDate - today;
    diffVect     = datevec(dateDiff);
    monthCount   = diffVect(1,1) * 12 + diffVect(1,2);
    if(diffVect(1,3) > 0)
        monthCount = monthCount + 1;
    end
    currentYear  = c(1,1);
    currentMonth = c(1,2);
    extraYears   = 0;
    prevAddage   = 0;
    for i=currentMonth:(monthCount + currentMonth)
        n = i - extraYears * 12;
        if(n == 13)
            extraYears = extraYears + 1;
            n          = i - extraYears * 12;
        end
        calYear = currentYear + extraYears;
        
        c = calendar(calYear, n);
        % Calendar where each of the dates has been replaced with 1.
        oneCal = c; 
        oneCal(oneCal~=0) = 1;
        
        from = prevAddage .* oneCal + 24 * (c - oneCal);
        to   = prevAddage .* oneCal + 24 * c;
        
        calTasks = cell(6,7);
        % Itterate through calendar
        for x = 1:7
            for y=1:6
                if(c(y,x) == 0)
                    continue;
                end
                
                dayFrom = from(y, x);
                dayTo   = to(y, x);
                % Day starts at 24 hours.
                [tak, execution] = find(startCalTimes >= dayFrom & startCalTimes < dayTo);
                taks = {};
                if(~isempty(tak))
                    for t=1:size(tak, 1)
                        taks{t} = Tasks{tak(t), 2};
                    end
                end
                calTasks{y,x} = taks;
            end
        end
        disp('===========================');
        disp([num2str(calYear), ' - ', num2str(n)]);
        disp(calTasks);
        
        % Get maximum value in matrix. (max returns maximum in one
        % direction.)
        prevAddage = max(max(to));
    end
end