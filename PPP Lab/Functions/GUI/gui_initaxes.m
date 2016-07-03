function handles = gui_initaxes(handles,varargin)

    % Populate axes
    hold(handles.leftaxes,'on');
    set(handles.leftaxes,'xlim',[-10 10]);
    set(handles.leftaxes,'ylim',[-10,10]);
    set(handles.leftaxes,'DrawMode','fast') 
    text(0,0,'East','Parent',handles.lxlabel)
    text(0,0,'North','rotation',90,'Parent',handles.lylabel)
    set(handles.rightaxes,'xlim',[-10 10]);
    set(handles.rightaxes,'ylim',[-10,10]);
    set(handles.rightaxes,'DrawMode','fast') 
    text(0,0,'East','Parent',handles.rxlabel)
    text(0,0,'North','rotation',90,'Parent',handles.rylabel)
    text(0,0,'East','Parent',handles.rxlabel)
    text(0,0,'North','rotation',90,'Parent',handles.rylabel)
    
end