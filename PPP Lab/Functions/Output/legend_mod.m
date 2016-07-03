function [leg,labelhandles,outH,outM]=legend_mod(source_axes,varargin)
%
%[Function Description]
%Wrapper for the built in 'legend' function to give a combined legend of
%multiple axes without having to send the handles of all the lines
%
%[Input Parameters]
%source_axes - array of handles of the axes whose legends have to be
%combined or one handle of a figure. In case of figure handle the program loops through all
%the axes in it and provides a combined legend
%Varargin - any options that built in 'legend' function takes
%
%[Output Parameters]
%Same as built in function
%
%[Author]
%Shreyes
%
%

labelhandles = [];
outH = [];
outM = [];

%If source_axes are empty the call is normal
if isempty(source_axes)
    [leg,labelhandles,outH,outM]=legend(varargin);
    return;
end

%Check if the handle is a figure
if length(source_axes) == 1
    src_type = get(source_axes,'Type');
    if strcmpi(src_type,'figure')        
        fg_child = get(source_axes,'Children');
        source_axes = [];
        for fg_child_cnt = 1:length(fg_child)
            fg_child_type = get(fg_child(fg_child_cnt),'Type');
            if strcmpi(fg_child_type,'Axes')
                source_axes(end + 1) = fg_child(fg_child_cnt); %#ok<AGROW>
            end
        end
    end
end

if isempty(source_axes)
    error('No Axes found');
end

line_h = [];

%Collect all the line handles
for ax_cnt = 1:length(source_axes)
    ax_child = get(source_axes(ax_cnt),'Children');
    for ax_child_cnt = 1:length(ax_child)
        h_type = get(ax_child(ax_child_cnt),'Type');
        if strcmpi(h_type,'line')
            line_h(end + 1) = ax_child(ax_child_cnt);
        end
    end
end


%Calling legend for the newly created axes with all the options specified
%by the user
leg = legend(line_h,varargin{:}); 

