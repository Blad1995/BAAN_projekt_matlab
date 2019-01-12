%% Projekt Bayesianska analyza
clc;
clear;
close all;


%% NactenÌ dat
load('Slovakia_macro_data.mat');
addpath('Support\');

%% Vytvoreni upraven˝ch promennych
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

%% StanovenÌ apriornÌch parametr˘

beta_0 = [0; 1; -0.3; -0.3; -1; -2];
V_0 = diag([0.5^2, 0.2^2, 0.8^2, 0.8^2, 2^2, 3^2]);
nu_0 = 3;
s2_0 = 0.5^2;      %apriorni rozptyl nahodnych slozek - 
                  %teda smerodajn· dochylka 10 (n·hodn· chyba m· rozdelenÌ N(0,s^2))
                  %- mohla by byù aj menöia ak by som viac veril svojmu modelu 
h_0 = 1/s2_0;   %apriorni presnost chyby

%% Definice promÏnnych pro model
y = GDP_diff;    %vysvetlovana promenna
X = [ones(N_final,1), GDP_diff_lag1, U, U_diff, I, R];  %vysvetlujici promenne



[beta, h] = gibbs_sampler(y,X,beta_0, h_0, V_0, nu_0, [2,3,4]);


