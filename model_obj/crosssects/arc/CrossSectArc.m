classdef CrossSectArc < CrossSectBase
    %CROSSSECTARC Describes an arc of a hollow cylinder.
    %   Properties are set upon class creation and cannot be modified.
    %   The anchor point for this is the center of the circle that this arc
    %   lies upon, with the x axis pointing toward the arc center.
    
    
    properties (GetAccess = 'public', SetAccess = 'protected')
        dim_d_a;    %Thickness of the arc: class type dimLinear. If 
        dim_r_o;    %Outer radius of the arc: class type dimLinear
        dim_alpha;  %Angular span of the arc: class type dimAngular
        dim_depth;  %Axial depth of the arc: class type dimLinear
    end
    
    methods
        function obj = CrossSectArc(varargin)
            obj = obj.createProps(nargin,varargin);            
            obj.validateProps();            
        end
        
        function [csToken] = draw(obj, drawer)
            validateattributes(drawer, {'Drawer2dBase'}, {'nonempty'});
            
            t = obj.dim_d_a;
            r = obj.dim_r_o;
            alpha = obj.dim_alpha.toRadians();
            
            x_out = r*cos(alpha/2);
            x_in = (r-t)*cos(alpha/2);
            x = [x_out, x_out, x_in, x_in];
            
            y_out = r*sin(alpha/2);
            y_in = (r-t)*sin(alpha/2);
            y = [-y_out, y_out, y_in, -y_in];
            
            [x_trans, y_trans] = obj.location.transformCoords(x,y);
            
            p1 = [x_trans(1), y_trans(1)];
            p2 = [x_trans(2), y_trans(2)];
            p3 = [x_trans(3), y_trans(3)];
            p4 = [x_trans(4), y_trans(4)];
            
            [arc_out] = drawer.drawArc(obj.location.anchor_xy, p1, p2);
            [line_cc] = drawer.drawLine(p2,p3);
            [arc_in] = drawer.drawArc(obj.location.anchor_xy, p4, p3);
            [line_cw] = drawer.drawLine(p4, p1);

            %calculate a coordinate inside the surface
            rad = obj.dim_r_o - obj.dim_d_a/2;
            innerCoord(1) = rad*cos(rotate_xy) + shift_xy(1);
            innerCoord(2) = rad*sin(rotate_xy) + shift_xy(2);
            %note: this will be much, much improved by using Nick's new
            %Location2D class.....
            
            segments = [arc_out, arc_in, line_cc, line_cw];
            csToken = CrossSectToken(innerCoord, segments);
        end
        
        function select(obj)
            
        end

    end
    
     methods(Access = protected)
         function validateProps(obj)
            %VALIDATE_PROPS Validate the properties of this component
             
            %1. use the superclass method to validate the properties 
            validateProps@CrossSectBase(obj);   
            
            %2. valudate the new properties that have been added here
            validateattributes(obj.dim_d_a,{'DimLinear'},{'nonnegative','nonempty'})            
            validateattributes(obj.dim_r_o,{'DimLinear'},{'nonnegative','nonempty'})
            validateattributes(obj.dim_depth,{'DimLinear'},{'nonnegative', 'nonempty'})
            validateattributes(obj.dim_alpha,{'DimAngular'},{'nonnegative', 'nonempty', '<', 2*pi})
         end
                  
         function obj = createProps(obj, len, args)
             %CREATE_PROPS Add support for value pair constructor
             
             validateattributes(len, {'numeric'}, {'even'});
             for i = 1:2:len 
                 obj.(args{i}) = args{i+1};
             end
         end
     end
end

