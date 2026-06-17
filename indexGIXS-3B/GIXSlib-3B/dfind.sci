function index=dfind(rule)
    
    // kludge: scilab 2023 to scilab 2026 incompatibility
    // in v2023 find produces always a row vector
    // in v2026 find produces a vector of the same shape as the input vector
    
    // rule is a boolean vector
    // index is a list of indices
    // no longer needed when win11 enterprise and scilab-2026 become compatible 
    
    test = find(rule)
    [r1,r2] = size(rule)
    [t1,t2] = size(test)
    if r1 > r2 & t1 < t2 then
        index = test';
    else
        index = test;
    end
endfunction
