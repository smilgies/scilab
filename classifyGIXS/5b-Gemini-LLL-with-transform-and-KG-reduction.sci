// Combined LLL and Niggli Cell Lattice Reduction for 3D Crystallographic Parameters
clear; clc;

// 1. INPUT: Define your initial 3D crystallographic parameters
a     = 1.362;    // nm
b     = 1.365;    // nm
c     = 0.383;    // nm
alpha = 118.3;    // deg
beta  = 71.70;    // deg
gamma = 98.77;    // deg

delta = 0.99; // LLL parameter
eps = 1e-5;   // Niggli tolerance threshold

printf("============ 1. INITIAL PARAMETERS ============\n");
printf("a = %.4f, b = %.4f, c = %.4f\n", a, b, c);
printf("alpha = %.2f, beta = %.2f, gamma = %.2f\n\n", alpha, beta, gamma);

// 2. CONVERT: Parameters to Cartesian Basis Matrix (B)
rad = %pi / 180;
al = alpha * rad;
be = beta * rad;
ga = gamma * rad;

bx = b * cos(ga);
by = b * sin(ga);
cx = c * cos(be);
cy = c * (cos(al) - cos(be)*cos(ga)) / sin(ga);
cz = sqrt(c^2 - cx^2 - cy^2);

B_orig = [ a,  bx, cx;
           0,  by, cy;
           0,  0,  cz ];

// Helper Function: Gram-Schmidt for LLL
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

// Helper Function: Extract cell lengths and angles from a basis matrix
function [cell_params] = matrix_to_cell(M)
    v1 = M(:, 1); v2 = M(:, 2); v3 = M(:, 3);
    a_n = norm(v1); b_n = norm(v2); c_n = norm(v3);
    al_n = acos((v2' * v3) / (b_n * c_n)) * (180 / %pi);
    be_n = acos((v1' * v3) / (a_n * c_n)) * (180 / %pi);
    ga_n = acos((v1' * v2) / (a_n * b_n)) * (180 / %pi);
    cell_params = [a_n, b_n, c_n, al_n, be_n, ga_n];
endfunction

// 3. ALGORITHM: LLL Reduction with Matrix Tracking
function [B_red, H] = lll_reduction(B_in, delta)
    B_red = B_in;
    n = size(B_red, 2);
    H = eye(n, n);
    [Q, mu] = gram_schmidt(B_red);
    k = 2;
    while k <= n
        for j = k-1:-1:1
            if abs(mu(k, j)) > 0.5 then
                r = round(mu(k, j));
                B_red(:, k) = B_red(:, k) - r * B_red(:, j);
                H(:, k)     = H(:, k) - r * H(:, j);
                [Q, mu] = gram_schmidt(B_red);
            end
        end
        val1 = Q(:, k)' * Q(:, k);
        val2 = (delta - mu(k, k-1)^2) * (Q(:, k-1)' * Q(:, k-1));
        if val1 >= val2 then
            k = k + 1;
        else
            tmp_B = B_red(:, k); B_red(:, k) = B_red(:, k-1); B_red(:, k-1) = tmp_B;
            tmp_H = H(:, k); H(:, k) = H(:, k-1); H(:, k-1) = tmp_H;
            [Q, mu] = gram_schmidt(B_red);
            k = max(k-1, 2);
        end
    end
endfunction

// 4. ALGORITHM: Niggli Cell Reduction (Krivý-Gruber Form)
function [B_nig, H_nig] = niggli_reduction(B_in, eps)
    B_nig = B_in;
    n = size(B_nig, 2);
    H_nig = eye(n, n);
    
    // Main iteration loop following Krivý-Gruber criteria
    while %t
        // Recalculate Niggli matrix elements (S-matrix components)
        A = B_nig(:, 1)' * B_nig(:, 1);
        B_val = B_nig(:, 2)' * B_nig(:, 2);
        C = B_nig(:, 3)' * B_nig(:, 3);
        D = 2 * (B_nig(:, 2)' * B_nig(:, 3));
        E = 2 * (B_nig(:, 1)' * B_nig(:, 3));
        F = 2 * (B_nig(:, 1)' * B_nig(:, 2));
        
        changed = %f;
        
        // Step 1: Main sorting sorting criteria (A > B)
        if A > B_val + eps then
            // Swap a and b
            tmp = B_nig(:, 1); B_nig(:, 1) = B_nig(:, 2); B_nig(:, 2) = tmp;
            tmp = H_nig(:, 1); H_nig(:, 1) = H_nig(:, 2); H_nig(:, 2) = tmp;
            changed = %t;
        // Step 2: Sorting criteria (B > C)
        elseif B_val > C + eps then
            // Swap b and c
            tmp = B_nig(:, 2); B_nig(:, 2) = B_nig(:, 3); B_nig(:, 3) = tmp;
            tmp = H_nig(:, 2); H_nig(:, 2) = H_nig(:, 3); H_nig(:, 3) = tmp;
            changed = %t;
        // Step 3: Handle All-Positive / All-Negative acute/obtuse alignment cases
        elseif (D > 0 & E > 0 & F > 0) | (D < 0 & E < 0 & F < 0) then
            // Set all signs positive or transform vectors to meet parity standards
            l_mat = eye(3,3);
            if D < 0 then
                l_mat = [1 0 0; 0 -1 0; 0 0 -1];
            end
            B_nig = B_nig * l_mat;
            H_nig = H_nig * l_mat;
            changed = %t;
        // Step 4: Size reductions of coordinates out of bounds
        elseif abs(D) > B_val + eps | (D == B_val & 2*E < F) | (D == -B_val & F < 0) then
            s = sign(D); if s == 0 then s = 1; end
            B_nig(:, 3) = B_nig(:, 3) - s * B_nig(:, 2);
            H_nig(:, 3) = H_nig(:, 3) - s * H_nig(:, 2);
            changed = %t;
        elseif abs(E) > A + eps | (E == A & 2*D < F) | (E == -A & F < 0) then
            s = sign(E); if s == 0 then s = 1; end
            B_nig(:, 3) = B_nig(:, 3) - s * B_nig(:, 1);
            H_nig(:, 3) = H_nig(:, 3) - s * H_nig(:, 1);
            changed = %t;
        elseif abs(F) > A + eps | (F == A & 2*D < E) | (F == -A & E < 0) then
            s = sign(F); if s == 0 then s = 1; end
            B_nig(:, 2) = B_nig(:, 2) - s * B_nig(:, 1);
            H_nig(:, 2) = H_nig(:, 2) - s * H_nig(:, 1);
            changed = %t;
        end
        
        // Loop terminates once none of the Niggli geometric conditions are triggered
        if ~changed then
            break;
        end
    end
endfunction

// 5. EXECUTION Pipeline
// Step A: First compute LLL-reduced state
[B_lll, H_lll] = lll_reduction(B_orig, delta);
p_lll = matrix_to_cell(B_lll);

// Step B: Route the result directly into Niggli constraints 
[B_niggli, H_nig_step] = niggli_reduction(B_lll, eps);
p_nig = matrix_to_cell(B_niggli);

// Total transformation directly linking Initial Basis -> Niggli Basis
H_total = H_lll * H_nig_step;

// 6. OUTPUTS
printf("============ 2. LLL REDUCED CELL ============\n");
printf("a = %.4f, b = %.4f, c = %.4f\n", p_lll(1), p_lll(2), p_lll(3));
printf("alpha = %.2f, beta = %.2f, gamma = %.2f\n\n", p_lll(4), p_lll(5), p_lll(6));

printf("============ 3. NIGGLI REDUCED CELL ============\n");
printf("a_nig = %.4f, b_nig = %.4f, c_nig = %.4f\n", p_nig(1), p_nig(2), p_nig(3));
printf("alpha_nig = %.2f, beta_nig = %.2f, gamma_nig = %.2f\n\n", p_nig(4), p_nig(5), p_nig(6));

printf("============ 4. TOTAL TRANSFORMATION MATRIX (H) ============\n");
disp(H_total);
printf("Determinant of H = %d (Must be 1 or -1 to retain exact volume)\n", round(det(H_total)));


//////////////////////////////////////////////////////////////////////
// sample output
// ============ 1. INITIAL PARAMETERS ============
// a = 1.3620, b = 1.3650, c = 0.3830
// alpha = 118.30, beta = 71.70, gamma = 98.77
// 
// ============ 2. LLL REDUCED CELL ============
// a = 0.3830, b = 1.2077, c = 1.2939
// alpha = 90.05, beta = 88.02, gamma = 84.35
// 
// ============ 3. NIGGLI REDUCED CELL ============
// a_nig = 0.3830, b_nig = 1.2077, c_nig = 1.2939
// alpha_nig = 90.05, beta_nig = 88.02, gamma_nig = 84.35
// 
// ============ 4. TOTAL TRANSFORMATION MATRIX (H) ============
//    0.   0.   1.
//    0.   1.   0.
//    1.   2.  -1.
// Determinant of H = -1 (Must be 1 or -1 to retain exact volume)

