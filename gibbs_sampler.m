function [beta, h] = gibbs_sampler(y,X, beta_0, h_0,V_0, nu_0,index_ommit_beta)

if (nargin < 6)
   error('Spatny pocet argumentu: gibbs_sampler(y,X, beta_0, h_0,V_0, nu_0)'); 
end

if(nargin == 7)
   %kdyz chci pouzit model s vynechanim nekterych promennych
   X(:, index_ommit_beta) = [];
   beta_0(index_ommit_beta) = [];
   V_0(:,index_ommit_beta) = [];
   V_0(index_ommit_beta, :) = [];
end


S = 10^5;
S_0 = floor(S * 2/3);   %zahodime prvnich 2/3 vzorku
S_1 = S - S_0;          %nechame si 1/3 vzorku pro post. analyzu
N = length(y);

beta = zeros(length(beta_0),S); %prostor pro ukladani vzorku 
h = zeros(1, S); %vzorky pro h (jeden riadok a S stlpcov - vektor dlzky S)



% nastaveni vychozich hodnot
beta(:,1) = beta_0;
h(1) = h_0;

%% Gibbsuv vzorkovac
for s=2:S
        %p(lambda|h,y)~N(lambda_1,V_1) - lambda podminene na h a y
        V_1 = inv(inv(V_0)+h(s-1)*X'*X); %(4.4) dle Koop(2008) (X' - transponovana matice X) 
        beta_1 = V_1*(inv(V_0)*beta_0+h(1,s-1)*X'*y); %(4.5) dle Koop (2008) 
        beta(:,s) = beta_1 + norm_rnd(V_1); %(4.7)
        
        %p(h|lambda,y)~G(h_1,nu_1)
        nu_1 = N + nu_0; %N = length(y) 
        h_1 = (1/nu_1*((y - X*beta(:,s))'*(y-X*beta(:,s)) + nu_0*1/h_0))^-1; %(4.10) 
        h(s) = gamm_rnd_Koop(h_1, nu_1,1); %(4.8)
                        
end

%% Posteriorni analyza
%vyhozeni prvnich S0 vzorku
    beta(:,1:S_0) = [];
    h(:,1:S_0) = []; 
    