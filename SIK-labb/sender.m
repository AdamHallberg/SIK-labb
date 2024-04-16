function [x] = sender(xI, xQ)
%% Define constants
L  = length(xI);                % Antal punkter i indatan
fs = 20e3;                      % Samplingsfrekvens
T  = 1/fs;                      % Periodtid 
M   = 20;                       % Uppsamplingsfaktor
L2  = L*M;                      % Nytt antal punkter
t2=(T/M)*[0:L2-1];              % Nytt tidsintervall

%% Uppsample
xI2=upsample(xI,M);             % x2I Uppsamplad xI
xQ2=upsample(xQ,M);             % x2Q Uppsamplad xQ

%% Filtrering
% Filterconstants
N  = 100;                       % Filtrets gradtal
f0 = 1/M;                       % Normerad frekvens

% Create filter
[b,a]=fir1(N,f0);               % Designa filter

% Filter and remove added zeros
yI2= filter(b,a,[xI2;zeros(N/2,1)]);
yI2= yI2(N/2+1:max(size(yI2))); 
yQ2= filter(b,a,[xQ2;zeros(N/2,1)]);
yQ2= yQ2(N/2+1:max(size(yQ2)));

%% Modulera
fc=150e3;                       % Bärfrekvensen
carrierI=cos(2*pi*fc*t2).';     % I carrier
carrierQ=-sin(2*pi*fc*t2).';    % Q carrier

zI=M*yI2.*carrierI;
zQ=M*yQ2.*carrierQ;

x = zI + zQ;                    %  I/Q modulation done

%%  Add known chirp to signal
known_chirp = chirp(t2,145e3,L2,155e3)';
x = [known_chirp; x];

%%  Bandpass filter to stay in desired bandwidth
% TODO
end