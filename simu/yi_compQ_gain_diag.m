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
C_s1 = 23.8e-9;
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

% === 11. Vo/Vin 與 Vo/VinC 增益比較圖（模擬） ========================

Vin = 1;  % 假設輸入電壓為 1V

% ➤ 補償前增益模擬（以換能器輸出 Zt 作為 Vo）
I_total = Vin ./ Ztotal;
Vo_total = I_total .* Zt;
Vo_Vin_total = abs(Vo_total ./ Vin);

% ➤ 補償後增益模擬
I_comp = Vin ./ Z_comp;
Vo_comp = I_comp .* Zt;
Vo_Vin_comp = abs(Vo_comp ./ Vin);

% ➤ 繪圖
figure('Position',[100 100 1000 400]);
plot(f/1e3, Vo_Vin_total, 'b-', 'LineWidth',2); hold on;
plot(f/1e3, Vo_Vin_comp, 'r--', 'LineWidth',2);
xlabel('Frequency (kHz)');
ylabel('|Vo / Vin|');
title('Bode diagram');
legend('補償前','補償後','Location','Best');
grid on;
print(gcf, 'yi_compQ_gain_diag', '-dpng', '-r300');
