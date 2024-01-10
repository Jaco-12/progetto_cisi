% function q_smoother = Regolarizzazione_EKF()
    q_hat_pred = get(out, "q_hat_computed");
    P_k_pred = get(out, "P_k_computed");
    F_k = get(out, "F_k_computed");
    
    P_k_corr = get(out, "P_k_corr");
    q_hat_corr = get(out, "q_hat_corr_k");
    
    % q_hat_computed = [Time, Data]
    N = size(q_hat_pred.Data, 1);
    
    q_smoother = zeros(4,1,N);
    P_smoother = zeros(4,4,N);
    
    q_smoother(:,:,N) = q_hat_corr.Data(:,N);
    P_smoother(:,:,N) = P_k_corr.Data(:,:,N);
    
    for k = (N-1):-1:1
        Ck = P_k_corr.Data(:,:,k) * F_k.Data(:,:,k+1)' * inv(P_k_pred.Data(:,:,k+1));
    
        q_smoother(:,:,k) = q_hat_corr.Data(:,k) + Ck*(q_smoother(:,:,k+1) - q_hat_pred.Data(k+1,:)');
    
        P_smoother(:,:,k) = P_k_corr.Data(:,:,k) + Ck*(P_smoother(:,:,k+1) - P_k_pred.Data(:,:,k+1))*Ck';
    end
% end