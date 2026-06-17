// reciprocal_lattice

// calculates the reciprocal lattice and switches to reciprocal mode

// dependencies
// - called by calc_spots

function [SRAs,SRBs,SRCs]=reciprocal_lattice(a,b,c,alf,bet,gam,H,K,L,s_fac)
    
    // volume of the unit cell and reciprocal lattice parameters (Authier)
    V = a*b*c*sqrt(1+2*cos(alf)*cos(bet)*cos(gam)-cos(alf)^2-cos(bet)^2-cos(gam)^2);

    as = 2*%pi*b*c*sin(alf)/V;
    bs = 2*%pi*a*c*sin(bet)/V;
    cs = 2*%pi*a*b*sin(gam)/V;

    alfs = acos((cos(bet)*cos(gam)-cos(alf))/abs(sin(bet)*sin(gam)));
    bets = acos((cos(gam)*cos(alf)-cos(bet))/abs(sin(gam)*sin(alf)));
    gams = acos((cos(alf)*cos(bet)-cos(gam))/abs(sin(alf)*sin(bet)));

    // reciprocal lattice vectors (Busing & Levy)

    As = [as;0;0];
    Bs = [bs*cos(gams);bs*sin(gams);0];
    Cs = [cs*cos(bets);-cs*sin(bets)*cos(alf);2*%pi/c];

    // indices and G vector of growth plane

    G = H*As+K*Bs+L*Cs;

    // rotate reciprocal lattice to make G parallel to surface normal (Smilgies & Blasini)
    // - phi: rotate G around z-axis so that G -> (x;0;z)
    // - chi: rotate G around y-axis so that G -> (0;0;z)

    phi = -atan(G(2),G(1));
    chi = -acos(G(3)/norm(G));

    R1 = [cos(phi) -sin(phi) 0; sin(phi) cos(phi) 0; 0 0 1];
    R2 = [cos(chi) 0 sin(chi);0 1 0;-sin(chi) 0 cos(chi)];    
    R  = R2*R1;

    // check: R*G=(0;0;z) >>> ok
    // disp(R*G)

    // shrinkage factor s_fac and shrink matrix S
    // used for uniaxial swelling (s_facf>1) or shrinking (s_fac<1)

    S = eye(3,3);    
    S(3,3) = 1/s_fac;    // S matrix in reciprocal space    

    // final reciprocal lattice vectors in surface reference frame

    SRAs = S*R*As;
    SRBs = S*R*Bs;
    SRCs = S*R*Cs;
    
endfunction
