clear all
close all
 
fid = fopen('message_to_be_encoded.txt','r');
textInAscii = double(fgetl(fid)); % ascii values of characters.
fclose(fid);
 
[y,Fs] = audioread('source_music.wav'); % where Fs is the sampling frequency.
y = y(:, 1); % converts from stereo to mono
low_y = lowpass(y, 13000, Fs);
audioLength = length(low_y);
dt = 1/Fs;
 
N = length(textInAscii); % no. of characters.
% normalise values
for i = 1 : N
    textInAscii(i) = textInAscii(i) - 31; % 1st char (space) = index 1, this index corresponds to their frequency
end
 
startingFreq = 14000; % in Hertz
estimatedNoOfCharPerWord = 8;
maxNoOfChars = 100 * estimatedNoOfCharPerWord;
segmentLength = 1400; % self-declared.
dF = Fs/segmentLength;
 
segmentDuration = segmentLength * dt;
t = [0 : dt : segmentDuration - dt];
freqMultiplesOfDF = multiplesOfDF(16000, dF, 127 - 32 + 1);
 
result = [];
 
for i = 1 : N
    freq = freqMultiplesOfDF(textInAscii(i));
    cosWave = 0.01*cos(2*pi*freq*t); % tried 0.01
    result = [result cosWave];
end

startMarkerFreq = 16000 + (116 * dF); % high enough frequency that will not correspond to any ascii value (max = 95 (~), after normalising)
endMarkerFreq = 16000 + (126 * dF);
startMarker = 0.008*cos(2*pi*startMarkerFreq*t); % to mark the start of the embedded message, tried 0.008
endMarker = 0.008*cos(2*pi*endMarkerFreq*t); % to mark the start of the embedded message, tried 0.01

temp = [startMarker result endMarker];
 
pad = round((audioLength - length(temp)) / 2);
temp2 = [zeros(1, pad) temp];
temp2(numel(low_y)) = 0;
 
embedded = (1.2*low_y) + (temp2.');
sound(embedded, Fs);
audiowrite('text2audio1.wav', embedded, Fs); 