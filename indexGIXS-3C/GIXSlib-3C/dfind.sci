function index=dfind(rule)
    
    // kludge: scilab 2023 to scilab 2026 incompatibility
    // in v2023 find produces always a row vector
    // in v2026.0.1 find produces a vector of the same shape as the input vector
    // in v2023.1.0 it's back to default (v2023); same for v2027.0.0
    // rule is a boolean vector
    // index is a list of indices
    // no longer needed when win11 enterprise and scilab-2026 become compatible 
    
    test = find(rule)
    [t1,t2] = size(test)
    if t1 < t2 then
        index = test';
    else
        index = test;
    end
endfunction
