// ============================================================
// LLL lattice reduction in 3D from six lattice parameters
// (a, b, c, alpha, beta, gamma) -> reduced basis + reduced cell
// ============================================================


// ---- 1. Build a 3x3 basis (rows = lattice vectors a,b,c) ----

// Standard crystallographic convention:
//   a along x
//   b in the xy-plane
//   c completes the set
// alpha = angle(b,c), beta = angle(a,c), gamma = angle(a,b), all in degrees.

function B = latticeParamsToBasis(a, b, c, alpha, beta, gamma)
    alpha_r = alpha*%pi/180;
    beta_r  = beta*%pi/180;
    gamma_r = gamma*%pi/180;

    ax = a; ay = 0; az = 0;
    bx = b*cos(gamma_r); by = b*sin(gamma_r); bz = 0;

    cx = c*cos(beta_r);
    cy = c*(cos(alpha_r) - cos(beta_r)*cos(gamma_r)) / sin(gamma_r);
    cz2 = c^2 - cx^2 - cy^2;
    if cz2 < 0 then
        error('Invalid lattice parameters: computed negative cell volume term.');
    end
    cz = sqrt(cz2);

    B = [ax ay az; bx by bz; cx cy cz];
endfunction


// ---- 2. Recover (a,b,c,alpha,beta,gamma) from a basis ----
// Useful to inspect the reduced cell after LLL.

function [a,b,c,alpha,beta,gamma] = basisToLatticeParams(B)
    v1 = B(1,:); v2 = B(2,:); v3 = B(3,:);
    a = norm(v1); b = norm(v2); c = norm(v3);
    alpha = acos( (v2*v3') / (b*c) ) * 180/%pi;   // angle(b,c)
    beta  = acos( (v1*v3') / (a*c) ) * 180/%pi;   // angle(a,c)
    gamma = acos( (v1*v2') / (a*b) ) * 180/%pi;   // angle(a,b)
endfunction


// ---- 3. Gram-Schmidt orthogonalization (rows of B) ----

function [Bstar, mu] = gramSchmidt(B)
    n = size(B,1);
    Bstar = zeros(n,3);
    mu = eye(n,n);
    for i = 1:n
        Bstar(i,:) = B(i,:);
        for j = 1:i-1
            mu(i,j) = (B(i,:)*Bstar(j,:)') / (Bstar(j,:)*Bstar(j,:)');
            Bstar(i,:) = Bstar(i,:) - mu(i,j)*Bstar(j,:);
        end
    end
endfunction


// ---- 4. LLL reduction ----

// B      : n x 3 matrix, rows are the input basis vectors
// delta  : Lovasz condition parameter, typically 0.75 (0.25 < delta <= 1)
//
// Returns:
//   Bred : the reduced basis (rows)
//   S    : the integer unimodular transformation matrix (det(S) = +-1)
//          such that Bred = S * Borig
// Every elementary row operation applied to B (shears from size-reduction,
// swaps from the Lovasz condition) is mirrored on S, starting from S=I.

function [Bred, S] = LLL(B, delta)
    if argn(2) < 2 then
        delta = 0.75;
    end
    n = size(B,1);
    S = eye(n,n);
    [Bstar, mu] = gramSchmidt(B);
    k = 2;
    while k <= n
        // size reduction of vector k against all previous vectors
        for j = k-1:-1:1
            if abs(mu(k,j)) > 0.5 then
                q = round(mu(k,j));
                B(k,:) = B(k,:) - q*B(j,:);
                S(k,:) = S(k,:) - q*S(j,:);
                [Bstar, mu] = gramSchmidt(B);
            end
        end
        // Lovasz condition
        normk  = Bstar(k,:)*Bstar(k,:)';
        normk1 = Bstar(k-1,:)*Bstar(k-1,:)';
        if normk >= (delta - mu(k,k-1)^2)*normk1 then
            k = k + 1;
        else
            tmp = B(k,:); B(k,:) = B(k-1,:); B(k-1,:) = tmp;
            tmpS = S(k,:); S(k,:) = S(k-1,:); S(k-1,:) = tmpS;
            [Bstar, mu] = gramSchmidt(B);
            k = max(k-1, 2);
        end
    end
    Bred = B;
endfunction


// ============================================================
// Example usage
// ============================================================
// Replace these six values with your own lattice parameters.
// Lengths in whatever unit you like (Angstrom, nm, ...), angles in degrees.

a     = 1.362;
b     = 1.365;
c     = 0.383;
alpha = 118.3;
beta  = 71.7;
gamma = 98.77;

B = latticeParamsToBasis(a, b, c, alpha, beta, gamma);
mprintf("Original basis vectors (rows):\n");
disp(B);

[Bred, S] = LLL(B, 0.75);
mprintf("\nLLL-reduced basis vectors (rows):\n");
disp(Bred);

mprintf("\nTransformation matrix S (integer, unimodular) such that Bred = S * Borig:\n");
disp(S);
mprintf("det(S) = %d  (must be +-1)\n", det(S));

// sanity check: recompute Bred from S and Borig directly
mprintf("\nCheck S*Borig (should equal Bred above):\n");
disp(S*B);

[ar,br,cr,alphar,betar,gammar] = basisToLatticeParams(Bred);
mprintf("\nReduced cell parameters:\n");
mprintf("a = %f, b = %f, c = %f\n", ar, br, cr);
mprintf("alpha = %f deg, beta = %f deg, gamma = %f deg\n", alphar, betar, gammar);

// sanity check: reduced cell should have the same volume as the original
// Vorig = abs(det(B));
// Vred  = abs(det(Bred));
// mprintf("\nVolume check: original = %f, reduced = %f (should match)\n", Vorig, Vred);


////////////////////////////////////////////////////////////////////////////////////////
// sample output
//
// Original basis vectors (rows):
//   1.362       0.          0.       
//  -0.2081193   1.3490409   0.       
//   0.1202591  -0.1651712   0.3239525
//
// LLL-reduced basis vectors (rows):
//   0.1202591  -0.1651712   0.3239525
//   1.2417409   0.1651712  -0.3239525
//   0.0323989   1.0186985   0.647905 
//
//Transformation matrix S (integer, unimodular) such that Bred = S * Borig:
//   0.   0.   1.                   lattice vector relations  a' = c
//   1.   0.  -1.                                             b' = a - c
//   0.   1.   2.                                             c' = b + 2c
// det(S) = 1  (must be +-1)
//
// Check S*Borig (should equal Bred above):
//   0.1202591  -0.1651712   0.3239525
//   1.2417409   0.1651712  -0.3239525
//   0.0323989   1.0186985   0.647905 
//
// Reduced cell parameters:
// a = 0.383000, b = 1.293888, c = 1.207716
// alpha = 90.051324 deg, beta = 84.351509 deg, gamma = 88.022080 deg
//
// Volume check: original = 0.595228, reduced = 0.595228 (should match)
//
// NOTE: final sorting step is missing (b>c) --> run dirichlet
