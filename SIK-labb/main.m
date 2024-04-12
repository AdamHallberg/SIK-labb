close all
clear
clc
%%  Read data
[xI,fsI] = audioread("matlab/xI.wav"); 
[xQ,fsQ] = audioread("matlab/xQ.wav"); 

%%  Sender sends data
x = sender(xI, xQ);

%%  Chanel transmitt data
%y = dummychannel(x, 2, 100e3);  
y = TSKS10channel(x);
%y = tmpChannel(x);
%disp("  >>  Chanel received data.")
%%  Receiver receve data
[zI,zQ,A,tau] = receiver(y);
disp("done.")
%% Compare results

%fs = fsI;                       % fsQ= fsI (always in our case)
disp("A   = " + A)
disp("Tau = " + tau)

%x0 = xI + xQ;
x0 = xI + xQ;
z  = zI + zQ;

last_zeros_I = length(zI)-length(xI);
last_zeros_Q = length(zQ)-length(xQ);
zI = zI(1:end-last_zeros_I);
zQ = zQ(1:end-last_zeros_Q);


SNRzI = 20*log10(norm(xI)/norm(zI-xI));
SNRzQ = 20*log10(norm(xQ)/norm(zQ-xQ));

disp("  >>  SNRzI = " + SNRzI)
disp("  >>  SNRzQ = " + SNRzQ)

%disp("  >>  SNRz = " + SNRz)
%plot(f,X)