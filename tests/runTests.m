% runtests('dimConstructorTest');
% runtests('dimLinearPlusTest');
% runtests('dimLinearMinusTest');
% runtests('dimUminusTest');
% runtests('dimUplusTest');
% runtests('dimMtimesTest');
% runtests('dimDivideTest');
% 
% runtests('xfemmRemoveExtraNodesTest');
% runtests('xfemmRemoveExtraOverlappingArcSegmentsTest');
% runtests('xfemmRemoveExtraOverlappingSegmentsTest');
% runtests('xfemmRemovePartiallyOverlappingArcSegmentsCase1Test');
% runtests('xfemmRemovePartiallyOverlappingArcSegmentsCase2Test');
% runtests('xfemmRemovePartiallyOverlappingArcSegmentsCase3Test');
% runtests('xfemmRemovePartiallyOverlappingArcSegmentsCase4Test');
% runtests('xfemmRemovePartiallyOverlappingSegmentsTest');

%% KDH
%Jmag
runtests("test_data_beta_torque_map");
runtests('test_data_dq_map_motorcad')
runtests("test_Jmag_Current_import");
runtests("test_data_pk_beta_map");
runtests('test_JmagPWMsimulation_import')
% motorcad
runtests('testLossMapMotorcadExport')
testDataPkBetaPsiMotorcadExport

%comparison

% surf
runtests('test_data_dq_map_simul')
runtests('test_data_pk_beta_angle_map_motorcad')

% To be revised
runtests("test_dq_transform_measured")
runtests('test_dq_transforms_jmag')
runtests('test_dq_transforms_motorcad')
% not working

runtests("test_data_dq_map");
runtests('test_data_pk_beta_angle_map_motorcad')
testDutyCyclePlot
%% working on
testDataDqMapMotorcadExport

testDataPkBetaMotorcadMat
