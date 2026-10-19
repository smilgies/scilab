// spacegroup 230 - Ia3d - double gyroid
function rule = sg230(h,k,l)
    
    // cubic
    h = abs(h)
    k = abs(k)
    l = abs(l)
        
    // body centered
    rule = pmodulo(h+k+l,2)==0;
    
    // rule 2: 4-fold screws along a,b,c 
    // h00: h=4n
    r2a = k~=0 | l~=0 | pmodulo(h,4)==0;
    r2b = l~=0 | h~=0 | pmodulo(k,4)==0;
    r2c = h~=0 | k~=0 | pmodulo(l,4)==0;
    rule = rule & r2a & r2b & r2c;
                
    // rule 3: diamond glides
    // hhl: 2h+l=4n (Bilbao)
    // cubic symmetry: same for (lkl ) and (hkk) families
    r3a = k~=l | pmodulo(2*k+h,4)==0;
    r3b = l~=h | pmodulo(2*l+k,4)==0; 
    r3c = h~=k | pmodulo(2*h+l,4)==0;
    rule = rule & r3a & r3b & r3c;    
    
    // rule 4: other glides
    // 0kl: k,l=2n (Bilbao)
    r4a = h~=0 | (pmodulo(k,2)==0 & pmodulo(l,2)==0);
    r4b = k~=0 | (pmodulo(l,2)==0 & pmodulo(h,2)==0);
    r4c = l~=0 | (pmodulo(h,2)==0 & pmodulo(k,2)==0);
    rule = rule & r4a & r4b & r4c
    
endfunction
