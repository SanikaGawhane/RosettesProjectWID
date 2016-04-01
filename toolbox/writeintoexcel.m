function[]=writeintoexcel()

% results_file = 'results_0401.xlsx';
col = {'Filename','Num_of_Ros_present','Num_of_ros_detected','Circularity','Avg_angle','MSE'};
%first_cell = 'A1';
xlswrite('results_0401.xlsx',col);%,1,'A1');

end