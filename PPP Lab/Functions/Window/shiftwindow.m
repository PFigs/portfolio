function window = shiftwindow(window,dim)
%SHIFTWINDOW shifts a window by one
    window(:,1:end-dim) = window(:,1+dim:end); 
end

