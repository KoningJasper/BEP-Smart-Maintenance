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
        from = prevAddage .* ones(6,7) + 24 * (calendar(calYear, n) - ones(6, 7));
        to   = prevAddage .* ones(6,7) + 24 * calendar(calYear, n);
        %cal  = calendar(calYear, n);
        calTasks = cell(6,7);
        % Itterate through calendar
        for x = 1:7
            for y=1:6
                dayFrom = from(y, x);
                dayTo   = to(y, x);
                [tak, execution] = find(startCalTimes >= dayFrom && startCalTimes <= dayTo);
                taks = {};
                for t=1:size(tak, 1)
                    taks{t} = Tasks{tak(t), 2};
                end
                calTasks{y,x} = taks;
            end
        end
        disp('===========================');
        disp([num2str(calYear), ' - ', num2str(n)]);
        disp(calTasks);
        
        prevAddage = max(to);
    end
end