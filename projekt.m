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

X_var_names = cell(1,6);
X_var_names{1} = 'Konstanta';
X_var_names{2} = 'Y_{t-1}';
X_var_names{3} = 'Unemployment';
X_var_names{4} = 'Unemployment difference';
X_var_names{5} = 'Inflation'; 
X_var_names{6} = 'Interest rates';

%% Prostor pro vyhozeni nekterych promennych
ommit_index = [];
% ommit_index = [1,2,6];
X_var_names(ommit_index) = [];
%kdyz chci pouzit model s vynechanim nekterych promennych
   X(:, ommit_index) = [];
   beta_0(ommit_index) = [];
   V_0(:,ommit_index) = [];
   V_0(ommit_index, :) = [];

test_vars = 1:6;
test_values = zeros(1,6);
[beta, h,SD_ratio] = gibbs_sampler(y,X,beta_0, h_0, V_0, nu_0,test_vars, test_values);

%%posteriorni analyza parametru beta
mean(beta,2)
sqrt(var(beta,0,2))

for (i=1:length(test_vars)
    fprintf('SD pomÏr hustot pro model, kde promÏnn· Ë.%d=%d je rovn˝',...
        test_vars(i),test_values(i),SD_ratio(i));
end

for i = 1:size(beta,1)
   figure
   hist(beta(i,:),100);
   title(X_var_names(i));
end



