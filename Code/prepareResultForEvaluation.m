function all_record = prepareResultForEvaluation(est, meas, label)
    % Init structures.
    idswitch = 0;
    truepos = 0;
    falseneg = 0;
    falsepos = 0;

    % distances
    distances = 0.;
    distances3D = 0.;
    distancesBB = 0.;
    premapping = [];
    mapping = [];
    gt = 0;
    all_record = cell(size(meas.Z, 1), 1);
    for t=1:length(est.T)
        ks= est.J(1,t);
        bidx= est.J(2,t);
        tah= est.T{t};

%         w= model.w_birth{bidx};
%         m= model.m_birth{bidx};
%         P= model.P_birth{bidx};
        
        for u=1:length(tah)
            %[m,P] = ukf_predict_multiple(model,m,P,est.filter.ukf_alpha,est.filter.ukf_kappa,est.filter.ukf_beta);
            k= ks+u-1;
            emm= tah(u);
%             if emm > 0
%                 [qz,m,P] = ukf_update_multiple(meas.Z{k}(:,emm),model,m,P,est.filter.ukf_alpha,est.filter.ukf_kappa,est.filter.ukf_beta);
%                 w= qz.*w+eps;
%                 w= w/sum(w);
%             end
            all_record{k} = [all_record{k}; str2double(est.H(t)) emm];

        end
    end
   
    for frame_num=1:length(all_record)
    % Check if the mapping procedure contraditcs previous mapping.
    % If so replace mapping and count it as an id switch.
        if length(mapping)  > 0 &&  length(premapping) > 0
          for o=1:length(mapping(:,1))
             idx = find(mapping(o,1) == premapping(:,1));
             % if contraditcs count as ID switch
             if mapping(o,2) ~= premapping(idx,2)
                idswitch = idswitch + 1;
                idswitchTmp = idswitchTmp + 1;
             else
                % count as TP and evaluate the MOTP.
                truepos = truepos + 1;
                h = find(idxTracks == mapping(o,2));
                idxo= find(indexObj(:,h) == mapping(o,1));
                distances = distances + score(idxo,h);
                trueposTmp = trueposTmp + 1;
             end

          end
        elseif length(mapping) > 0
          for o=1:length(mapping(:,1))
             % count as TP and evaluate the MOTP.
             truepos = truepos + 1;
             h = find(idxTracks == mapping(o,2));
             idxo= find(indexObj(:,h) == mapping(o,1));
             distances = distances + score(idxo,h);
             trueposTmp = trueposTmp + 1;
          end
        elseif length(premapping) > 0
          mapping = premapping;
        end
    end
    
    % Get unmapped object and put it in the current mapping.
    unmappedObj = [];
    if ~isempty(mapping)
      unmappedObj = setdiff(currentAllLabel,mapping(:,1));
    end
    for unmap=1:length(unmappedObj)
      if ~isempty(premapping)
         idxunmapped = find(premapping(:,1) == unmappedObj(unmap));
         mapping = [mapping; premapping(idxunmapped,:)];
      end
    end

    % Save current mapping as previous.
    premapping = mapping;
end