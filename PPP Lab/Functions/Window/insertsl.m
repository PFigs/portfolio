function window = insertsl( value, window, dim )
%INSERTSR shifts DIM times a window and iserts VALUE into it

    window        = shiftwindow(window,abs(dim));
    window(:,end) = value;

end

