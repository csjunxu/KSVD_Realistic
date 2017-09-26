%KSVDDENOISEDEMO K-SVD denoising demonstration.
%  KSVDDENISEDEMO reads an image, adds random white noise and denoises it
%  using K-SVD denoising. The input and output PSNR are compared, and the
%  trained dictionary is displayed.
%
%  To run the demo, type KSVDDENISEDEMO from the Matlab prompt.
%
%  See also KSVDDEMO.
addpath('ompbox10');
pathstr = fileparts(which('ksvddenoisedemo'));

Original_image_dir  =    './images/';
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);


%% generate noisy image %%

for sigma = [30 50 75 100 20 40 10]
    PSNR = [];
    SSIM = [];
    for i = 1:im_num
        % Peppers image
        im = double(imread(fullfile(Original_image_dir,im_dir(i).name)));
        disp(' ');
        disp('Generating noisy image...');
        randn('seed',0);
        n = randn(size(im)) * sigma;
        imnoise = im + n;
        %% set parameters %%
        params.x = imnoise;
        params.blocksize = 8;
        params.dictsize = 256;
        params.sigma = sigma;
        params.maxval = 255;
        params.trainnum = 40000;
        params.iternum = 20;
        params.memusage = 'high';
        % denoise!
        disp('Performing K-SVD denoising...');
        tic
        [imout, dict] = ksvddenoise(params);
        toc
%         % show results %
%         dictimg = showdict(dict,[1 1]*params.blocksize,round(sqrt(params.dictsize)),round(sqrt(params.dictsize)),'lines','highcontrast');
%         figure; imshow(imresize(dictimg,2,'nearest'));
%         title('Trained dictionary');
%         
%         figure; imshow(im/params.maxval);
%         title('Original image');
%         
%         figure; imshow(imnoise/params.maxval);
%         title(sprintf('Noisy image, PSNR = %.2fdB', 20*log10(params.maxval * sqrt(numel(im)) / norm(im(:)-imnoise(:))) ));
%         
%         figure; imshow(imout/params.maxval);
%         title(sprintf('Denoised image, PSNR: %.2fdB', 20*log10(params.maxval * sqrt(numel(im)) / norm(im(:)-imout(:))) ));
        imname = sprintf('KSVD_nSig%d_%s',sigma,im_dir(i).name);
        imwrite(imout,imname);
        PSNR =  [PSNR csnr( imout, im, 0, 0 )];
        SSIM      =  [SSIM cal_ssim( imout, im, 0, 0 )];
    end
    mPSNR = mean(PSNR);
    mSSIM = mean(SSIM);
    name = sprintf('KSVD_nSig%d.mat',sigma);
    save(name,'mPSNR','PSNR','SSIM','mSSIM');
end
