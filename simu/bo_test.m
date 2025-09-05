clear; clc;

% === 參數 ===
Llp = 0.069e-3;
Lls = 0.514e-3;
Lm  = 1.032e-3;
R1  = 130.4947;
L1  = 379.2760e-3;
C1  = 117.7164e-12;
C0  = 2.822977e-9;

% 預設諧振頻率
f0 = 23810;
w0 = 2 * pi * f0;
jw0 = 1i * w0;

% Step 1：先算出補償電容 Cs1
Z_RLC = R1 + jw0*L1 + 1/(jw0*C1);
Zt = 1 / (1/Z_RLC + jw0*C0);
Z_secondary = jw0*Lls + Zt;
Z_parallel = 1 / (1/(jw0*Lm) + 1/Z_secondary);
Z_rest = jw0*Llp + Z_parallel;
X_rest = imag(Z_rest);
Cs1 = 1 / (w0 * X_rest);  % 所需補償電容

fprintf('✅ 補償電容 Cs1 = %.4e F (%.2f nF)\n', Cs1, Cs1*1e9);

% Step 2：頻率掃描來計算 Q
f = linspace(22000, 25000, 100000);  % Hz
w = 2 * pi * f;
Zin = zeros(size(f));

for k = 1:length(f)
    jw = 1i * w(k);

    % 加入補償電容 Cs1（一次側）
    Zcs1 = 1 / (jw * Cs1);

    Z_RLC = R1 + jw*L1 + 1/(jw*C1);
    Zt = 1 / (1/Z_RLC + jw*C0);
    Z_secondary = jw*Lls + Zt;
    Z_parallel = 1 / (1/(jw*Lm) + 1/Z_secondary);
    Zin(k) = Zcs1 + jw*Llp + Z_parallel;
end

% Step 3：找最大幅值與 -3dB 點
magZ = abs(Zin);
[Zmax, idx_peak] = max(magZ);
f_res = f(idx_peak);

% 找半功率點（-3dB）：0.707*Zmax
target = Zmax / sqrt(2);
idx_lower = find(magZ(1:idx_peak) <= target, 1, 'last');
idx_upper = find(magZ(idx_peak:end) <= target, 1, 'first') + idx_peak - 1;

f1 = f(idx_lower);
f2 = f(idx_upper);
bandwidth = f2 - f1;

Q = f_res / bandwidth;

% 輸出
fprintf('✅ 諧振頻率 f₀ = %.2f Hz\n', f_res);
fprintf('✅ -3dB 頻寬 Δf = %.2f Hz\n', bandwidth);
fprintf('🎯 諧振 Q 值 = %.2f\n', Q);

% Optional: 繪圖
figure;
plot(f, magZ, 'LineWidth', 1.5); grid on;
xlabel('頻率 (Hz)');
ylabel('|Z_{in1}| (Ω)');
title('Impedance Magnitude');
hold on;
yline(target, '--r', '-3dB');
xline(f1, '--k');
xline(f2, '--k');
