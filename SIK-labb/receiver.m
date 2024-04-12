function [zI,zQ,A,tau] = receiver(y)
%%  Constants
L  = length(y);                 % Antal punkter i indatan
fs = 400e3;                     % Samplingsfrekvens
T  = 1/fs;                      % Periodtid
T0 = 1/20000;
%%  Determine A and tau
%  Create known chirp
Length = 20*100000;
tc = T*[0:Length-1];

known_chirp = chirp(tc,140e3,Length,160e3)';  % samma som i sender

% chirp for leading zeros
known_chirp1 = [known_chirp;zeros(length(y)-length(known_chirp),1)];  

%  Get index for correlation for leading zeros
[~, i0] = max(abs(xcorr(known_chirp1)));            % Gives index for peak in known chirp 

[~, i1] = max(abs(xcorr(y, known_chirp1)));            % Gives index for peak in known chirp

added_samples = abs(i1-i0);
disp("  >>  Added zeros at start: " + added_samples)
tau = T*added_samples;

%%  Bestäm A
val = xcorr(y, known_chirp1);
sgn = sign(val(i1));
A   = norm(y(added_samples+1:added_samples+Length))/norm(known_chirp1);
A = A*sgn;

%%  Adjust in-signal
y = (1/A)*y(added_samples + Length + 1:end);

%%  Find trailing zeros
% chirp for ending zeros
known_chirp2 = [zeros(length(y)-length(known_chirp),1);known_chirp];  

%  Get index for correlation for leading zeros
[~, i0] = max(abs(xcorr(known_chirp2)));            % Gives index for peak in known chirp 

[~, i1] = max(abs(xcorr(y, known_chirp2)));            % Gives index for peak in known chirp

added_samples = abs(i1-i0);
disp("  >>  Added zeros at end:   " + added_samples)

%%  Adjust in-signal
%sze = size(y)                                % When crash = 9978
%result = length(y) -added_samples + Length;  % when crash = 2001711
y = y(1:end-(added_samples + Length));        % when crash = []

%%  De-modulate 
t  = T*[0:length(y)-1];                 % Tidsintervall det samplas över

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
L   = length(y)/M;                      % Nytt antal punkter
T2  = T/M;                      % Ny periodtid


% Uppsample signals
zI  = downsample(yI2,M);        % zI nedsamplad yI2
zQ  = downsample(yQ2,M);        % zQ nedsamplad yQ2
end