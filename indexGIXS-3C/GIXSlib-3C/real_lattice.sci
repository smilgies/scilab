function [a,b,c,alf,bet,gam,s_fac]=real_lattice(aspar,bspar,gamspar,asperp,bsperp,csperp)

    // reciprocal surface lattice
    SRAs = [aspar;0;asperp];
    SRBs = [bspar*cos(gamspar);bspar*sin(gamspar);bsperp];
    SRCs = [0;0;csperp];

    // lattice vectors of real space lattice

    Vrec = (cross(SRAs,SRBs)'*SRCs);
    A = 2*%pi*cross(SRBs,SRCs)/Vrec;
    B = 2*%pi*cross(SRCs,SRAs)/Vrec;
    C = 2*%pi*cross(SRAs,SRBs)/Vrec;

    // real space lattice constants
    
    a = norm(A);
    b = norm(B);
    c = norm(C);
    alf = acos((B'*C)/(b*c));
    bet = acos((C'*A)/(c*a));
    gam = acos((A'*B)/(a*b));
    s_fac = 1;
    
    // note: HKL and s remain unchanged 
    // and have no effect on lattice parameters

endfunction



