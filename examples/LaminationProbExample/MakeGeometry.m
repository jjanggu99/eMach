% Lamination 

clc
clear
n = 5; %number of laminations

%TO DO: 
%   - add airbox
%   - assign mesh settings
%   - create coils


%% set up MagNet
toolMn = MagNet();
toolMn.open(0,0,true);
toolMn.setDefaultLengthUnit('millimeters', false);
    
%% Conductors

CsCleft = CrossSectSolidRect( ...
        'name', 'Cond1', ...
        'dim_w',DimMillimeter(2),....
        'dim_h',DimMillimeter(25),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,2.5]), ...
            'theta', DimDegree([0]).toRadians() ...
        ) ...
        );
    
CsCright = CrossSectSolidRect( ...
        'name', 'Cond2', ...
        'dim_w',DimMillimeter(2),....
        'dim_h',DimMillimeter(25),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([16,2.5]), ...
            'theta', DimDegree([0]).toRadians() ...
        ) ...
        );
    
condL = Component( ...
        'name', 'LeftCoil', ...
        'crossSections', CsCleft, ...
        'material', MaterialGeneric('name', 'Copper: 5.77e7 Siemens/meter'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(10)) ...
        );
condL.make(toolMn,toolMn);
toolMn.viewAll();

condR = Component( ...
        'name', 'RightCoil', ...
        'crossSections', CsCright, ...
        'material', MaterialGeneric('name', 'Copper: 5.77e7 Siemens/meter'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(10)) ...
        );

condR.make(toolMn,toolMn);
toolMn.viewAll();

%% Laminations
lamT = 10/n; %lamination thickness
for i = 1:n
    lamCS(i) = CrossSectSolidRect( ...
        'name', ['csLam' num2str(i)], ...
        'dim_w',DimMillimeter(lamT),....
        'dim_h',DimMillimeter(30),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([4 + lamT*(i-1),0]), ...
            'theta', DimDegree([0]).toRadians() ...
        ) ...
        );
    
    %REPLACE THE MATERIAL WITH A CONDUCTIVE STEEL MATERIAL MODEL
    compLam(i) = Component( ...
        'name', ['Lam' num2str(i)], ...
        'crossSections', lamCS(i), ...
        'material', MaterialGeneric('name', 'M19: USS Transformer 72 -- 29 Gage'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(10)) ...
        );
    
    compLam(i).make(toolMn,toolMn);
    toolMn.viewAll();
end

