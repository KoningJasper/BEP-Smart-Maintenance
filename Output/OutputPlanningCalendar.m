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
    nowVec       = datevec(datetime());
    filename     = strcat('Planning_', num2str(nowVec(1)), '_', num2str(nowVec(2)), '_', num2str(nowVec(3)), '_', num2str(nowVec(4)), '_', num2str(nowVec(5)), '_', num2str(round(nowVec(6))), '.xlsx');
    planningCell = cell(1,7);
    writeRow     = 1;
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
        planningCell{writeRow, 1} = strcat(num2str(calYear), ' - ', num2str(n));
        writeRow = writeRow + 1;
        planningCell(writeRow, :) = {'M', 'T', 'W', 'T', 'F', 'S', 'S'};
        writeRow = writeRow + 1;
        % Itterate through calendar
        for y = 1:6
            for x=1:7
                if(c(y,x) == 0)
                    continue;
                end
                
                dayFrom = from(y, x);
                dayTo   = to(y, x);
                % Day starts at 24 hours.
                [tak, ~] = find(startCalTimes >= dayFrom & startCalTimes < dayTo);
                taks = {};
                if(~isempty(tak))
                    for t=1:size(tak, 1)
                        taks{t} = Tasks{tak(t), 2};
                    end
                end
                calTasks{y,x} = taks;
                planningCell{writeRow, x} = strjoin({num2str(c(y,x)) strjoin(taks, char(10))}, char(10));
            end
            writeRow = writeRow + 1;
        end
        disp('===========================');
        disp([num2str(calYear), ' - ', num2str(n)]);
        disp(calTasks);
        
        % Get maximum value in matrix. (max returns maximum in one
        % direction.)
        prevAddage = max(max(to));
    end
    xlswrite(filename, planningCell);
end