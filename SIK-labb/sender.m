function [x] = sender(xI, xQ)
%% Define constants
L  = length(xI);                % Antal punkter i indatan
fs = 20e3;                      % Samplingsfrekvens
T  = 1/fs;                      % Periodtid 

%% Uppsample
% Constants
M   = 20;                       % Uppsamplingsfaktor
L2  = L*M;                      % Nytt antal punkter
T2  = T/M;                      % Ny periodtid
t2=T2*[0:L2-1];                 % Nytt tidsintervall


% Uppsample signals
xI2=upsample(xI,M);             % x2I Uppsamplad xI
xQ2=upsample(xQ,M);             % x2Q Uppsamplad xQ

%% Filtrering
% Filterconstants
N  = 100;                       % Filtrets gradtal
f0 = 1/M;                       % Normerad frekvens

% Create filter
[b,a]=fir1(N,f0);               % Designa filter
                                % The fir1(N, f0) function creates a lowpass-filter and gives its
                                % parameters in vector b. N gives the order of the filter. The cutoff
                                % frequency is normalized, meaning it is specified in terms of the 
                                % Nyquist frequency (half the sampling frequency).

% Filter signals                
%yI = filter(b,a,xI2);           % Filtrera xI2
%yQ = filter(b,a,xQ2);           % Filtrera xQ2

yI2= filter(b,a,[xI2;zeros(N/2,1)]);
yI2= yI2(N/2+1:max(size(yI2))); % Remove first N/2 points since filter adds delay
yQ2= filter(b,a,[xQ2;zeros(N/2,1)]);
yQ2= yQ2(N/2+1:max(size(yQ2)));

%% Modulera
fc=150e3;                       % Bärfrekvensen
carrierI=cos(2*pi*fc*t2).';     % I carrier
carrierQ=-sin(2*pi*fc*t2).';    % Q carrier

zI=M*yI2.*carrierI;
zQ=M*yQ2.*carrierQ;

x = zI + zQ;                    %  I/Q modulation done
%%  Create chirp
known_chirp = chirp(t2,140e3,L2,160e3)';
%%  Add known chirp to signal
x = [known_chirp; x];
end