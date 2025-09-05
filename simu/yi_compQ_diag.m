%===============================
%===============================
clear; close all;

% ─── 全域字型 & 大小 預設 ───────────────────────────
set(groot, ...
    'defaultAxesFontName','Times New Roman', ...
    'defaultAxesFontSize',14, ...
    'defaultTextFontName','Times New Roman', ...
    'defaultTextFontSize',14, ...
    'defaultLegendFontName','Times New Roman', ...
    'defaultLegendFontSize',12);

% --- 1. 參數定義 ------------------------------------
Lk1 = 0.876e-3;      % H, 原邊漏感
Lk2 = 1.994e-3;      % H, 次邊漏感
Lm  = 1.124e-3;      % H, 磁化電感
R1  = 900.72;      % Ω, 換能器等效電阻
L1  = 901.37e-3;   % H, 換能器等效電感
C1  = 50.75e-12;  % F, 換能器等效串聯電容
C0  = 519.01e-12;   % F, 換能器平行電容

% --- 2. 頻率掃描範圍 --------------------------------
f   = linspace(20e3, 32e3, 1200);  % Hz
w   = 2*pi*f;                     % rad/s

% --- 3. 計算總阻抗 Ztotal -------------------------
% 3.1 換能器等效阻抗 Zt
Zs    = R1 + 1j*w*L1 + 1./(1j*w*C1);
Zt    = ( (1./(1j*w*C0)) .* Zs ) ./ ( (1./(1j*w*C0)) + Zs );

% 3.2 反射至原邊的支路阻抗 Zb
Zb    = 1j*w*Lk2 + Zt;

% 3.3 並聯磁化支路阻抗 ZA
ZA    = (1j*w*Lm .* Zb) ./ (1j*w*Lm + Zb);

% 3.4 加上原邊漏感 Lk1 得到總阻抗
Ztotal = 1j*w*Lk1 + ZA;

% --- 4. 找出不含 Cs1 時的諧振點 -------------------
[~, idx_min] = min(abs(Ztotal));   % 取阻抗最小點索引
f_res   = f(idx_min);              % 諧振頻率 (Hz)
w_res   = 2*pi*f_res;              % 諧振角頻率
Z_res   = Ztotal(idx_min);         % 諧振點阻抗
X_res   = imag(Z_res);             % 虛部

fprintf('\n【補償前】 f_res = %.3f kHz, ∠Z = %.2f°\n', f_res/1e3, angle(Z_res)*180/pi);

% --- 5. 計算串聯補償電容 Cs1 --------------------
C_s1 = 1 / (w_res * X_res);
fprintf('\n串聯補償電容 Cs1 = %.3e F\n', C_s1);

% --- 6. 加上 Cs1，並輸出新諧振資訊 -------------
Zc1    = 1./(1j*w*C_s1);          % Cs1 的阻抗
Z_comp = Ztotal + Zc1;            % 串聯相加

[~, idx2]   = min(abs(Z_comp));
f_res2      = f(idx2);
Z_res2      = Z_comp(idx2);
phase_res2  = angle(Z_res2) * 180/pi;

fprintf('\n【補償後】 f_res2 = %.3f kHz, ∠Z = %.2f°\n', f_res2/1e3, phase_res2);

% --- 7. 繪製波德圖 --------------------------------
figure('Position',[100 100 1200 600]);

% (a) 幅值 (線性 Ω)，同時比較未補償與補償後
subplot(2,1,1);
plot(f/1e3, abs(Ztotal), 'LineWidth',2); hold on;
plot(f/1e3, abs(Z_comp), 'LineWidth',2);
grid on; hold off;
xlabel('Frequency (kHz)');
ylabel('|Z| (Ω)');
title('Impedance Magnitude');
legend('補償前','補償後','Location','Best');

% (b) 相位 (°)，同時比較未補償與補償後
subplot(2,1,2);
plot(f/1e3, angle(Ztotal)*180/pi, 'LineWidth',2); hold on;
plot(f/1e3, angle(Z_comp)*180/pi, 'LineWidth',2);
grid on; hold off;
xlabel('Frequency (kHz)');
ylabel('Phase (°)');
title('Impedance Phase');
legend('補償前','補償後','Location','Best');

% --- 8. 儲存 Figure --------------------------------
hFig = gcf;
print(hFig, 'yi_compQ_diag', '-dpng', '-r300');

% === 9. 補償前 Q 值（半功率點法） ========================
Zmag1 = abs(Ztotal);                      % 取補償前幅值
Zmin1 = min(Zmag1);
Z3dB1 = sqrt(2) * Zmin1;

idx_left1  = find(Zmag1(1:idx_min)  > Z3dB1, 1, 'last');
idx_right1 = find(Zmag1(idx_min:end) > Z3dB1, 1, 'first') + idx_min - 1;

f1 = f(idx_left1);
f2 = f(idx_right1);
Q1 = f_res./(f2 - f1);

fprintf('\n【補償前】 Q = %.2f, 頻寬 = %.2f Hz\n', Q1, (f2 - f1));

% === 10. 補償後 Q 值（半功率點法） ========================
Zmag2 = abs(Z_comp);
Zmin2 = min(Zmag2);
Z3dB2 = sqrt(2) * Zmin2;

idx_left2  = find(Zmag2(1:idx2)  > Z3dB2, 1, 'last');
idx_right2 = find(Zmag2(idx2:end) > Z3dB2, 1, 'first') + idx2 - 1;

f1_2 = f(idx_left2);
f2_2 = f(idx_right2);
Q2 = f_res2 / (f2_2 - f1_2);

fprintf('\n【補償後】 Q = %.2f, 頻寬 = %.2f Hz\n', Q2, (f2_2 - f1_2));
