%%%Wrapper to call the matrix completion function, perform the task of Subspace
%%%Tracking with missing data

clear;
clc;
% close all
load('Lobby.mat')

addpath('YALL1_v1.4')
addpath('PROPACK')
% addpath('PG-RMC')
% addpath('PG-RMC/Mex')
% addpath('GRASTA')


L = M;
Train = DataTrain;
[n,m] = size(L);
% [~,m] = size(Lx);
% L = zeros(prod(imSize/2),m);
% for i = 1:m
%     x = reshape(Lx(:,i), imSize);
%     L(:,i) = reshape(x(1:2:end,1:2:end),[prod(imSize/2),1]);
% end

% [~,m] = size(DataTrain);
% Train = zeros(prod(imSize/2),m);
% for i = 1:m
%     x = reshape(DataTrain(:,i), imSize);
%     Train(:,i) = reshape(x(1:2:end,1:2:end),[prod(imSize/2),1]);
% end

%% Parameter Initialization
[n,m] = size(L);

r = 30;

t_max = m;

alpha = 60;

%%% TOLERANCE %%%
% tolerance used in cgls(conjugate gradient least squares)
tol = 1e-10;

t_back = t_max;

GRASTA = 0;
norst = 1;
NCRMC = 0;

% 
    rho = 0.1; %denotes fraction of missing entries
    BernMat = rand(n, t_max);
    T = 1 .* (BernMat <= 1 - rho);
    
M = L .* T;
    
%% Calling the Algorithms


if(norst == 1)
        %%% NORST-random %%%
    % Algorithm parameters for NORST
    lambda = 0;
    K = 3;
    ev_thresh = 2e-3;
    omega = 15 ;
%     mu = mean(Train,2);
    mu = 0;
    M_norst = M - mu;

    fprintf('\tNORST\n')
%     Initialization of true subspace
    t_norst = tic;
    fprintf('Initialization...\t');
        P_init = orth(ncrpca(Train, r, 1e-2, 100));        
%         Train = DataTrain - mu;
%         [P_init, ~] = svds(Train,r);
        
    fprintf('Subspace initialized\n'); 
    fprintf('iteration:\n');
    [x_cs_hat, FG, BG, L_hat, P_hat, S_hat, T_hat, t_hat, ...
            P_track_full, t_calc] = ...
            NORST_video(M_norst, mu, T,...
            P_init, ev_thresh, alpha, K, omega);
    t_NORST = toc(t_norst);                
    
%     err_L_fro_norst = norm(L-BG,'fro')/norm(L,'fro');
%     err_nmse_norst = sqrt(mean((L - BG).^2, 1)) ./ sqrt(mean(L.^2, 1));
end

  if(GRASTA == 1)
        fprintf('GRASTA\t');
        
%         [I,J] = find(T);
        t_grasta = tic;
        run_alg_grasta
%        L_hat_grasta = Usg * Vsg';
       t_GRASTA = toc(t_grasta);
       
%        err_L_fro_GRASTA = norm(L-L_hat_grasta,'fro')/norm(L,'fro');
%        err_nmse_grasta = sqrt(mean((L - L_hat_grasta).^2, 1)) ./ sqrt(mean(L.^2, 1));
  end
  
   if(NCRMC == 1)
       t_ncrmc = tic;
%        avg = mean(mean(M,1),2);
%        M2 = M - avg;
       fprintf('NC_RMC\n');
       
       [U_t, SV_t] = ncrmc(M,T);
       L_hat_ncrmc = U_t * SV_t;
       t_NCRMC = toc(t_ncrmc);
       
%        err_L_fro_ncrmc = norm(L-L_hat_ncrmc,'fro')/norm(L,'fro');
%        err_nmse_ncrmc = sqrt(mean((L - L_hat_ncrmc).^2, 1)) ./ sqrt(mean(L.^2, 1));
   end

%% Display the reconstructed video
save('video_RMC_Lobby_NORST_rho10_noSubtraction.mat')
% DisplayVideo(L, T, M, BG, imSize/2,'Lobby_fgbg_omega1.avi')