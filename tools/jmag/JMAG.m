classdef JMAG < ToolBase & DrawerBase & MakerExtrudeBase & MakerRevolveBase
    %JMAG Encapsulation for the JMAG Designer of JSOL Corporation.
    %   TODO: add more description
    %   TODO: add more description
    %   TODO: add more description
    %   TODO: add more description
    
    properties (GetAccess = 'public', SetAccess = 'public')        
        jd;  % The activexserver object for JMAG Designer
        app = 0; % app = jd
        projName = 0; % The name of JMAG Designer project (a string)
        geomApp = 0; % The Geometry Editor object
        doc = 0; % The document object in Geometry Editor
        assembly = 0; % The assembly object in Geometry Editor
        sketch = 0; % The sketch object in Geometry Editor
        part = 0; % The part object in Geometry Editor
        model = 0; % The model object in JMAG Designer
        study = 0; % The study object in JMAG Designer
        view;  % The view object in JMAG Designer
        defaultLength = 'DimMeter'; % Default length unit is m
        defaultAngle = 'DimDegree'; % Default angle unit is degrees
        workDir = './';
        sketchList;
    end
    
    
    methods
        function obj = JMAG(varargin)
            obj = obj.createProps(nargin,varargin);            
            obj.validateProps();            
        end
        
        function obj = open(obj, Filename, Jd, Visible)
            %OPEN Open JMAG Designer or a specific file.
            %   open() opens a new instance of JMAG Designer with a new document.
            %
            %   open('filename') opens the file in a new instance of JMAG.
            %
            %   open('filename', jd) opens the file in the jd JMAG instance
            %
            %   open('filename', jd, VISIBLE) opens the file in the jd JMAG
            %   Designer instance with customizable visibility (true for visible)
            %
            %   iMn and Filename can be set to 0 to allow setting
            %   the visibility of a new instance.

            if nargin <= 1
                obj.jd = actxserver('designer.Application.181'); %JMAG version 18
            end
            
            % obj.jd now exists at this point
            if nargin > 2
                if isnumeric(Jd)
                    obj.jd = actxserver('designer.Application.181');
                end

                if Visible
                    obj.jd.Show();
                else
                    obj.jd.Hide();
                end
            end
            
            obj.workDir = './';
            obj.projName = 'proj';
            if nargin >= 1 && ~isnumeric(Filename)
                obj.jd.Open(strcat(obj.workDir, Filename, '.jproj'));
            else
                obj.jd.SaveAs(strcat(obj.workDir, obj.projName, '.jproj'));
            end
            
            obj.view = obj.jd.View();
            obj.app = obj.jd;
        end
        
        function obj = close(obj)
            obj.jd.Quit();
        end
        
        
        function [tokenDraw] = drawLine(obj, startxy, endxy)
            %DRAWLINE Draw a line.
            %   drawLine([start_x, _y], [end_x, _y]) draws a line

            if isnumeric(obj.sketch)
                obj.sketch = obj.getSketch(0);
                obj.sketch.OpenSketch();
            end
            
            % Convert to default units
            startxy = obj.convertLengthUnit(startxy,obj.defaultLength);
            endxy = obj.convertLengthUnit(endxy,obj.defaultLength);             
            
            line = obj.sketch.CreateLine(startxy(1),startxy(2),endxy(1),endxy(2));
            tokenDraw = TokenDraw(line, 0);
        end
        
        
        function [tokenDraw] = drawArc(obj, centerxy, startxy, endxy)
            %DRAWARC Draw an arc in the current JMAG document.
            %   drawarc(mn, [center_x,_y], [start_x, _y], [end_x, _y])
            %       draws an arc
            
            if isnumeric(obj.sketch)
                obj.sketch = obj.getSketch(0);
                obj.sketch.OpenSketch();
            end
            
            % Convert to default units
            centerxy = obj.convertLengthUnit(centerxy,obj.defaultLength);
            startxy = obj.convertLengthUnit(startxy,obj.defaultLength);
            endxy = obj.convertLengthUnit(endxy,obj.defaultLength);     
            
            obj.sketch.CreateVertex(startxy(1), startxy(2));
            obj.sketch.CreateVertex(endxy(1), endxy(2));
            obj.sketch.CreateVertex(centerxy(1), centerxy(2));
            arc = obj.sketch.CreateArc(centerxy(1), centerxy(2), ...
                                        startxy(1), startxy(2), ...
                                        endxy(1), endxy(2));
            tokenDraw = TokenDraw(arc, 1);
        end
        
        
        function geomApp = checkGeomApp(obj)
            if ~isnumeric(obj.geomApp)
            else
                obj.app.LaunchGeometryEditor();
                obj.geomApp = obj.app.CreateGeometryEditor(true);
                obj.doc = obj.geomApp.NewDocument();                
            end
            geomApp = obj.geomApp;
        end
        
        
        function sketch = getSketch(obj, Sketch, varargin)
            if isnumeric(Sketch)
                sketchName = strcat('mySketch', num2str(Sketch));
            else
                sketchName = Sketch;
            end

            for i = 1:length(obj.sketchList)
                if obj.sketchList(i) == sketchName
                    obj.sketch = obj.assembly.GetItem(sketchName);
                    % open sketch for drawing (must be closed before switch to another sketch)
                    obj.sketch.OpenSketch();
                    sketch = obj.sketch;
                    return
                end
            end
            if i == length(obj.sketchList)
                obj.sketchList(end) = sketchName;
            end
            
            obj.geomApp = obj.checkGeomApp();
            obj.doc = obj.geomApp.GetDocument();
            obj.assembly = obj.doc.GetAssembly();
            ref1 = obj.assembly.GetItem('XY Plane');
            ref2 = obj.doc.CreateReferenceFromItem(ref1);
            obj.sketch = obj.assembly.CreateSketch(ref2);
            obj.sketch.SetProperty('Name', sketchName)
            if nargin>2
                obj.sketch.SetProperty('Color', varargin);
            end         
            % Creating part from sketch
            obj.sketch.OpenSketch();
            ref1 = obj.assembly.GetItem(sketchName);
            ref2 = obj.doc.CreateReferenceFromItem(ref1);
            obj.assembly.MoveToPart(ref2);
            obj.part = obj.assembly.GetItem(sketchName);
            sketch = obj.sketch;
        end
        
        
        function select(obj)
           %SELECT Selects something from canvas (?)
            %    select()
            
            % TODO:
            % Implement this...
            %
            % This will need to take in arguments, or maybe
            % CrossSect objects which then store internally all their
            % lines and surfaces that need to be selected
        end
        
        
        function new = revolve(obj, name, material, center, axis, angle)
            %REVOLVE Revolve a cross-section along an arc    
            %new = revolve(obj, name, material, center, axis, angle)
            %   name   - name of the newly extruded component
            %   center - x,y coordinate of center point of rotation
            %   axis   - x,y coordinate on the axis of ration (negative reverses
            %             direction) (0, -1) to rotate clockwise about the y axis
            %   angle  - Angle of rotation (dimAngular) 
        end
        
        
        function extrudeSketch = extrude(obj, name, material, depth, csToken)
            ref1 = obj.sketch;
            obj.part.CreateExtrudeSolid(ref1,double(DimMeter(depth)))
            obj.part.SetProperty('Name', name)
            sketchName = strcat(name,'Sketch');
            obj.sketch.SetProperty('Name', sketchName)
            % Import Model into Designer
            obj.sketch = 0;
            obj.doc.SaveModel(true)
            
            if obj.study == 0
                obj.model = obj.app.GetCurrentModel();
                obj.model.SetName(obj.projName)
                % Create study
                obj.study = obj.model.CreateStudy('Transient', obj.projName);
            else
                % Delete old model
                obj.app.DeleteModel(obj.projName)
                % Setup the new model
                obj.model = obj.app.GetCurrentModel();
                obj.model.SetName(obj.projName)
                obj.study = obj.model.GetStudy(obj.projName);
            end
            
            % Set to default units
            obj.setDefaultLengthUnit(obj.defaultLength)
            obj.setDefaultAngleUnit(obj.defaultAngle)
            % Add material
            obj.study.SetMaterialByName(name, material)
            obj.app.Save()
            extrudeSketch = 0;
        end
        
        
        function sketch = prepareSection(obj, csToken)
            validateattributes(csToken, {'CrossSectToken'}, {'nonempty'});
            obj.doc.GetSelection().Clear();
            for i = 1:length(csToken.token)
                obj.doc.GetSelection().Add(obj.sketch.GetItem(csToken.token(i).segmentIndices.GetName()));
            end
            id = obj.sketch.NumItems();
            obj.sketch.CreateRegions();
            id2 = obj.sketch.NumItems();
            visItem = 1; % Set 1 to select only the visible (top layer) item
            itemType = 64; % Set 64 for region.
            obj.geomApp.View.SelectAtCoordinateDlg(double(DimMeter(csToken.innerCoord(1))), ...
                double(DimMeter(csToken.innerCoord(2))), 0, visItem, itemType);
            region = obj.doc.GetSelection.Item([0]);
            regionName = region.GetName;            
            
            regionList{1} = 'Region';
            for idx = 2:id2-id
                regionList{idx} = sprintf('Region.%d',idx);
            end
            
            for idx = 1:id2-id
                if ~strcmp(regionList{idx}, regionName)
                    obj.doc.GetSelection().Clear();
                    obj.doc.GetSelection().Add(obj.sketch.GetItem(regionList{idx}));
                    obj.doc.GetSelection().Delete();
                end
            end          
            obj.sketch.CloseSketch();
            sketch = 1;
        end        
        
        
        function setDefaultLengthUnit(obj, userUnit)
            %SETDEFAULTLENGTHUNIT Set the default unit for length.
            %   setDefaultLengthUnit(userUnit)
            %       Sets the units for length. 
            %   userUnit can be set to meters
  
            if strcmp(userUnit, 'DimMeter')
                obj.defaultLength = userUnit;
                obj.model.SetUnitCollection('SI_units')
            else
                error('unsupported length unit')
            end
        end
        
        function setDefaultAngleUnit(obj, userUnit)
            %SETDEFAULTANGLEUNIT Set the default unit for angle.
            %   setDefaultAngleUnit(userUnit)
            %       Sets the units for angle. 
            %   userUnit can be set to degrees
  
            if strcmp(userUnit, 'DimDegree')
                obj.defaultAngle = userUnit;
                obj.model.SetUnitCollection('SI_units')
            else
                error('unsupported angle unit')
            end
        end
        
        
        function convertedLength = convertLengthUnit(obj, length, userUnit)
            %CONVERTLENGTHUNIT Convert the units for length.
            %   convertLengthUnit(length,userUnit)
            %       Convert the units for length. 
            %   userUnit can be set to meters
  
            if strcmp(userUnit, 'meters')
                convertedLength = double(DimMeter(length));
            else
                error('unsupported length unit')
            end
        end
        
        
        function convertedAngle = convertAngleUnit(obj, angle, userUnit)
            %CONVERTANGLEUNIT Convert the units for angle.
            %   convertAngleUnit(angle, userUnit)
            %       Convert the units for angle. 
            %   userUnit can be set to degrees
  
            if strcmp(userUnit, 'degrees')
                convertedAngle = double(DimDegree(angle));
            else
                error('unsupported length unit')
            end
        end
        
        
        function setVisibility(obj, visibility)
            % Set visibility of the JMAG application
            if visibility == 1
               obj.jd.Show();
            else
                obj.jd.Hide();
            end
        end
    end
    
   
    methods(Access = protected)
         function validateProps(obj)
            %VALIDATE_PROPS Validate the properties of this component
             
            % Use the superclass method to validate the properties 
            validateProps@ToolBase(obj);   
            validateProps@DrawerBase(obj);
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