%--------------------------------------------------------------------------
clear;
%KSVDDENOISEDEMO K-SVD denoising demonstration.
%  KSVDDENISEDEMO reads an image, adds random white noise and denoises it
%  using K-SVD denoising. The input and output PSNR are compared, and the
%  trained dictionary is displayed.
%
%  To run the demo, type KSVDDENISEDEMO from the Matlab prompt.
%
%  See also KSVDDEMO.
addpath('ompbox10');
addpath('NoiseEstimation');
pathstr = fileparts(which('ksvddenoisedemo'));

% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.JPG');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.JPG');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.png');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% GT_fpath = fullfile(GT_Original_image_dir, '*mean.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% TT_fpath = fullfile(TT_Original_image_dir, '*real.png');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\our_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.JPG');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\our_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.JPG');
GT_Original_image_dir = 'C:/Users/csjunxu/Desktop/RID_Dataset/RealisticImage/';
GT_fpath = fullfile(GT_Original_image_dir, '*mean.JPG');
TT_Original_image_dir = 'C:/Users/csjunxu/Desktop/RID_Dataset/RealisticImage/';
TT_fpath = fullfile(TT_Original_image_dir, '*real.JPG');

GT_im_dir  = dir(GT_fpath);
TT_im_dir  = dir(TT_fpath);
im_num = length(TT_im_dir);

method = 'KSVD';
write_MAT_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/PolyU_Results/'];
write_sRGB_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/PolyU_Results/' method];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end
PSNR = [];
SSIM = [];
RunTime = [];
for i = 1 : im_num
    IM =   double(imread( fullfile(TT_Original_image_dir,TT_im_dir(i).name) ));
    IM_GT = double(imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)));
    fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', csnr(uint8(IM), uint8(IM_GT), 0, 0 ), cal_ssim(uint8(IM), uint8(IM_GT), 0, 0 ));
    % S = regexp(TT_im_dir(i).name, '\.', 'split');
    IMname = TT_im_dir(i).name(1:end-9);
    [h,w,ch] = size(IM);
    params.blocksize = 8;
    params.dictsize = 256;
    params.maxval = 255;
    params.trainnum = 40000;
    params.iternum = 20;
    time0 = clock;
    IMout = zeros(size(IM));
    for cc = 1:ch
        %% set parameters %%
        params.x = IM(:,:,cc);
        params.sigma = NoiseEstimation(IM(:, :, cc), 8);
        params.memusage = 'high';
        %% denoising
        [IMoutcc, dict] = ksvddenoise(params);
        IMout(:,:,cc) = IMoutcc;
    end
    RunTime = [RunTime etime(clock,time0)];
    fprintf('Total elapsed time = %f s\n', (etime(clock,time0)) );
    PSNR = [PSNR csnr( uint8(IMout), uint8(IM_GT), 0, 0 )];
    SSIM = [SSIM cal_ssim( uint8(IMout), uint8(IM_GT), 0, 0 )];
    fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
    imwrite(IMout/255, [write_sRGB_dir '/' method '_our_' IMname '.png']);
end
mPSNR = mean(PSNR);
mSSIM = mean(SSIM);
mRunTime = mean(RunTime);
matname = sprintf([write_MAT_dir method '_our.mat']);
save(matname,'PSNR','mPSNR','SSIM','mSSIM','RunTime','mRunTime');