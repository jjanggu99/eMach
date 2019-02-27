clc
clear

DRAW_MAGNET = 1;
DRAW_TIKZ   = 0;

%% Define cross sections

arc1 = CrossSectArc( ...
        'name', 'arc1', ...
        'dim_d_a', DimMillimeter(1), ...
        'dim_r_o', DimMillimeter(10), ...
        'dim_depth', DimMillimeter(10), ...
        'dim_alpha', DimDegree(45).toRadians(), ...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,0]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
    
trap1 = CrossSectTrapezoid( ...
        'name', 'trapezoid1', ...
        'dim_h', DimMillimeter(1), ...
        'dim_w', DimMillimeter(4), ...
        'dim_theta', DimDegree(60).toRadians(), ...
        'dim_depth', DimMillimeter(1), ...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,0]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
    
%% Define components

cs = [arc1 trap1];

comp1 = Component( ...
        'name', 'comp1', ...
        'crossSections', cs, ...
        'material', MaterialGeneric('name', 'pm'), ...
        'makeSolid', MakeSimpleExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(15)) ...
        );

%% Draw via MagNet

if (DRAW_MAGNET)
    toolMn = MagNet();
    toolMn.open(0,0,true);
    toolMn.setDefaultLengthUnit('millimeters', false);

    comp1.make(toolMn, toolMn);

    toolMn.viewAll();
end

%% Draw via TikZ

if (DRAW_TIKZ)
    toolTikz = TikZ();
    toolTikz.open('output.txt');

    comp1.make(toolTikz);

    toolTikz.close();
end
