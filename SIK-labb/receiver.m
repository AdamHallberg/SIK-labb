function [zI,zQ,A,tau] = receiver(y)
%%  Determine A and tau
fs = 400e3;                     % Samplingsfrekvens
T  = 1/fs;                      % Periodtid
Length = 20*100000;
tc = T*[0:Length-1];

known_chirp = chirp(tc,145e3, ...
    Length,155e3)';             % samma som i sender

[~, i1] = max(abs(xcorr(y, ...
    known_chirp, 'none')));     % Gives index for peak in known chirp

added_samples = abs(i1-length(y));
tau = T*added_samples;

%%  Bestäm A
val = xcorr(y, known_chirp);
sgn = sign(val(i1));
A   = sgn*norm(y(added_samples+1:added_samples+Length))/norm(known_chirp);

%%  Adjust in-signal
y = (1/A)*y(added_samples + Length + 1:2*Length + added_samples);

%%  De-modulate 
t  = T*[0:length(y)-1];         % Tidsintervall det samplas över

fc = 150e3;                     % Bärfrekvensen
carrierI = 2*cos(2*pi*fc*t).';  % I carrier
carrierQ = -2*sin(2*pi*fc*t).'; % Q carrier

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

yI2 = yI2(N/2+1:end);           % Remove first N/2 points
yQ2 = yQ2(N/2+1:end);           % since filter adds delay

%% Down-sample
% Constants
M   = 20;                       % Nedsamplingsfaktor

zI  = downsample(yI2,M);        % zI nedsamplad yI2
zQ  = downsample(yQ2,M);        % zQ nedsamplad yQ2
end