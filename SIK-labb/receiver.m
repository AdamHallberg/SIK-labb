function [zI,zQ,A,tau] = receiver(y)
%%  Constants
L  = length(y);                 % Antal punkter i indatan
fs = 400e3;                     % Samplingsfrekvens
T  = 1/fs;                      % Periodtid 
t  = T*[0:L-1];                 % Tidsintervall det samplas över
%%  De-modulate 
fc = 150e3;                       % Bärfrekvensen
carrierI = 2*cos(2*pi*fc*t).';    % I carrier
carrierQ = -2*sin(2*pi*fc*t).';   % Q carrier

yI = y.*carrierI;
yQ = y.*carrierQ;

%%  Low-pass-filter
N  = 100;                       % Filtrets gradtal
f0 = 1/20;                      % Normerad frekvens

% Create filter
[b,a]=fir1(N,f0);               % Designa filter

% Handle time delay
yI2 = filter(b,a,[yI;zeros(N/2,1)]);
yQ2 = filter(b,a,[yQ;zeros(N/2,1)]);

yI2 = yI2(N/2+1:end);           % Remove first N/2 points since filter adds delay
yQ2 = yQ2(N/2+1:end);

%% Down-sample
% Constants
M   = 20;                       % Nedsamplingsfaktor
L   = L*M;                      % Nytt antal punkter
T2  = T/M;                      % Ny periodtid


% Uppsample signals
zI  = downsample(yI2,M);        % zI nedsamplad yI2
zQ  = downsample(yQ2,M);        % zQ nedsamplad yQ2

%%  Determine A and tau...
A   = 1;
tau = 1;
end