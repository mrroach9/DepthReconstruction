function r = reliability(match)
    peaks = findpeaks([0 match 0], 'sortstr', 'descend');
    if isempty(peaks)
    	r = 0;
        return;
    end;
    r = peaks(1);
    if length(peaks) >= 2
        r = r - 0.8*peaks(2)/peaks(1);
    end;
end