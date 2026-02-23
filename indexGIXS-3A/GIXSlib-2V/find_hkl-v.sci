// for indexGIXS-2X
// - vectorized hkl generation
// - vectorized space group checking
// - needs sg_info
// - called by calc_spot

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


function hkl_allowed=find_hkl(sg_info)

    // generate basic hkl set
    Hmax=round(evstr(sg_info(10)));
    Kmax=round(evstr(sg_info(11)));
    Lmax=round(evstr(sg_info(12)));

    Nmax=(2*Hmax+1)*(2*Kmax+1)*(2*Lmax+1);   // number of generated spots

    hkl=[];
    for hn=-Hmax:Hmax,
        for kn=-Kmax:Kmax,
            for ln=-Lmax:Lmax,
                hkl=[hkl;hn,kn,ln];
            end
        end
    end

    // note: h,k,l are vectors
    h = hkl(:,1);
    k = hkl(:,2);
    l = hkl(:,3);
    
    // apply index rulea    
    select index_rule
    case "P"
        // all indices allowed
        index = [1:Nmax]';
        rule = ones(index)==1;
    case "C"
        rule = pmodulo(h+k,2)==0;
        // dfind allowed reflections
        index=dfind(rule)
    case "A"
        rule = pmodulo(k+l,2)==0;
        // dfind allowed reflections
        index=dfind(rule)
    case "B"
        rule = pmodulo(l+h,2)==0;
        // dfind allowed reflections
        index=dfind(rule)
    case "F"
        r1 = pmodulo(h+k,2)==0;
        r2 = pmodulo(k+l,2)==0;
        r3 = pmodulo(l+h,2)==0;
        // element-wise and operator
        rule = r1 & r2 & r3
        // dfind allowed reflections
        index=dfind(rule)
    case "I"
        rule = pmodulo(h+k+l,2)==0;
        // dfind allowed reflections
        index=dfind(rule)
    case "sc"
        // all indices allowed
        index=[1:Nmax]'
    case "bcc"
        rule = pmodulo(h+k+l,2)==0;
        // dfind allowed reflections
        index=dfind(rule)
    case "fcc"
        r1 = pmodulo(h+k,2)==0;
        r2 = pmodulo(k+l,2)==0;
        r3 = pmodulo(l+h,2)==0;
        // element-wise and operator
        rule = r1 & r2 & r3
        // dfind allowed reflections
        index=dfind(rule)
    case "hcp"
        r1 = pmodulo(h+2*k,3)==0;
        r2 = pmodulo(l,2)==1;
        rule= ~(r1 & r2)
        // dfind allowed reflections
        index = dfind(rule)
    case "dia"
        r1 = pmodulo(h+k,2)==0;
        r2 = pmodulo(k+l,2)==0;
        r3 = pmodulo(l+h,2)==0;
        r4 = r1 & r2 & r3;
        // for all even hkl
        test = h+k+l;
        r5 = pmodulo(test,2)==0 & pmodulo(test,4)==0;
        rule = r4 & r5; 
        // dfind allowed reflections
        index = dfind(rule);
    case "sgl gyr"
        rule = sg214(h,k,l);
        index=dfind(rule)
    case "dbl gyr"
        rule = sg230(h,k,l);
        index=dfind(rule)
    case "cyl"
        index = 1:Nmax
    case "lam"
        index = 1:Nmax
    else
        messagebox("error: unknown index rule")
    end


    // only for Bravais lattices (P,C,F,I): screw axes and glide planes
    // note: one instance of the rules is defined above

    bravais = ["P","C","A","B","F","I"];
    brav_flag = or(index_rule==bravais);

    // only run if srew or glide is set
    sg_info_def=[">>>";"1";"1";"1";">>>";"none";"none";"none"];
    sg_flag = ~and(sg_info(1:8)==sg_info_def);
    
    if brav_flag & sg_flag then
                
        // screw axes
        a_screw = evstr(sg_info(2));
        b_screw = evstr(sg_info(3));
        c_screw = evstr(sg_info(4));
        
        // [100] axis          
        if a_screw > 1 then
            r = k~=0 | l~=0 | pmodulo(h,a_screw)==0;
            rule = rule & r
        end
        // [010] axis
        if b_screw > 1 then 
            r = l~=0 | h~=0 | pmodulo(k,b_screw)==0;
            rule = rule & r
        end
        // [001] axis
        if c_screw > 1 then
            r = h~=0 | k~=0 | pmodulo(l,c_screw)==0;
            rule = rule & r
        end

        // glide planes
        a_glide=sg_info(6);
        b_glide=sg_info(7);
        c_glide=sg_info(8);

        // (100) plane
        // note: there
        select a_glide
        case "none"
            r = rule
        case "a/b"                
            r = h~=0 | pmodulo(k,2)==0;
        case "a/c"
            r = h~=0 | pmodulo(l,2)==0;
        case "a/n"
            r = h~=0 | pmodulo(k+l,2)==0;
        end
        rule = rule & r;

        // (010) plane (default)

        select b_glide
        case "none"
            r = rule;
        case "b/c"
            r = k~=0 | pmodulo(l,2)==0;
        case "b/a"
            r = k~=0 | pmodulo(h,2)==0;
        case "b/n"
            r = k~=0 | pmodulo(l+h,2)==0;
        end
        rule = rule & r;

        // (001) plane
        select c_glide
        case "none"
            r = rule;
        case "c/a"
            r = l~=0 | pmodulo(h,2)==0;
        case "c/b"
            r = l~=0 | pmodulo(k,2)==0;
        case "c/n"
            r = l~=0 | pmodulo(h+k,2)==0;
        end
        rule = rule & r;

        // extra sg rule only applied for Bravais lattices
        index = dfind(rule);
    end

    // return only allowed hkl as listed in index
    hkl_allowed=hkl(index,:);

endfunction


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

