function XC = extract_subfeatures(X, D, im, params)

    
    % Parameters
    rfSize = params.rfSize;
    regSize = params.regSize;
    alpha = params.alpha;
    regSize(1:2) = [size(im, 1) size(im, 2)];
    
    % Initalizations
    k = size(D.codes, 1);
    prows = regSize(1) - rfSize(1) + 1;
    pcols = regSize(2) - rfSize(2) + 1;
    r = rfSize(1) * rfSize(2) * rfSize(3);
    f = k * prows * pcols;
    XC = zeros(size(X, 1), f);
    
    % Main loop
    for i = 1:size(X, 1)
        
        %if ~mod(i, ceil(size(X,1)/50)); fprintf('.'); end
        
        % Extract overlapping sub-patches into rows of 'patches'
        ims = regSize(1) * regSize(2); patches = [];
        for j = 1:regSize(3)
            patches = [patches; im2col(reshape(X(i,(j-1)*ims+1:j*ims), [regSize(1) regSize(2)]), [rfSize(1) rfSize(2)])];
        end
        patches = patches';
    
        % Contrast normalization
        patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2) + 10));
        %patches = bsxfun(@rdivide, bsxfun(@minus, patches, params.patchmean), params.patchvar);
        
        % Whitening
        %patches = bsxfun(@minus, patches, D.mean) * D.whiten;
        patches = bsxfun(@minus, patches, D.mean);
        
        % Soft activation
        xc = patches * D.codes';
        %xc = tanh(xc);
        %patches = max(xc - alpha, 0);
        %patches = [ max(xc - alpha, 0), -max(-xc - alpha, 0) ];
        patches = xc;
        
        % Localized normalization
        %sd = std(patches, [], 2);
        %patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches, 2)), max(mean(sd), sd));
        %patches(isnan(patches)) = 0;
        
        % Features
        patches = reshape(patches, prows, pcols, k);
        features = patches(:)';
        XC(i,:) = features;
    end
    %disp(' ');


end

