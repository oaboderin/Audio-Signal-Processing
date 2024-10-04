clear, clc, close all;
[y,Fs] = audioread('mozarts_corrupted.wav');
N = length(y);          % Length of vector y, number of samples
Y = fft(y,N);           % Fourier transform of y
F = (0:N-1)*(Fs/N);     % Frequency vector
Y1 = Y(:,1);            %Analyzing the columns of Y separately
Y2 = Y(:,2);

figure(1);
plot(F, abs(Y));
title('Corrupted Sound Frequency Domain')
xlabel('Frequency(HZ)');
ylabel('dB');

figure(2)
plot(y);
title('Corrupted Sound Time Domain')
xlabel('time(s)');


%first column
    max_y = max(Y1);
    Index1 = find(Y==max_y);
    
%second column
    max_y = max(Y2);
    Index = find(Y==max_y);
    Index2 = minus(Index,length(Y1));    %Avoiding error from indexing
   
%Notch Filter for First Column
fs = Fs;                %sampling rate
f0 = F(Index1);         %notch frequency
fn = fs/2;              
freqratio = f0/fn;      %ratio of notch frequency to nyquist frequency

notchwidth = 0.1;       

% Computing zeros
notchzeroes = [exp( sqrt(-1)*pi*freqratio ), exp( -sqrt(-1)*pi*freqratio )];

% Computing poles
notchpoles = (1-notchwidth) * notchzeroes;

figure(3);
zplane(notchzeroes.', notchpoles.');

b = poly(notchzeroes);     %filter coefficients
a = poly(notchpoles);      %filter coefficients

figure(4);
freqz(b,a,fs)

%Notch Filter for Second Column
fs = Fs;                
f02 = F(Index2);        
fn = fs/2;              
freqratio2 = f02/fn;    

notchwidth = 0.1;       

notchzeroes2 = [exp( sqrt(-1)*pi*freqratio2 ), exp( -sqrt(-1)*pi*freqratio2 )];

notchpoles2 = (1-notchwidth) * notchzeroes2;

figure(5);
zplane(notchzeroes2.', notchpoles2.');

b2 = poly(notchzeroes2); 
a2 = poly(notchpoles2); 

figure(6);
freqz(b2,a2,fs)

% filter signal 
B = [b b2];
A = [a a2];

R = filter(B,A,y);

figure(7)
plot(R);
title('Restored Sound Time Domain')
xlabel('time(s)');


C = length(R);
L = fft(R,C);

figure(8)
plot(F,abs(L));
title('Restored Sound Frequency Domain')
xlabel('Frequency(HZ)');
ylabel('dB');



fprintf('Playing the Corrupted Sound File...\n');
sound(y, Fs);
pause(60);
fprintf('Playing the Restored Sound File...\n');
sound(R, Fs);
audiowrite('mozarts_restored.wav',R,Fs);