clc
clear   

% Create FemmProblem
toolXFEMM = XFEMM();
toolXFEMM.newFemmProblem(0,'planar','millimeters');

% Draw two partially overlapping segments  
toolXFEMM.drawLine([10 0],[30 20]);
toolXFEMM.drawLine([20 10],[40 30]);

% Remove all segments and add new non-overlapping segments
FemmProblem = toolXFEMM.removeOverlaps();  
toolXFEMM.plot();

% We know that 2 segment should be removed and 3 segments should be added
if length(FemmProblem.Segments) == 3
    fprintf('TEST PASSED!\n');
else
    fprintf('TEST FAILED\n');
end

% You can manually go and look at FemmProblem struct to ensure there are no
% partially overlapping segments anymore
