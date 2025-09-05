%===============================
%       模擬 + CSV 疊圖
%===============================
clear; close all;

% ─── 字型預設 ─────────────────────────────
set(groot, ...
    'defaultAxesFontName','Times New Roman', ...
    'defaultAxesFontSize',14, ...
    'defaultTextFontName','Times New Roman', ...
    'defaultTextFontSize',14, ...
    'defaultLegendFontName','Times New Roman', ...
    'defaultLegendFontSize',12);

% --- 1. 模型參數 -------------------------------------
Lk1 = 0.069e-3;      
Lk2 = 0.514e-3;      
Lm  = 1.032e-3;      
R1  = 130.4947;      
L1  = 379.2760e-3;   
C1  = 117.7164e-12;  
C0  = 2.822977e-9;   

% --- 2. 頻率掃描範圍 -------------------------------
f   = linspace(20e3, 32e3, 1200);  
w   = 2*pi*f;                      

% --- 3. 計算模型總阻抗 -----------------------------
Zs    = R1 + 1j*w*L1 + 1./(1j*w*C1);
Zt    = ( (1./(1j*w*C0)) .* Zs ) ./ ( (1./(1j*w*C0)) + Zs );
Zb    = 1j*w*Lk2 + Zt;
ZA    = (1j*w*Lm .* Zb) ./ (1j*w*Lm + Zb);
Ztotal = 1j*w*Lk1 + ZA;

% --- 4. 找出補償前諧振點 ---------------------------
[~, idx_min] = min(abs(Ztotal));   
f_res   = f(idx_min);              
w_res   = 2*pi*f_res;              
Z_res   = Ztotal(idx_min);         
X_res   = imag(Z_res);             

fprintf('\n【補償前】 f_res = %.3f kHz, ∠Z = %.2f°\n', f_res/1e3, angle(Z_res)*180/pi);

% --- 5. 串聯補償電容計算 ---------------------------
C_s1 = 1 / (w_res * X_res);
%C_s1 = 82e-9;
fprintf('\n串聯補償電容 Cs1 = %.3e F\n', C_s1);

% --- 6. 加入補償後的阻抗 ---------------------------
Zc1    = 1./(1j*w*C_s1);          
Z_comp = Ztotal + Zc1;            

[~, idx2]   = min(abs(Z_comp));
f_res2      = f(idx2);
Z_res2      = Z_comp(idx2);
phase_res2  = angle(Z_res2) * 180/pi;

fprintf('\n【補償後】 f_res2 = %.3f kHz, ∠Z = %.2f°\n', f_res2/1e3, phase_res2);

% --- 7. 載入實測資料 (ZC = Magnitude, OC = Phase) ---------
zc_data = readmatrix('ZC.CSV', 'NumHeaderLines', 3);
oc_data = readmatrix('OC.CSV', 'NumHeaderLines', 3);

f_meas = zc_data(:,1);             % 頻率
Zmag_meas = zc_data(:,2);          % 實測幅值 (Ω)
Zphase_meas = oc_data(:,2);        % 實測相位 (°)

% --- 8. 繪製波德圖（含實測疊圖） ---------------------
figure('Position',[100 100 1200 600]);

% (a) 幅值圖
subplot(2,1,1);
plot(f/1e3, abs(Ztotal), 'b-', 'LineWidth',2); hold on;
plot(f/1e3, abs(Z_comp), 'r-', 'LineWidth',2);
plot(f_meas/1e3, Zmag_meas, 'g--', 'LineWidth',2);
grid on;
xlabel('Frequency (kHz)');
ylabel('|Z| (Ω)');
title('Impedance Magnitude');
legend('補償前(模擬)','補償後(模擬)','Impedance anayzler(實際量測)','Location','Best');

% (b) 相位圖
subplot(2,1,2);
plot(f/1e3, angle(Ztotal)*180/pi, 'b-', 'LineWidth',2); hold on;
plot(f/1e3, angle(Z_comp)*180/pi, 'r-', 'LineWidth',2);
plot(f_meas/1e3, Zphase_meas, 'g--', 'LineWidth',2);
grid on;
xlabel('Frequency (kHz)');
ylabel('Phase (°)');
title('Impedance Phase');
legend('補償前(模擬)','補償後(模擬)','Impedance anayzler(實際量測)','Location','Best');

% --- 9. 儲存圖檔 ------------------------------------
print(gcf, 'bo_compQ_diag_anay', '-dpng', '-r300');

% --- 10. Q 值分析（補償前） --------------------------
Zmag1 = abs(Ztotal);
Zmin1 = min(Zmag1);
Z3dB1 = sqrt(2)*Zmin1;
idx_left1  = find(Zmag1(1:idx_min)  > Z3dB1, 1, 'last');
idx_right1 = find(Zmag1(idx_min:end) > Z3dB1, 1, 'first') + idx_min - 1;
f1 = f(idx_left1); f2 = f(idx_right1);
Q1 = f_res / (f2 - f1);
fprintf('\n【補償前】 Q = %.2f, 頻寬 = %.2f Hz\n', Q1, (f2 - f1));

% --- 11. Q 值分析（補償後） --------------------------
Zmag2 = abs(Z_comp);
Zmin2 = min(Zmag2);
Z3dB2 = sqrt(2)*Zmin2;
idx_left2  = find(Zmag2(1:idx2)  > Z3dB2, 1, 'last');
idx_right2 = find(Zmag2(idx2:end) > Z3dB2, 1, 'first') + idx2 - 1;
f1_2 = f(idx_left2); f2_2 = f(idx_right2);
Q2 = f_res2 / (f2_2 - f1_2);
fprintf('\n【補償後】 Q = %.2f, 頻寬 = %.2f Hz\n', Q2, (f2_2 - f1_2));
