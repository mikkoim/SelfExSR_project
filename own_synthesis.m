function imgPyrH =  own_synthesis(imgPyrH, imgPyrL, scalePyr, modelPlane, opt, visualize)
% Simplified version of the original script by Huang
% Mikko Impiö
%
% SR_SYNTHESIS:
%
% Patch-based synthesis using the PatchMatch algorithm and planar structural guidance
%
% Input:
%   - imgPyrH:    high-freq band image pyramid
%   - imgPyrL:    low-freq band image pyramid
%   - scalePyr:   pyramid scale information
%   - modelPlane: planar model
%   - filePath:   pathes and file names
%   - opt:        parameters
% Output:
%   - imgPyrH:    reconstructed high-freq image pyramid
% =========================================================================

%
pyrLvl = opt.origResLvl-1: -1 : opt.topLevel; % Starting from the original resolution to the desired resolution
numIterLvl = opt.numIter;                     % Initial iteration number
NNF = [];                                     % Initialize NNF

% =========================================================================
% Coarse-to-fine image super-resolution
% =========================================================================

for iLvl = pyrLvl
    % plane parameters for the current level
    modelPlaneCur = modelPlane{iLvl};
    
    % Image size at the current image level
    imgSizeCur    = scalePyr{iLvl}.imgSize;
    
    opt.iLvl = iLvl;
    
    % Prepare NNF for the current level
    fprintf('--- Initialize NNF at level %d\n', iLvl);
    NNF = sr_init_lvl_nnf(imgSizeCur, NNF, modelPlaneCur, opt);
    
    % Number of iterations at the current level
    numIterLvl = max(numIterLvl - opt.numIterDec, opt.numIterMin);
    
    fprintf('--- Pass... level: %d, #Iter: %d, #uvPixels: %7d\n', iLvl, numIterLvl, NNF.uvPix.numUvPix);
    fprintf('--- %3s\t%12s\t%12s\t%10s\n', 'iter', '#PropUpdate', '#RandUpdate', 'AvgCost');

    % Estimate nearest neighbor field
    % Use the low-freq band image as the target image
    imgTrg = imresize(imgPyrH{iLvl+1}, scalePyr{iLvl}.imgSize, opt.resampleKernel);
    NNF    = own_pass(imgTrg, imgPyrL, NNF, modelPlaneCur, numIterLvl, opt, visualize);
    
    % Image reconstruction via weighted voting (using the high-freq band image pyramid)
    imgPyrH{iLvl} = sr_voting(imgPyrH, NNF, opt);
    
    % Low-pass filtering
    imgPyrL{iLvl} = imresize(imgPyrH{iLvl}, scalePyr{iLvl+1}.imgSize, opt.resampleKernel);
    imgPyrL{iLvl} = imresize(imgPyrL{iLvl}, scalePyr{iLvl}.imgSize,   opt.resampleKernel);
  
end

% Patch-based reconstruction
imgPyrH{opt.topLevel} = sr_voting(imgPyrH, NNF, opt);

end