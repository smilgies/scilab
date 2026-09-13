////////////////////////////
// Dirichlet normalization
////////////////////////////

// Script performs the Dirichlet normalization:
// a <= b <= c and angles either all acute or all obtuse
// and checks whether the cell can be further reduced 
// [Dirichlet 1850]
// The conditions are often ascribed to Niggli who cites Dirichlet's work.

// The script should be performed for surface unit cells and unit cells from
// literature in order to provide a properly normalized set of lattice parameters
// and to probe whether further reduction should be performed.


///////////////////////////////////////////////////////////////////////
// input of surface unit cell lattice parameters

a     = 1.362;    // nm
b     = 1.365;    // nm
c     = 0.383;    // nm
alf   = 118.3;    // deg
bet   = 71.70;    // deg
gam   = 98.77;    // deg
H = 0
K = 0
L = 1

// vectors for sorting
abc = [a b c]
alfbetgam = [alf bet gam]
HKL = [H K L]

disp("input lattice parameters")
disp([abc,alfbetgam,HKL])

// cosines
calf = cos(alf*%pi/180)
cbet = cos(bet*%pi/180)
cgam = cos(gam*%pi/180)

//////////////////////////
// Condition 1: a <= b<= c
// - sort a,b,c
// - alf, bet, gam follow as do H K L

// ordering
[abc2, order] = gsort(abc,"g","i")
alfbetgam2 = alfbetgam(order)
HKL2 = HKL(order)

// sorted lengths, angles, and growth plane indices
a2 = abc2(1)
b2 = abc2(2)
c2 = abc2(3)

alf2 = alfbetgam2(1)
bet2 = alfbetgam2(2)
gam2 = alfbetgam2(3)

H2 = HKL2(1)
K2 = HKL2(2)
L2 = HKL2(3)

/////////////////////////////////////////////////////
// Condition 2: all angles acute or all angles obtuse

check = sum(alfbetgam2 < 90)

select check
case 0
    disp("case 2 - all obtuse")
    latt_type = 2
case 1
    if alf2==90 | bet2==90 | gam2==90 then
        // special case: alf=90 etc. counts as obtuse
        disp("case 2 - all obtuse")
        latt_type = 2
        if alf2 < 90 then
            alf2 = 180 - alf2
        end
        if bet2 < 90 then
            bet2 = 180 - bet2
        end
        if gam2 < 90 then
            gam2 = 180 - gam2
        end
    else
        disp("case 1 - all acute")  
        latt_type = 1
        if alf2 < 90 then
            bet2 = 180 - bet2
            gam2 = 180 - gam2
        elseif bet2 < 90 then
            gam2 = 180 - gam2
            alf2 = 180 - alf2
        elseif gam2 < 90 then
            alf2 = 180 - alf2
            bet2 = 180 - bet2
        end
    end
case 2
    disp "case 2 - all obtuse"
    latt_type = 2
    if alf2 > 90 then
        bet2 = 180 - bet2
        gam2 = 180 - gam2
    elseif bet2 > 90 then
        gam2 = 180 - gam2
        alf2 = 180 - alf2
    elseif gam2 > 90 then
        alf2 = 180 - alf2
        bet2 = 180 - bet2
    end    
case 3
    disp "case 1 - all acute"
    latt_type = 1
end

disp("normalized lattice parameters")
disp([a2 b2 c2 alf2 bet2 gam2])
disp("growth plane")
disp([H2,K2,L2])


/////////////////////////////////////////////////////////
// condition 3: no diagonals shorter than lattice vectors

// a-b face
Fab = %t
if a2^2 - 2*a2*b2*abs(cgam) < 0 then
    Fab = %f
    disp("test failed - a-b face diagonal is shorter than b")
end
// c-a face diagonal
Fca = %t
if a2^2 - 2*c2*a2*abs(cbet) < 0 then
    Fca = %f
    disp("test failed - c-a face diagonal is shorter than c")
end
// b-c face diagonal
Fbc = %t
if b2^2 - 2*b2*c2*abs(calf) < 0 then
    Fbc = %f
    disp("test failed -  b-c face diagonal is shorter than c")
end

// a-b-c body diagonal
Babc = %t
if a2^2 + b2^2 - 2*b2*c2*abs(calf) - 2*c2*a2*abs(cbet) - 2*a2*b2*abs(cgam) < 0 then
    Babc = %f
    disp("test failed - abc body diagonal is shorter than c")
end    

if (Fab & Fca & Fbc & Babc) then
    disp("cell is Dirichlet reduced")
else
    disp("cell can be reduced further")
end


