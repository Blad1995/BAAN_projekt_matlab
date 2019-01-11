%% Projekt Bayesianska analyza
clc;
clear;
close all;


%% Nactení dat
load('Slovakia_macro_data.mat');

%% Vytvoreni upravených promennych
% mezirocni procentualni rust realneho GDP (uz zkraceneho o 
% prvni obdobi - kvuli zpozdene promenne)
N_whole = length(DATE);
GDP_diff = (GDP(5:end))./GDP(1:N_whole - 4) - 1;
U_diff = (Uneployment(6:end))./Uneployment(2:N_whole - 4) - 1;
GDP_diff_lag1 = GDP_diff(1:N_whole - 5);

% vysledne pouzite promenne (zkracene)
I = Inflation(6:end);
DATE_short = DATE(6:end);
U = Uneployment(6:end);
R = Interest_rates(6:end);
GDP_diff = GDP_diff(2:end);

N_final = length(GDP_diff);


S = 10^5;
S_0 = S/2;
S_1 = S - S_0;