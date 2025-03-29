function [est, est_N_c]=extract_estimates(glmb,model,meas,est)
%extract estimates via recursive estimator, where  
%trajectories are extracted via association history, and
%track continuity is guaranteed with a non-trivial estimator

%extract MAP cardinality and corresponding highest weighted component
[~,mode] = max(glmb.cdn); 
M = mode-1;
T= cell(M,1);
J= zeros(2,M);
PD = zeros(1,M);

[~,idxcmp]= max(glmb.w.*(glmb.n==M));
for m=1:M
    idxptr= glmb.I{idxcmp}(m);
    T{m,1}= glmb.tt{idxptr}.ah;
    J(:,m)= glmb.tt{idxptr}.l;
    PD(:,m)= glmb.tt{idxptr}.cphd.P_D;
end
est_N_c = glmb.clutter(idxcmp) ;

H= cell(M,1);
for m=1:M
   H{m}= [num2str(J(1,m)),'.',num2str(J(2,m))]; 
end

%compute dead & updated & new tracks
[~,io,is]= intersect(est.H,H);
[~,id,in]= setxor(est.H,H);

est.M= M;
est.T= cat(1,est.T(id),T(is),T(in));
est.J= cat(2,est.J(:,id),J(:,is),J(:,in));
est.PD= cat(2,est.PD(:,id),PD(:,is),PD(:,in));
est.H= cat(1,est.H(id),H(is),H(in));

%write out estimates in standard format
est.N= zeros(meas.K,1);
est.X= cell(meas.K,1);
est.L= cell(meas.K,1);
for t=1:length(est.T)
    ks= est.J(1,t);
    bidx= est.J(2,t);
    tah= est.T{t};
    
    w= model.w_birth{bidx};
    m= model.m_birth{bidx};
    P= model.P_birth{bidx};
    for u=1:length(tah)
        [m,P] = ukf_predict_multiple(model,m,P,est.filter.ukf_alpha,est.filter.ukf_kappa,est.filter.ukf_beta);
        k= ks+u-1;
        emm= tah(u);
        if emm > 0
            [qz,m,P] = ukf_update_multiple(meas.Z{k}(:,emm),model,m,P,est.filter.ukf_alpha,est.filter.ukf_kappa,est.filter.ukf_beta);
            w= qz.*w+eps;
            w= w/sum(w);
        end

        [~,idxtrk]= max(w);
        est.N(k)= est.N(k)+1;
        est.X{k}= cat(2,est.X{k},m(:,idxtrk));
        est.L{k}= cat(2,est.L{k},est.J(:,t));
    end
end
end