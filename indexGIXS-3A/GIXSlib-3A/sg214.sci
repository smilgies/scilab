// spacegroup 214 (I 41 3 2) - single gyroid
function rule = sg214(h,k,l)
    
    // cubic
    h = abs(h)
    k = abs(k)
    l = abs(l)

    // rule 1: body centered
    // hkl: h+k+l=2n
    rule = pmodulo(h+k+l,2)==0;

    // rule 4: 4-fold screws along a,b,c
    // h00: h=4n
    r2a = k~=0 | l~=0 | pmodulo(h,4)==0;
    r2b = l~=0 | h~=0 | pmodulo(k,4)==0;
    r2c = h~=0 | k~=0 | pmodulo(l,4)==0;
    rule = rule & r2a & r2b & r2c;
                
    // rule 2 and 3 contained in rule 1
    
endfunction
