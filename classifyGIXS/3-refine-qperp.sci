////////////////////////////////////////////////////////////////////
// refine qperp

// for ZnPc example
// initial values for asperp, bsperp, csperp were determined with indexGIXS
//   based on the (10l) and (01l) scattering rods
// l-values of spots were determined with indexGIXS
//
// input format:
// reflection list hkl: h k l qperp qpar
// select well-defined reflections for each rod

hkl = [-1 0 0 1.25 4.65];
hkl = [hkl; 1 0 1 18.15 4.65];

hkl = [hkl; 0 1 0 2.35 4.65];
hkl = [hkl; 0 -1 1 17.1 4.65];

hkl = [hkl; -1 1 0 3.7 6.1];
hkl = [hkl; 1 -1 1 15.8 6.1];

hkl = [hkl; 1 1 0 1.0 7.1];
hkl = [hkl; -1 -1 1 18.4 7.1];

hkl = [hkl; 0 2 0 4.7 9.3];   
hkl = [hkl; 0 -2 1 14.7 9.3];     

hkl = [hkl; -1 2 0 6.0 9.8];
hkl = [hkl; 1 -2 1 13.3 9.8];     

hkl = [hkl; 2 -1 1 14.35 9.8];    

hkl = [hkl; -2 -1 0 0.2 11.0];
hkl = [hkl; 2 1 1 19.15 11.0];    

hkl = [hkl; 2 -2 1 11.9 14.0];    

hkl = [hkl; -3 1 0 6.35 14.0];    

hkl = [hkl; 0 -3 1 12.2 14.0];    

hkl = [hkl; 1 3 0 5.7 15.4];      

hkl = [hkl; 2 3 0 4.3 17.9];

hkl = [hkl; -3 3 0 11.1 18.2];

hkl = [hkl; -1 4 0 10.85 18.5];

hkl = [hkl; -4 -1 0 2.9 18.7];

hkl = [hkl; 3 3 0 3.0 21.1];

hkl = [hkl; 3 -4 1 5.7 21.5];

hkl = [hkl; 4 -3 1 6.75 21.5]

////////////////////////////////////////////////
// decompose hkl

h = hkl(:,1);
k = hkl(:,2);
l = hkl(:,3);
qz  = hkl(:,4);
qxy = hkl(:,5);

///////////////////////////////////////////////
// consistency check (for finding input errors)

// original determination based on (10L)/(01L) rod values
// check any input with deviation larger than 1 nm-1
asperp0 = -1.32;
bsperp0 = 2.35;
csperp0 = 19.4;
qzc0 = h*asperp0 + k*bsperp0 + l*csperp0;
dev0 = qzc0 - qz;
devtot0 = sqrt(sum(dev0.^2)/length(dev0));
disp("consistency check");
disp([h k l qzc0 qz dev0]);


//////////////////////////////////////////////////////
// least-squares optimization
// h*asperp + h*bsperp +l*csperp = qz

M = [h k l];
C = qz;

// solve normal equation MTM * XYZ = MTC
MTM = M' * M;
MTC = M' * C;
XYZ = inv(MTM) * MTC;

// components
asperp = round(XYZ(1)*1000)/1000;
bsperp = round(XYZ(2)*1000)/1000;
csperp = round(XYZ(3)*1000)/1000;

// print solution
disp("original lattice params")
disp([asperp0 bsperp0 csperp0 devtot0])

qzc = h*asperp + k*bsperp + l*csperp;
dev = qzc - qz;
devtot = sqrt(sum(dev.^2)/length(dev));
disp("LSQ refined lattice params");
disp([asperp bsperp csperp devtot]);
