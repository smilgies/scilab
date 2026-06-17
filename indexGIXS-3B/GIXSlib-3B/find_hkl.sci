///////////////////////////////////////////////////////////////////////
// generate list of space group allowed indices

// - vectorized hkl generation
// - vectorized space group checking
// - needs sg_info
// - called by calc_spots

function hkl_allowed=find_hkl(sg_info)

    // generate basic hkl set
    
    // limits of index range
    Hmax=round(evstr(sg_info(10)));
    Kmax=round(evstr(sg_info(11)));
    Lmax=round(evstr(sg_info(12)));

    // number of generated spots
    Nmax=(2*Hmax+1)*(2*Kmax+1)*(2*Lmax+1);   

    // complete hkl list
    hkl=[];
    for hn=-Hmax:Hmax,
        for kn=-Kmax:Kmax,
            for ln=-Lmax:Lmax,
                hkl=[hkl;hn,kn,ln];
            end
        end
    end

    // apply index rules
    
    // note: h,k,l are column vectors of hkl
    h = hkl(:,1);
    k = hkl(:,2);
    l = hkl(:,3);
    
    // apply index rulea    
    select index_rule
    case "P"
        // all indices allowed
        rule = ones([1:Nmax])==1;
    case "C"
        rule = pmodulo(h+k,2)==0;
    case "A"
        rule = pmodulo(k+l,2)==0;
    case "B"
        rule = pmodulo(l+h,2)==0;
    case "F"
        r1 = pmodulo(h+k,2)==0;
        r2 = pmodulo(k+l,2)==0;
        r3 = pmodulo(l+h,2)==0;
        // element-wise and operator
        rule = r1 & r2 & r3
    case "I"
        rule = pmodulo(h+k+l,2)==0;
    case "sc"
        // all indices allowed
        rule = ones([1:Nmax])==1;
    case "bcc"
        rule = pmodulo(h+k+l,2)==0;
    case "fcc"
        r1 = pmodulo(h+k,2)==0;
        r2 = pmodulo(k+l,2)==0;
        r3 = pmodulo(l+h,2)==0;
        // element-wise and operator &
        rule = r1 & r2 & r3;
    case "hcp"
        r1 = pmodulo(h+2*k,3)==0;
        r2 = pmodulo(l,2)==1;
        rule= ~(r1 & r2);
    case "dia"
        r1 = pmodulo(h+k,2)==0;
        r2 = pmodulo(k+l,2)==0;
        r3 = pmodulo(l+h,2)==0;
        r4 = r1 & r2 & r3;
        // for all even hkl
        test = h+k+l;
        r5 = pmodulo(test,2)==0 & pmodulo(test,4)==0;
        rule = r4 & r5; 
    case "sgl gyr"
        rule = sg214(h,k,l);
    case "dbl gyr"
        rule = sg230(h,k,l);
    case "cyl"
        rule = ones([1:Nmax])==1;
    case "lam"
        rule = ones([1:Nmax])==1;
    else
        messagebox("error: unknown index rule")
    end
    
    // list of allowed indices out of hkl when rule is true
    // - dfind is a modified find fcn 
    //   due to differences between scilab 2023 and 2026 
    index = dfind(rule);


    ///////////////////////////////////////////////////////////////////
    // only for Bravais lattices (P,C,F,I): screw axes and glide planes

    // only run for Bravais lattices
    bravais = ["P","C","A","B","F","I"];
    brav_flag = or(index_rule==bravais);

    // only run if screw or glide is set
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
            rule = rule & r;
        end
        // [010] axis
        if b_screw > 1 then 
            r = l~=0 | h~=0 | pmodulo(k,b_screw)==0;
            rule = rule & r;
        end
        // [001] axis
        if c_screw > 1 then
            r = h~=0 | k~=0 | pmodulo(l,c_screw)==0;
            rule = rule & r;
        end

        // glide planes
        a_glide=sg_info(6);
        b_glide=sg_info(7);
        c_glide=sg_info(8);

        // (100) plane
        // note: there
        select a_glide
        case "none"
            r = rule;
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

        // extra sg rule only applied to Bravais lattices
        index = dfind(rule);
    end

    // return only allowed hkl as listed in index
    hkl_allowed=hkl(index,:);

endfunction
