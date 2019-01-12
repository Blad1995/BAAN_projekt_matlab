%% Projekt Bayesianska analyza
clc;
clear;
close all;


%% Nacten� dat
load('Slovakia_macro_data.mat');
addpath('Support\');

%% Vytvoreni upraven�ch promennych
% mezirocni procentualni rust realneho GDP (uz zkraceneho o 
% prvni obdobi - kvuli zpozdene promenne)
GDP_diff = (GDP(5:end))./GDP(1:end - 4) - 1;
U_diff = (Uneployment(6:end))- Uneployment(2:end - 4);
I_diff_a = (Inflation_interannual(6:end)) - Inflation_interannual(2:end - 4);
% R_diff = (Interest_rates(6:end)) - Interest_rates(2:end - 4);

% U_diff = (Uneployment(6:end))./ Uneployment(2:end - 4) - 1;
% I_diff_a = (Inflation_interannual(6:end))./ Inflation_interannual(2:end - 4) - 1;
R_diff = (Interest_rates(6:end))./ Interest_rates(2:end - 4) - 1;
GDP_diff_lag1 = GDP_diff(1:end-1);

% nakonec jsme radeji pouzili mezictvrtletni rozdily
% lepsi charakteristiky tykajici se stacionarity
% vynechali jsme prvni dve pozorovani kvuli tvorbe *_diff promennych (1. pozorovani) a
% kvuli zpozdene promenne GDP_diff_lag1 (2. pozorovani)
% GDP_diff = (GDP(2:end))./GDP(1:end - 1) - 1;
% U_diff = (Uneployment(3:end)) -Uneployment(2:end - 1);
% I_diff = (Inflation(3:end)) - Inflation(2:end - 1);
% R_diff = (Interest_rates(3:end)) - Interest_rates(2:end - 1);
% GDP_diff_lag1 = GDP_diff(1:end - 1);
I = Inflation(6:end);
DATE_short = DATE(6:end);
U = Uneployment(6:end);
R = Interest_rates(6:end);
GDP_diff = GDP_diff(2:end);

N_final = length(GDP_diff);

%% Stanoven� apriorn�ch parametr�

beta_0 = [0; 1; -0.7; -0.2; -1; -1; -2; -2];
V_0 = diag([0.5^2, 0.2^2, 0.8^2, 0.8^2, 2^2, 2^2, 3^2, 3^2]);
nu_0 = 15;
s2_0 = var(GDP_diff./4) ;   %tohle je zkouska jestli by to davalo smysl cca
% s2_0 = 0.05^2;    %apriorni rozptyl nahodnych slozek - 
                  %teda smerodajn� dochylka 10 (n�hodn� chyba m� rozdelen� N(0,s^2))
                  %- mohla by by� aj men�ia ak by som viac veril svojmu modelu 
h_0 = 1/s2_0;   %apriorni presnost chyby

%% Definice prom�nnych pro model
y = GDP_diff;    %vysvetlovana promenna
X = [ones(N_final,1), GDP_diff_lag1, U, U_diff, I, I_diff_a, R, R_diff];  %vysvetlujici promenne

X_var_names = cell(1,6);
X_var_names{1} = 'Konstanta';
X_var_names{2} = 'Y_{t-1}';
X_var_names{3} = 'Unemployment';
X_var_names{4} = 'Unemployment difference';
X_var_names{5} = 'Inflation'; 
X_var_names{6} = 'Inflation difference'; 
X_var_names{7} = 'Interest rates';
X_var_names{8} = 'Interest rates difference';

%% Prostor pro vyhozeni nekterych promennych
ommit_index = [2,6,8];   %index urcujici, ktere promenne vyhodim
% ommit_index = [2,3,5,6,8];
X_var_names(ommit_index) = [];
%kdyz chci pouzit model s vynechanim nekterych promennych
   X(:, ommit_index) = [];
   beta_0(ommit_index) = [];
   V_0(:,ommit_index) = [];
   V_0(ommit_index, :) = [];


test_vars = 1:length(beta_0); %nastavuji cisla promennych, ktere chci testovat
test_values = zeros(1,length(beta_0)); %nastavuju prislusne hodnoty, ktere testuji
[beta, h, SD_ratio, cng] = gibbs_sampler(y,X,beta_0, h_0, V_0, nu_0,test_vars, test_values);

%%posteriorni analyza parametru beta
beta_means = mean(beta,2);
beta_sd = sqrt(var(beta,0,2));

fprintf('_________________________________________\n');
for (i=1:length(test_vars))
    fprintf('SD pom�r hustot pro model, kde prom�nn� �.%d=%d je rovn� %6.4f\n',...
        test_vars(i),test_values(i),SD_ratio(i));
end

fprintf('__________________________________________\n');
fprintf('CD statistika byla: %7.4f\n',cng.CD);

%Intervaly najvy��ej posteri�rnej hustoty HPDI
HPDI_beta = quantile(beta,[0.025,0.975],2);   
HPDI_h = quantile(h,[0.025,0.975],2); 

fprintf('__________________________________________\n');
fprintf('Souhrnn� statistiky:\n');
fprintf('Prom�nn�\tPr�m�r\t\tSm. odchylka\t\tHPDI_low\t\tHPDI_high\t\tCD\n');
for i=1:length(beta_0)
    fprintf('beta_%d\t\t%6.4f\t\t\t%6.4f\t\t\t%6.4f\t\t\t%6.4f\t\t\t%6.4f\n',...
        i,beta_means(i),beta_sd(i),HPDI_beta(i,:),cng.CD(i));
end


for i = 1:size(beta,1)
   subplot(3,ceil(length(beta_0)/3),i);
   hist(beta(i,:),100);
   title(X_var_names(i));
end
figure
hist(h,100)
title('h')


