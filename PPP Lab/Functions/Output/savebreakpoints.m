function savebreakpoints(varargin)
    breakpoints = dbstatus;
    save('savedreakpoints.mat', 'breakpoints');
end 