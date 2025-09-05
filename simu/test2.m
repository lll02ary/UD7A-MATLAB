clear; clc;

% === 參數 ===
Llp = 0.876e-3;      % H, 原邊漏感
Lls = 1.994e-3;      % H, 次邊漏感
Lm  = 1.124e-3;      % H, 磁化電感
R1  = 900.72;      % Ω, 換能器等效電阻
L1  = 901.37e-3;   % H, 換能器等效電感
C1  = 50.75e-12;  % F, 換能器等效串聯電容
C0  = 519.01e-12;   % F, 換能器平行電容

% 目標諧振頻率
f0 = 23540;             % Hz
w0 = 2 * pi * f0;       % rad/s
jw = 1i * w0;

% 換能器阻抗 Zt（串聯 RLC 與 C0 並聯）
Z_RLC = R1 + jw*L1 + 1/(jw*C1);
Zt = 1 / (1/Z_RLC + jw*C0);

% 次邊漏感串接
Z_secondary = jw*Lls + Zt;

% Lm 並聯次邊路徑
Z_parallel = 1 / (1/(jw*Lm) + 1/Z_secondary);

% 一次側 Lk1 串聯（未加 Cs1）
Z_rest = jw*Llp + Z_parallel;

% 🔍 Step 1：取虛部
X_rest = imag(Z_rest);   % 就是要補償掉的虛部

% 🔧 Step 2：計算補償電容
Cs1 = 1 / (w0 * X_rest);

fprintf('✅ 為補償 Im(Zin1) = 0，所需串聯電容 Cs1 = %.4e F (%.2f nF)\n', Cs1, Cs1*1e9);
