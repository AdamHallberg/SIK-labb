close all
clear
clc

%%  Read data
[xI,fsI] = audioread("matlab/xI.wav"); 
[xQ,fsQ] = audioread("matlab/xQ.wav"); 

%%  Sender sends data
x = sender(xI, xQ);

%%  Chanel transmitt data
y = dummychannel(x, -2, 190e3, 10);  % 1711e3 ger krash
%y = TSKS10channel(x);
%y = tmpChannel(x);

%%  Receiver receve data
[zI,zQ,A,tau] = receiver(y);


%% Compare results

disp("---------------------------")
disp("  >>  Resultat:")
disp("  >>  A     = " + A)
disp("  >>  Tau   = " + tau)
disp("  >>  SNRzI = " + 20*log10(norm(xI)/norm(zI-xI)))
disp("  >>  SNRzQ = " + 20*log10(norm(xQ)/norm(zQ-xQ)))
disp("---------------------------")