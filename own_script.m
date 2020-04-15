startup;

%%% PARAMS %%%%
folder = fullfile('omat','VGA');
SRF = 4;
%%%%%%%%%%%%%%%

srf_dir = fullfile(folder, ['SRF' num2str(SRF)]);
d = dir(fullfile(srf_dir,'*LR.png'));

opt = sr_init_opt(SRF);
for i = [10,11,12]
    in_fname = d(i).name;
    out_fname = [in_fname(1:end-6) 'SR.png'];
    
    filePath = [];
    filePath.dataPath    = srf_dir;             % Path to images
    filePath.imgFileName = in_fname; 
    filePath.resLvlPath = fullfile(srf_dir,'lvl');
    
    imgSupRes = own_demo(filePath, opt, 1);
    imwrite(imgSupRes, fullfile(filePath.dataPath, out_fname));
    
end