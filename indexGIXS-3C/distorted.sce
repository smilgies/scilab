// distorted
// replace s-factor with distorted lattice

// input lattice with HKL plane and s-factor

head="distorted lattice"
label=["a (nm)";"b (nm)";"c (nm)";"alf (deg)";"bet (deg)";"gam (deg)";"H";"K";"L";"s-factor"]
value=string(ones(10,1));
value(4)="90";
value(5)="90";
value(6)="90";
value=x_mdialog(head,label,value);

// convert string to float
a=evstr(value(1));
b=evstr(value(2));
c=evstr(value(3));
alf=evstr(value(4))*%pi/180;   // angles in rad
bet=evstr(value(5))*%pi/180;
gam=evstr(value(6))*%pi/180;
H=evstr(value(7));
K=evstr(value(8));
L=evstr(value(9));
s_fac=evstr(value(10));

// reciprocal lattice parameters (Authier)

V=a*b*c*sqrt(1+2*cos(alf)*cos(bet)*cos(gam)-cos(alf)^2-cos(bet)^2-cos(gam)^2);

as=2*%pi*b*c*sin(alf)/V;
bs=2*%pi*a*c*sin(bet)/V;
cs=2*%pi*a*b*sin(gam)/V;

alfs=acos((cos(gam)*cos(bet)-cos(alf))/abs(sin(gam)*sin(bet)));
bets=acos((cos(alf)*cos(gam)-cos(bet))/abs(sin(alf)*sin(gam)));
gams=acos((cos(alf)*cos(bet)-cos(gam))/abs(sin(alf)*sin(bet)));

// reciprocal lattice vectors (Busing & Levy)

As=[as;0;0];
Bs=[bs*cos(gams);bs*sin(gams);0];
Cs=[cs*cos(bets);-cs*sin(bets)*cos(alf);2*%pi/c];

// indices and G vector of growth plane

G=H*As+K*Bs+L*Cs;

// rotate lattice to make G parallel to surface normal (Smilgies & Blasini)

phi=atan(G(2),G(1));
chi=acos(G(3)/sqrt(G(1)^2+G(2)^2+G(3)^2));

R1=[cos(-chi) 0 sin(-chi);0 1 0;-sin(-chi) 0 cos(-chi)];
R2=[cos(-phi) -sin(-phi) 0; sin(-phi) cos(-phi) 0; 0 0 1];
R=R1*R2;

// check: R*G=(0;0;z) >>> ok

// shrinkage factor s_fac and shrink matrix S
// used for uniaxial swelling (f>1) or shrinking (f<1)

S=eye(3,3);    // note: def of eye different from MatLab!!!
S(3,3)=1/s_fac;    

SRAs=S*R*As;
SRBs=S*R*Bs;
SRCs=S*R*Cs;

// lattice vectors of distorted lattice

Vdis=(cross(SRAs,SRBs)'*SRCs);
Adis=2*%pi*cross(SRBs,SRCs)/Vdis;
Bdis=2*%pi*cross(SRCs,SRAs)/Vdis;
Cdis=2*%pi*cross(SRAs,SRBs)/Vdis

adis=norm(Adis);
bdis=norm(Bdis);
cdis=norm(Cdis);
alfdis=acos((Bdis'*Cdis)/(bdis*cdis))*180/%pi;
betdis=acos((Cdis'*Adis)/(cdis*adis))*180/%pi;
gamdis=acos((Adis'*Bdis)/(adis*bdis))*180/%pi;

// output

HKL=string(H)+string(K)+string(L);
head="distorted lattice along HKL="+HKL;
label=["adis (nm))";"bdis (nm)";"cdis (nm)";"alfdis (deg)";"betdis (deg)";"gamdis (deg)"];
value=string([adis;bdis;cdis;alfdis;betdis;gamdis]);
x_mdialog(head,label,value);




