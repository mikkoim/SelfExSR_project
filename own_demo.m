function imgSupRes = own_demo(filePath, opt, visualize)
% Simplified impementation of sr_demo by Jia-Bin Huang

% Implementation is simplified and helpful visualizations are added
% Mikko Impiö

% Based on:
%   Single Image Super-Resolution using Transformed Self-Exemplars
%   Jia-Bin Huang, Abhishek Singh, and Narendra Ahuja
%   IEEE Conference on Computer Vision and Pattern Recognition, CVPR 2015

%%%%%% 1. Read the image itself %%%%%%%%%%%%%
img = im2single(imread(fullfile(filePath.dataPath, filePath.imgFileName)));

if visualize
    figure;
    imshow(img)
    title('LR image')
end

%%%%% 2. Extract planes from the image %%%%%%%%%%%%%
modelPlane = sr_extract_plane(filePath.dataPath, filePath.imgFileName, opt);

if visualize
    figure;
    planes = modelPlane.postProb(:,:,1);
    subplot(1,2,1)
    imshow(imfuse(img,planes,'blend','Scaling','joint'));
    title('First plane probabilities on top of image')
    
    subplot(1,2,2)
    imshow(planes,[])
    title('Plane probabilities')
     
end

% 3. Create the high- and low-freq image pyramids and produce
% a plane pyramid for each pyramid level 

[imgPyrH, imgPyrL, scaleImgPyr] = sr_create_img_pyramid(img, opt);
modelPlane = sr_planar_structure_pyramid(scaleImgPyr, modelPlane, opt.topLevel);

if visualize
    
    %%% Pyramid visualization
    figure
    subplot(3,2,1)
    imshow(imgPyrH{opt.origResLvl},[])
    title('High frequency pyramid, original scale')
    
    subplot(3,2,2)
    imshow(imgPyrL{opt.origResLvl},[])
    title('Low frequency pyramid, original scale')
    
    subplot(3,2,3)
    imshow(imgPyrH{opt.origResLvl+1},[])
    title('High frequency pyramid, original scale - 1')
    
    subplot(3,2,4)
    imshow(imgPyrL{opt.origResLvl+1},[])
    title('Low frequency pyramid, original scale - 1')
    
    subplot(3,2,5)
    imshow(imgPyrH{opt.origResLvl+2},[])
    title('High frequency pyramid, original scale - 2')
    
    subplot(3,2,6)
    imshow(imgPyrL{opt.origResLvl+2},[])
    title('Low resolution pyramid, original scale - 2')

    
end
    
%%% 4. Patch-based synthesis %%%%%%

imgPyr = own_synthesis(imgPyrH, imgPyrL, scaleImgPyr, modelPlane, opt, 1);


%%% 5. Retrieve the correct scale from pyramid and return it %%%%%%%%

if(mod(opt.SRF,2) == 0 )
    lvlInd = opt.origResLvl - log(opt.SRF)/log(2)*opt.nLvlToRedRes;
else
    lvlInd = opt.origResLvl - log(opt.SRF)/log(3)*opt.nLvlToRedRes;
end

imgSupRes = imgPyr{uint8(lvlInd)};

end