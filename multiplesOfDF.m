function result = multiplesOfDF(baseFreq, dF, N)
    % returns an array of N frequencies that are multiples of dF, starting
    % from baseFreq
    
    result = [];
    
    for i = 1 : N
        nextFreq = baseFreq + (i * dF);
        result = [result nextFreq];
    end
    
end
