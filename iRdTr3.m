%% Inverse Radon Transform version 3
clc,clear;
%% initial settings

load('./RdTr_results/RdTr_physical.mat');

nrays = size(R,1);
nviews = size(R,2);
L = 300; % length of x-ray sensor (mm)
interval_size = L/nrays; % interval size between rays

views = linspace(0,180-180/nviews,nviews)/180*pi;

% set the width of fft
width = 2^(nextpow2(nrays)+1);

%% Fourier tranform and filter

%fft
R_fft = fft(R, width);

% Ram-lak filter
filter = triang(width);

R_fft_filtered = bsxfun(@times, R_fft, filter);

%% inverse Fourier tranform and back project

% inverse Fourier transform
proj_ifft = ifft(R_fft_filtered,'symmetric');

% back project
fbp = zeros(nrays); % 假设初值为0
for i = 1:nviews
    rad = views(i);%弧度， %这个rad 是投影角，不是投影线与x轴夹角，他们之间相差 pi/2
    for x = 1:nrays
        for y = 1:nrays
            %{
            %最近邻插值法
            t = round((x-M/2)*cos(rad)-(y-M/2)*sin(rad));%将每个元素舍X入到最接近的整数。
            if t<size(R,1)/2 && t>-size(R,1)/2
                fbp(x,y)=fbp(x,y)+proj_ifft(round(t+size(R,1)/2),i);
            end
            %}
            t_temp = (x-nrays/2) * cos(rad) - (y-nrays/2) * sin(rad)+nrays/2  ;
             %最近邻插值法
            t = round(t_temp) ;
            if t>0 && t<=nrays
                fbp(x,y)=fbp(x,y)+proj_ifft(t,i);
            end
        end
    end
end
fbp = (fbp*pi)/180;%512x512 原图像每个像素位置的密度

%% 显示结果

figure,imshow(fbp',[]),title('反投影变换后的图像')