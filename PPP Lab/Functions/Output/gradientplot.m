function gradientplot(ax,x,y,varargin)
% GRADIENTPLOT is a wrapper function for MATLAB's plot which plots data
% with a color gradient, drawing the most recent data (latter in the data
% vector) with a more saturated color
%   
%   INPUT
%   AXES     - Axes to plot data
%   X        - Vector of data to plot on the X axis
%   Y        - Vector of data to plot on the Y axis   
%   VARARGIN
%
%       'light'       - Color to apply to the older data
%
%       'dark'        - Color to apply to the newer data
%
%       'depth'       - Intensity of the gradient (a smaller number will imply a
%                       smoother transition). It must be bigger than 1.
%
%       'lightoffset' - A 1-by-3 row with values between 0 and 1 to apply
%                       an offset to the light color array (it can contain
%                       negative values). 
%                       NOTE: light array + offset
%
%       'darkoffset'  - A 1-by-3 row with values between 0 and 1 to apply
%                       an offset to the dark color array(it can contain
%                       negative values). 
%                       NOTE: dark array + offset
%
%   USAGE:
%
%
% Pedro Silva, Instituto Superior Tecnico, May 2012

    % Gradient step
    depth       = 4;
    light       = 'light blue';
    dark        = 'midnight blue';
    darkoffset  = [0 0 0];
    lightoffset = [0 0 0];
    
    if nargin >= 4 && ~mod(nargin-3,2)
       for i=1:2:size(varargin,2)
           if strcmpi(varargin{i},'dark')
               dark  = varargin{i+1};
           elseif strcmpi(varargin{i},'light')
               light = varargin{i+1};
           elseif strcmpi(varargin{i},'depth')
               if depth > 1
                   depth = varargin{i+1};
               end
           elseif strcmpi(varargin{i},'lightoffset')
               if all(abs(lightoffset) >= 0 & abs(lightoffset) <= 1)
                   lightoffset = varargin{i+1};
               end
           elseif strcmpi(varargin{i},'darkoffset')
               if all(abs(darkoffset) >= 0 & abs(darkoffset) <= 1)
                   darkoffset = varargin{i+1};
               end
           end
       end
    end
    
    
    if ~strcmp(dark,light)
        nbpoints   = length(x);
        if depth > nbpoints, depth = 2; end
        step       = fix(nbpoints/depth);
        tint       = zeros(depth+2,3);
        light      = rgb(light) + lightoffset;
        dark       = rgb(dark) + darkoffset;
        
        % Validate offset 
        if any(light < 0 | light > 1)
            light   = rgb(light); 
        end
        if any(dark < 0 | dark > 1)
            dark   = rgb(dark); 
        end
        
        % Creates gradient
        if light(1) ~= dark(1)
            tint(:,1) = light(1) : (dark(1)-light(1))/(depth+1) : dark(1);
        else
            tint(:,1) = ones(depth+2,1)*light(1);            
        end
        if light(2) ~= dark(2)
            tint(:,2) = light(2) : (dark(2)-light(2))/(depth+1) : dark(2);
        else
            tint(:,2) = ones(depth+2,1)*light(2);
        end
        if light(3) ~= dark(3)
            tint(:,3) = light(3) : (dark(3)-light(3))/(depth+1) : dark(3);
        else
            tint(:,3) = ones(depth+2,1)*light(3);
        end

        % Plots data to axis
        count = 1;
        for points = 1:step:nbpoints-step
            plot(ax,x(points:points+step-1),y(points:points+step-1),'.','color',tint(count,:));
            count = count + 1;
        end
        plot(ax,x(points+1:end),y(points+1:end),'.','color',tint(count,:));
    else
       plot(ax,x,y,'.','color',light); 
    end
end



