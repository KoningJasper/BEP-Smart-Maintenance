function [ Schema ] = VaarschemaMakerFunctie( t_max,t_p)
%This function makes a sailing schedule for the time to be studied
%     In the VaarschamaMaker excel-file a randomized version has been made
%     of a provided sailing schedule. This has been done by determining the
%     duration of all the jobs and of all the breaks in a period of two
%     weeks. Assuming this gives a realistic spreading of jobs and breaks,
%     this has been extended untill there were 4000 jobs and 4000 breaks.
%     These have been put in a random order. In this function these random
%     breaks and jobs are put in the order as they would occur, according
%     to the workcycle provided. This function is only suitable for ships
%     with a fixed working cycle and should be altered according to the
%     working cycle of said ship, since the working cycle is not an input
%     in the function.

   
rest = 10; %h
work = 12; %h

M1 = cell2mat(DataReader('VaarschemaMaker.xls'));
M1 = round(M1*24/t_p);

no_workcycle = ceil(t_max/(rest+work)); %The number of work-cycles in t_max

Schema = zeros(round(t_max/t_p),2);
t_cycle = round((rest+work)/t_p); %Duration of a cycle in time-steps

for j = 1:no_workcycle 
    Schema((j-1)*t_cycle+1:ceil(10/t_p)+(j-1)*t_cycle,2)=3; 
    s = 1;
    g = ceil(rest/t_p)+1;
    while g<t_cycle
            type = mod(s,2)+1;
            f = g;
            g = g+M1(ceil(s/2),type);
            s = s+1;
            Schema(j*t_cycle-t_cycle+f:j*t_cycle-t_cycle+g,2) = 2-type;
    end
end

Schema(:,1) = (0:t_p:t_p*size(Schema,1)-t_p);

end








