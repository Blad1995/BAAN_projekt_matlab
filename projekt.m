%% Projekt Bayesiansk� anal�za
clc;
clear;
close all;


%% Na�ten� dat
load('Slovakia_macro_data.mat');

%% Vytvo�en� upraven�ch prom�nn�ch
%meziro�n� procentu�ln� r�st realn�ho GDP (u� zkr�cen�ho o prvn� obdob� - kv�li zpozd�n� prom�nn�)
N_whole = length(DATE);
GDP_diff = (GDP(5:end))./GDP(1:N_whole - 4) - 1;
U_diff = (Uneployment(6:end))./Uneployment(2:N_whole - 4) - 1;
GDP_diff_lag1 = GDP_diff(1:N_whole - 5);

% v�sledn� pou�it� prom�nn� (zkr�cen�)
I = Inflation(6:end);
DATE_short = DATE(6:end);
U = Uneployment(6:end);
R = Interest_rates(6:end);
GDP_diff = GDP_diff(2:end);

N_final = length(GDP_diff);


S = 10^5;
S_0 = S/2;
S_1 = S - S_0;