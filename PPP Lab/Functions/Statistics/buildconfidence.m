function [col2d,labels2d,col3d,labels3d,collumnlabels] = buildconfidence(type,east,north,up)

    if strcmpi(type,'formulai')
        % 2D precision - using std
        sigmaeast  = std(east);
        sigmanorth = std(north);
        sigmaup    = std(up);
        
        DMRS  = sqrt(sigmaeast.^2+sigmanorth.^2);
        DMRS2 = 2*DMRS; % 65%
        CEP50 = 0.62*sigmanorth+0.56*sigmaeast;
        CEP95 = 2.08*CEP50;
        
        % 3D precision - using std
        MRSE  = sqrt(sigmaeast.^2+sigmanorth.^2+sigmaup.^2);
        MRSE2 = 2*MRSE;
        SEP50 = 0.513*(sigmaeast+sigmanorth+sigmaup);
        SEP95 = 1.122*MRSE;

        
%         CEP50 = 0.75*DMRS;
%         CEP80 = 1.28*DMRS;
%         CEP90 = 1.6*DMRS;
%         CEP95 = 2.0*DMRS;
        
%         col2d         = [DMRS,CEP50,CEP80,CEP90,CEP95,CEP99];
%         col3d         = [MRSE,SEP50,SEP80,SEP90,SEP95,SEP99];
%         labels3d      = ['\textbf{DMRS},\textbf{SEP50},\textbf{SEP80},\textbf{SEP90},\textbf{SEP95},\textbf{SEP99}'];    
%         labels2d      = ['\textbf{MRSE},\textbf{CEP50},\textbf{CEP80},\textbf{CEP90},\textbf{CEP95},\textbf{CEP99}'];
%         collumnlabels = ['\textbf{Confidence Region},\textbf{Value (m)}'];
        
        col2d         = [DMRS,DMRS2,CEP50,CEP95];
        col3d         = [MRSE,MRSE2,SEP50,SEP95];
        labels3d      = ['\textbf{MRSE},\textbf{MRSE2},\textbf{SEP50},\textbf{SEP95}'];    
        labels2d      = ['\textbf{DMRS},\textbf{DMRS2},\textbf{CEP50},\textbf{CEP95}'];
        collumnlabels = ['\textbf{Confidence Region},\textbf{Value (m)}'];
        
    elseif strcmpi(type,'crr')
        
        sigmaeast  = std(east);
        sigmanorth = std(north);
        sigmaup    = std(up);
        
        std2dvec = cov(east,north);%[sigmaeast,sigmanorth];
        DMRS     = sqrt(sigmaeast^2+sigmanorth^2);
        CEP50    = crr(std2dvec,0.5);
        CEP80    = crr(std2dvec,0.8);
        CEP90    = crr(std2dvec,0.9);
        CEP95    = crr(std2dvec,0.95);
        CEP99    = crr(std2dvec,0.99); % 3 sigma
        
        % 3D precision - using std
        std3dvec = cov([east,north,up]);
        MRSE     = sqrt(sigmaeast^2+sigmanorth^2+sigmaup^2);
        SEP50    = crr(std3dvec,0.5);
        SEP80    = crr(std3dvec,0.8);
        SEP90    = crr(std3dvec,0.9);
        SEP95    = crr(std3dvec,0.95);
        SEP99    = crr(std3dvec,0.99); % 3 sigma 
        
        
        col2d         = [DMRS,CEP50,CEP80,CEP90,CEP95,CEP99];
        col3d         = [MRSE,SEP50,SEP80,SEP90,SEP95,SEP99];
        labels3d      = ['\textbf{DMRS},\textbf{SEP50},\textbf{SEP80},\textbf{SEP90},\textbf{SEP95},\textbf{SEP99}'];    
        labels2d      = ['\textbf{MRSE},\textbf{CEP50},\textbf{CEP80},\textbf{CEP90},\textbf{CEP95},\textbf{CEP99}'];
        collumnlabels = ['\textbf{Confidence Region},\textbf{Value (m)}'];
        
    elseif strcmpi(type,'cov')
        cov2d    = cov(east,north);
        CEP50    = crr(cov2d ,0.5);
        CEP80    = crr(cov2d ,0.8);
        CEP90    = crr(cov2d ,0.9);
        CEP95    = crr(cov2d ,0.95);
        CEP99    = crr(cov2d ,0.99); % +/- 3 sigma

        % 3D precision - using cov
        cov3d    = cov([east,north,up]);
        SEP50    = crr(cov3d ,0.5);
        SEP80    = crr(cov3d ,0.8);
        SEP90    = crr(cov3d ,0.9);
        SEP95    = crr(cov3d ,0.95);
        SEP99    = crr(cov3d ,0.99); % +/- 3 sigma        
        
        col2d         = [CEP50,CEP80,CEP90,CEP95,CEP99];
        col3d         = [SEP50,SEP80,SEP90,SEP95,SEP99];
        labels3d      = ['\textbf{SEP50},\textbf{SEP80},\textbf{SEP90},\textbf{SEP95},\textbf{SEP99}'];    
        labels2d      = ['\textbf{CEP50},\textbf{CEP80},\textbf{CEP90},\textbf{CEP95},\textbf{CEP99}'];
        collumnlabels = ['\textbf{Confidence Region},\textbf{Value (m)}'];        
        
        
    end


end