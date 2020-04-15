function NNF = own_pass(imgTrg, imgSrcPyr, NNF, modelPlane, numIterLvl, opt, visualize)
% Simplified version of the sr_pass script by Huang
% visualizations were fixed

% SR_PASS
%
% Nearest neighbor field estimation at the current level using the
% generalized PatchMatch algorithm
%
% Input:
%   - imgTrg:     target image
%   - imgSrcPyr:  source image pyramid
%   - NNF:        the current nearest neighbor field 
%   - modelPlane: planar structure model 
%   - numIterLvl: number of iterations at the current level
%   - opt:        parameters
% Output:
%   - NNF:        updated nearest neighbor field
% =========================================================================

% =========================================================================
% Compute the initial patch cost at the current level
% =========================================================================
% Prepare target patch
trgPatch = sr_prep_target_patch(imgTrg, opt.pSize);

% Prepare source patch
[srcPatch, srcPatchScale] = sr_prep_source_patch(imgSrcPyr, NNF.uvTformH.data, opt);
% Compute patch matching cost: appearance cost
[NNF.uvCost.data, NNF.uvBias.data] = sr_patch_cost_app(trgPatch, srcPatch, opt);
% Compute patch matching cost: scale cost       
if(opt.useScaleCost)
    costScale = opt.lambdaScale*max(0, opt.scaleThres - srcPatchScale);
    NNF.uvCost.data = NNF.uvCost.data + costScale;
end
% Compute patch matching cost: plane compatibility cost
if(opt.usePlaneGuide)
    costPlane = sr_patch_cost_plane(modelPlane.mLogLPlaneProb, NNF.uvPlaneID.data, NNF.uvPix.ind, NNF.uvTformH.data(:,7:8));
    NNF.uvCost.data = NNF.uvCost.data + opt.lambdaPlane*costPlane;
end

% Update cost map
NNF.uvCost.map = sr_update_uvMap(NNF.uvCost.map, NNF.uvCost.data, NNF.uvPix.ind);

% =========================================================================
% Update the nearest neighbor field using PatchMatch 
% =========================================================================

for iter = 1 : numIterLvl
    [NNF, nUpdate] = sr_update_NNF(trgPatch, imgSrcPyr, NNF, modelPlane, opt);
    avgPatchCost = mean(NNF.uvCost.data);
    
    fprintf('    %3d\t%12d\t%12d\t%14f\n', iter, nUpdate(1), nUpdate(2), avgPatchCost);
      
    if(visualize)
        NNFVis = sr_vis_nnf(NNF, imgSrcPyr, opt);
             
        fig = figure;
        subplot(2,3,1)
        imshow(NNFVis.uvTfomMapVis,[])
        title('uvTfomMapVis')
        subplot(2,3,2)
        imshow(NNFVis.uvPosMap,[])
        title('uvPosMap')
        subplot(2,3,3)
        imshow(NNFVis.uvTformScaleVis,[])
        title('uvTformScaleVis')
        subplot(2,3,4)
        imshow(NNFVis.uvCostMapVis,[])
        title('uvCostMapVis')
        subplot(2,3,5)
        imshow(NNFVis.uvBiasMapVis,[])
        title('uvBiasMapVis')
        subplot(2,3,6)
        imshow(NNFVis.uvPlaneIDMapVis,[])
        title('uvPlaneIDMapVis')

%         saveas(fig, ['iter_', num2str(iter),'_vis.png']);
        
        
       
    end
end

end