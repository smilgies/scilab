///////////////////////////////////////////////
// 2D reciprocal surface unit cell optimization
///////////////////////////////////////////////


// list of inplane q-values found by indexGIXS

// - example: ZnPc - triclinic
qexp=[4.65;6.1;7.1;9.3;9.8;11.0;12.1;14.0;15.4;17.9;18.2;18.5;18.7;19.5;19.9;21.2;21.5];


////////////    begin optimization     ////////////

// number of experimental q-values
nq = length(qexp);

// successful assignment
as = qexp(1);
bs = qexp(1);
ds = qexp(2);

// gams angle between as and bs
cosgams = (as^2+bs^2-ds^2)/(2*as*bs);
gamsdeg = acos(cosgams)*180/%pi;
gamsdeg = round(gamsdeg*10)/10;

// generating a set of reflections and their indices
qc=[];
hk=[];
for h=-7:7
    for k=-7:7
        hk=[hk;h,k];
        qq=h^2*as^2 + k^2*bs^2 + 2*h*as*k*bs*cosgams;
        qc=[qc;sqrt(qq)];   
    end
end

// sort qc and hk by size of qc
[qcsort,listq] = gsort(qc,"g","i");
qcsort=round(qcsort*1000)/1000;
hksort=hk(listq,1:2);

// find qcsort value larger than qmax
qmax = max(qexp);
nqmax = find(qcsort>qmax);
N = min(nqmax)+4;

// remove Friedel pairs and (0,0)
qcalc = qcsort(3:2:N);
hk = hksort(3:2:N,1:2);
mq = length(qcalc);


/////////////////////////////////////////////
//automatic match of qcalc and qexp

// max allowable tolerance for matching
// - tol=0.1 is too narrow, tol=0.15 is just right, tol=0.2 is too wide
tol = 0.15;

// LOOP: matching qcalc with qexp
match = [];      // matrix of matched [h k qcalc qexp]
nomatch = 0;     // number of unmatched qexp

for iq=1:nq
    check = %f;
    for kq=1:mq
        if abs(qcalc(kq) - qexp(iq))<tol then
            // if match within tol, add it to the list
            match = [match; hk(kq,1), hk(kq,2), qcalc(kq), qexp(iq)];
            check = %t;
        end
    end
    if ~check then
        nomatch=nomatch+1;
    end
end

///////////////////////////////////////////////////////
// interactive finetuning: eliminate double assignments

header = "tol="+string(tol)+"   finetune assignments; no match: "+string(nomatch);
nbeg = size(match,"r");
match = x_matrix(header,match);
nend = size(match,"r");
corrections = nbeg - nend;

////////////////////////////////////////////////////////////
// prepare matrix components for LSQ fit via normal equation
h = match(:,1);
k = match(:,2);
qca = match(:,3);
qex = match(:,4);


///////////////////////////////////////////////
// output original values and deviation

// initial deviation
dev = norm(qca-qex)/nend;
dev = round(dev*1000)/1000;

// output using table fcn
varnames = ["aspar" "bspar" "gamspar" "dev" "tol" "no match" "corrected"];
varvalue = [as,bs,gamsdeg,dev,tol,nomatch,corrections];
version = getversion();
if version=="scilab-2023.1.0" then
    disp(varnames);
    disp(string(varvalue));
elseif version=="scilab-2026.1.0" then
    disp("")
    tab = table(varvalue,"Variablenames",varnames);
    disp(tab)
else
    disp("unsupported scilab version: use 2023.1.0 or 2026.1.0");
end

//////////////     end optimization     //////////////


//////////////////////////////////////////////////////
// least-mean-square (LSQ) fit

// the problem: solve LSQ fit of linearized equation system
// q^2 = h^2 * X + k^2 * Y + h*k * Z
// with X = a^2, Y = b^2, Z = 2*a*b*cos(gam)

// building the equation matrix
M = [h.^2, k.^2, h.*k];
C = qex.^2;

// matrices for normal equation solving the LSQ fit
M2 = M'*M;
C2 = M'*C;

// solution of normal equation
XYZ = inv(M2)*C2;

// solution components: best 2D reciprocal surface unit cell
X = XYZ(1);
Y = XYZ(2);
Z = XYZ(3);
asopt = sqrt(X);
bsopt = sqrt(Y);
gamsopt = acos(Z/(2*asopt*bsopt));
gamsoptdeg = gamsopt*180/%pi;

// reduce digits after decimal point
asopt = round(asopt*1000)/1000;
bsopt = round(bsopt*1000)/1000;
gamsoptdeg = round(gamsoptdeg*100)/100;

// deviation
qfit = sqrt((h*asopt).^2 + (k*bsopt).^2 + 2*h.*k*asopt*bsopt*cos(gamsopt));
dev = norm(qfit-qex)/nend;
dev = round(dev*1000)/1000;

//////////////////////////////////////////////////////////////
// output

// display result - using table

varnames = ["aspar" "bspar" "gamspar" "dev"];
varvalue = [asopt,bsopt,gamsoptdeg,dev];
if version=="scilab-2023.1.0" then
    disp("refined values");
    disp(string(varvalue));
else
    disp("");
    tab = table(varvalue,"Variablenames",varnames);
    disp(tab);
end

///////////////////////////////////////////////////////////////
// sample results for scilab-2026.1.0

// tolerance 0.15 just right: all qexp matched, few corrections
//  ""
//   aspar   bspar   gamspar    dev    tol    no match   corrected
//   _____   _____   _______   _____   ____   ________   _________
//                                                              
//   4.65    4.65    82        0.014   0.15   0          2      
//  ""
//   aspar   bspar   gamspar    dev 
//   _____   _____   _______   _____
//                                  
//   4.657   4.657   81.23     0.007


// tolerance 0.1 too small - not all qexp matched
// ""
//   aspar   bspar   gamspar    dev    tol   no match   corrected
//   _____   _____   _______   _____   ___   ________   _________
//                                                             
//   4.65    4.65    82        0.013   0.1   5          0      
//  ""
//   aspar   bspar   gamspar    dev 
//   _____   _____   _______   _____
//                                  
//   4.658   4.658   81.41     0.009


// tolerance 0.2 too relaxed - more corrections needed
//  ""
//   aspar   bspar   gamspar    dev    tol   no match   corrected
//   _____   _____   _______   _____   ___   ________   _________
//                                                             
//   4.65    4.65    82        0.015   0.2   0          4      
//  ""
//   aspar   bspar   gamspar    dev 
//   _____   _____   _______   _____
//                                  
//   4.659   4.659   81.37     0.011
