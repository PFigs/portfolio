function value = adxl345params( name )
%ADXL345PARAMS returns constants related to the adxl345
%
%   The following formula is used for determining the scale factor
%
%   Gs = Measurement Value * (G-range/(2^10)) 
%   or
%   Gs = Measurement Value * (8/1024)
%
%   Pedro Silva, Instituto Superior Tecnico, June 2012
    persistent scale_2g;
    persistent scale_4g;
    persistent scale_8g;
    persistent scale_16g;

    % Creates the scale factor +/-xg = 2x range
    if isempty(scale_2g)
        scale_2g = 4/1024;
    end
    
    if isempty(scale_4g)
        scale_4g = 8/1024;
    end
    
    if isempty(scale_8g)
        scale_8g = 16/1024;
    end
    
    if isempty(scale_16g)
        scale_16g = 24/1024;
    end
    
    % Returns the value
    if strcmpi(name,'scale2g')
        value = scale_2g;
    elseif strmcpi(name,'scale4g')
        value = scale_4g;
    elseif strmcpi(name,'scale8g')
        value = scale_8g;
    elseif strmcpi(name,'scale16g')
        value = scale_16g;
    end
    
end

