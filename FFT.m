
close all
clear all
clc

X = im2gray(imread('Pic.jpg'));
imagesc(X)
figure
Y = fft2(X);
imagesc(abs(fftshift(Y)));
figure,

Y(1513:end, 2016:end) = 0;
X2 = ifft2(Y);
imagesc(X2);
