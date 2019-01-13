%% Projekt Bayesianska analyza
clc;
clear;
close all;


%% Nacten� dat
load('Slovakia_macro_data.mat');
addpath('Support\');
DATE = datetime(DATE,'InputFormat','dd.MM.yyyy');

%% Vytvoreni upraven�ch promennych
% mezirocni procentualni rust realneho GDP (uz zkraceneho o
% prvni obdobi - kvuli zpozdene promenne)
GDP_diff = (GDP(5:end))./GDP(1:end - 4) - 1;

U_diff = (Uneployment(5:end))- Uneployment(1:end - 4);
I_diff_a = (Inflation_interannual(5:end)) - Inflation_interannual(1:end - 4);
R_diff = (Interest_rates(5:end)) - Interest_rates(1:end - 4);

% % p��padn� by se daly vyu��t procentu�ln� zm�ny
% U_diff = (Uneployment(5:end))./ Uneployment(1:end - 4) - 1;
% I_diff_a = (Inflation_interannual(5:end))./ Inflation_interannual(1:end - 4) - 1;
% R_diff = (Interest_rates(5:end))./ Interest_rates(1:end - 4) - 1;

% nakonec jsme radeji pouzili mezictvrtletni rozdily
% lepsi charakteristiky tykajici se stacionarity
% vynechali jsme prvni dve pozorovani kvuli tvorbe *_diff promennych (1. pozorovani) a
% kvuli zpozdene promenne GDP_diff_lag1 (2. pozorovani)
% GDP_diff = (GDP(2:end))./GDP(1:end - 1) - 1;
% U_diff = (Uneployment(3:end)) -Uneployment(2:end - 1);
% I_diff = (Inflation(3:end)) - Inflation(2:end - 1);
% R_diff = (Interest_rates(3:end)) - Interest_rates(2:end - 1);
% GDP_diff_lag1 = GDP_diff(1:end - 1);
I = Inflation(5:end);
DATE_short = DATE(5:end);
U = Uneployment(5:end);
R = Interest_rates(5:end);

N_final = length(GDP_diff);

%% Stanoven� apriorn�ch parametr�

beta_0 = [0;-0.7; -0.2; -1; -1; -2; -2];
V_0 = diag([0.5^2, 0.8^2, 0.8^2, 2^2, 2^2, 3^2, 3^2]);
nu_0 = 15;
s2_0 = var(GDP_diff./4) ;   %tohle je zkouska jestli by to davalo smysl cca
% s2_0 = 0.05^2;    %apriorni rozptyl nahodnych slozek -
%teda smerodajn� dochylka 10 (n�hodn� chyba m� rozdelen� N(0,s^2))
%- mohla by by� aj men�ia ak by som viac veril svojmu modelu
h_0 = 1/s2_0;   %apriorni presnost chyby

%% Definice prom�nnych pro model
y = GDP_diff;    %vysvetlovana promenna
X = [ones(N_final,1), U, U_diff, I, I_diff_a, R, R_diff];  %vysvetlujici promenne

X_var_names = cell(1,6);
X_var_names{1} = 'Konstanta';
X_var_names{2} = 'Unemployment';
X_var_names{3} = 'Unemployment difference';
X_var_names{4} = 'Inflation';
X_var_names{5} = 'Inflation difference';
X_var_names{6} = 'Interest rates';
X_var_names{7} = 'Interest rates difference';



%% Prostor pro vyhozeni nekterych promennych
%index urcujici, ktere promenne vyhodim
% ommit_index = [2,4,5]; %model bez Unemployment
 ommit_index = [4,5]; %model s Unemployment
%  ommit_index = [] %pln� model
X_var_names(ommit_index) = [];
%kdyz chci pouzit model s vynechanim nekterych promennych
X(:, ommit_index) = [];
beta_0(ommit_index) = [];
V_0(:,ommit_index) = [];
V_0(ommit_index, :) = [];


test_vars = 1:length(beta_0); %nastavuji cisla promennych, ktere chci testovat
test_values = zeros(1,length(beta_0)); %nastavuju prislusne hodnoty, ktere testuji
[beta, h, SD_ratio, cng] = gibbs_sampler(y,X,beta_0, h_0, V_0, nu_0,test_vars, test_values);

%pocet vzorku S1 = length(h)
S1 = length(h);


%% Testovani hypotezy
if (size(ommit_index) == [1 2] & ommit_index == [4, 5])
    % testovani hypotezy v modelu s Unemployment
    % hypoteza o negativnom vplyve nezamestnanosti Beta 2 <= 0
    pc = sum(beta(2,:) <= 0)/S1;
    fprintf('\n Pravdepodobnost beta_4 <= 0 a odpovidajici Bayesuv faktor\n')
    fprintf('pc = %6.4f      BF = %6.4f\n',pc,pc/(1-pc))
end

%% posteriorni analyza parametru beta
beta_means = mean(beta,2);
beta_sd = sqrt(var(beta,0,2));
fprintf('_________________________________________\n');
for (i=1:length(test_vars))
    fprintf('SD pom�r hustot pro omezen� model,\nkde prom�nn� beta_{%s} = %d je rovn� %6.4f\n\n',...
        X_var_names{i},test_values(i),SD_ratio(i));
end

fprintf('__________________________________________\n');
for (i = 1:length(cng.CD)-1)
    fprintf('CD statistika prom�nn� beta_%s byla: %7.4f\n',X_var_names{i},cng.CD(i));
end

%Intervaly najvy��ej posteri�rnej hustoty HPDI
HPDI_beta = quantile(beta,[0.025,0.975],2);
HPDI_h = quantile(h,[0.025,0.975],2);

%% Vykresleni vysledku - tabulky a grafy
%apriorni str. hodnoty a sm. odchylky
%beta_0, h0 - apriorni str. hodnoty
std_beta_0 = sqrt(diag(V_0)); %vektor apriornich sm. odchylek beta
std_h_0 = sqrt(2*h_0^2/nu_0); %apriorni sm. odchylka presnosti chyby
fprintf('__________________________________________\n');
fprintf('Souhrnn� statistiky:\n');
fprintf('Prom�nn�\tPr�m�r\t\tSm. odchylka\t\tHPDI_low\t\tHPDI_high\t\tCD\n');
for i=1:length(beta_0)
    fprintf('beta_%d\t\t%6.4f\t\t\t%6.4f\t\t\t%6.4f\t\t\t%6.4f\t\t\t%6.4f\n',...
        i,beta_means(i),beta_sd(i),HPDI_beta(i,:),cng.CD(i));
end
fprintf('h\t\t\t%6.4f\t\t%6.4f\t\t%6.4f\t\t%6.4f\t\t%6.4f\n',...
    mean(h),sqrt(var(h)),HPDI_h(1),HPDI_h(2),cng.CD(length(beta_0)+1));

for i = 1:size(beta,1)
    subplot(3,ceil(length(beta_0)/3),i);
    hist(beta(i,:),100);
    title(['Simulovane hodnoty \beta_{',X_var_names{i},'}']);
end
figure
hist(h,100)
title('h')

%% zobrazenie konvergencie
figure
for ii=1:length(beta_0)
    subplot(3,ceil(length(beta_0)/3),ii);
    plot(beta(ii,1:500:end));
    axis([0 66 -inf inf]);
    ylabel(['\beta_',num2str(ii)]);
    title(['Zobrazeni konvergence \beta_{',X_var_names{i},'}']);
end

figure
plot(h(:,1:500:end))
axis([0 66 -inf inf])
ylabel('h')
title('Zobrazeni konvergence h');


%% Simulace
y_pred = zeros(N_final,S1);
for s=1:S1
    y_pred(:,s)= X*beta(:,s)+randn(length(y),1)*sqrt(1/h(s));
end
%jiny zpusob generovani odhadovanych hodnnot
% E_y_pred1 = X*beta_means;

E_y_pred = mean(y_pred,2);
std_y_pred = sqrt(var(y_pred,0,2));

%intervaly spolehlivosti predikce
y_pred_low = E_y_pred + 1.96 * std_y_pred;
y_pred_high = E_y_pred - 1.96*std_y_pred;


%vykresleni simulovanych hodnot vuci puvodnim
figure
plot(datenum(DATE_short),[y, E_y_pred]);
hold on;
plot(datenum(DATE_short),[y_pred_low, y_pred_high], '--');
title('Vykresleni puvodnich hodnot GDP_{diff} vuci simulovanym');
legend('Puvodni hodnota','Simulovane hodnoty',...
    'Dolni interval spolehlivosti','Horni interval spolehlivosti');
datetick('x','yyyy','keepticks');
xlabel('rok');
ylabel('GDP_{diff}');
