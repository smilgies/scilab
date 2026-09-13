// LLL Lattice Reduction for 3D Crystallographic Lattices with Transformation Matrix
clear; clc;

// 1. INPUT: Define your 3D crystallographic lattice parameters
a     = 1.362;    // nm
b     = 1.365;    // nm
c     = 0.383;    // nm
alpha = 118.3;    // deg
beta  = 71.70;    // deg
gamma = 98.77;    // deg

delta = 0.99; // Lovász parameter

printf("--- Original Crystallographic Parameters ---\n");
printf("a = %.4f, b = %.4f, c = %.4f\n", a, b, c);
printf("alpha = %.2f, beta = %.2f, gamma = %.2f\n\n", alpha, beta, gamma);

// 2. CONVERT: Crystallographic parameters to Cartesian Basis Matrix (B)
rad = %pi / 180;
al = alpha * rad;
be = beta * rad;
ga = gamma * rad;

bx = b * cos(ga);
by = b * sin(ga);
cx = c * cos(be);
cy = c * (cos(al) - cos(be)*cos(ga)) / sin(ga);
cz = sqrt(c^2 - cx^2 - cy^2);

B = [ a,  bx, cx;
      0,  by, cy;
      0,  0,  cz ];

// 3. FUNCTION: Gram-Schmidt Orthogonalization
function [Q, mu] = gram_schmidt(X)
    [m, n] = size(X);
    Q = zeros(m, n);
    mu = zeros(n, n);
    for i = 1:n
        Q(:, i) = X(:, i);
        for j = 1:i-1
            mu(i, j) = (X(:, i)' * Q(:, j)) / (Q(:, j)' * Q(:, j));
            Q(:, i) = Q(:, i) - mu(i, j) * Q(:, j);
        end
        mu(i, i) = 1;
    end
endfunction

// 4. ALGORITHM: LLL Lattice Reduction with Transformation Matrix Tracking
function [B_red, H] = lll_reduction_with_matrix(B_in, delta)
    B_red = B_in;
    n = size(B_red, 2);
    
    // Initialize the transformation matrix as an Identity Matrix
    H = eye(n, n);
    
    [Q, mu] = gram_schmidt(B_red);
    k = 2;
    
    while k <= n
        // Size reduction step
        for j = k-1:-1:1
            if abs(mu(k, j)) > 0.5 then
                r = round(mu(k, j));
                B_red(:, k) = B_red(:, k) - r * B_red(:, j);
                H(:, k)     = H(:, k) - r * H(:, j); // Track operation in H
                [Q, mu] = gram_schmidt(B_red);
            end
        end
        
        // Lovász condition check
        val1 = Q(:, k)' * Q(:, k);
        val2 = (delta - mu(k, k-1)^2) * (Q(:, k-1)' * Q(:, k-1));
        
        if val1 >= val2 then
            k = k + 1;
        else
            // Swap vectors v_k and v_{k-1}
            tmp_B = B_red(:, k);
            B_red(:, k) = B_red(:, k-1);
            B_red(:, k-1) = tmp_B;
            
            // Swap corresponding columns in the transformation matrix
            tmp_H = H(:, k);
            H(:, k) = H(:, k-1);
            H(:, k-1) = tmp_H;
            
            [Q, mu] = gram_schmidt(B_red);
            k = max(k-1, 2);
        end
    end
endfunction

// 5. EXECUTE: Run LLL
[B_reduced, H] = lll_reduction_with_matrix(B, delta);

printf("--- LLL Reduced Basis Matrix (B_reduced) ---\n");
disp(B_reduced);

printf("--- Transformation Matrix (H) ---\n");
disp(H);
printf("Determinant of H = %d (Must be 1 or -1)\n\n", round(det(H)));

// 6. RECONSTRUCT: Convert reduced matrix back to crystallographic parameters
v1 = B_reduced(:, 1);
v2 = B_reduced(:, 2);
v3 = B_reduced(:, 3);

a_new = norm(v1);
b_new = norm(v2);
c_new = norm(v3);

alpha_new = acos((v2' * v3) / (b_new * c_new)) / rad;
beta_new  = acos((v1' * v3) / (a_new * c_new)) / rad;
gamma_new = acos((v1' * v2) / (a_new * b_new)) / rad;

printf("--- LLL Reduced Crystallographic Parameters ---\n");
printf("a_red = %.4f, b_red = %.4f, c_red = %.4f\n", a_new, b_new, c_new);
printf("alpha_red = %.2f, beta_red = %.2f, gamma_red = %.2f\n", alpha_new, beta_new, gamma_new);


///////////////////////////////////////////////////////////
// sample output
//
// --- Original Crystallographic Parameters ---
// a = 1.3620, b = 1.3650, c = 0.3830
// alpha = 118.30, beta = 71.70, gamma = 98.77
//
// --- LLL Reduced Basis Matrix (B_reduced) ---
//   0.1202591   0.0323989   1.2417409
//  -0.1651712   1.0186985   0.1651712
//   0.3239525   0.647905   -0.3239525
// --- Transformation Matrix (H) ---
//   0.   0.   1.
//   0.   1.   0.
//   1.   2.  -1.
// Determinant of H = -1 (Must be 1 or -1)
//
// --- LLL Reduced Crystallographic Parameters ---
// a_red = 0.3830, b_red = 1.2077, c_red = 1.2939
// alpha_red = 90.05, beta_red = 88.02, gamma_red = 84.35
