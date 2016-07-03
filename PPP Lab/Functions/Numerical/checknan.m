function val = checknan( val )
%CHECKNAN checks if VAL is NaN and sets it to zero

    if any(isnan(val))
        val = 0;
    end

end

