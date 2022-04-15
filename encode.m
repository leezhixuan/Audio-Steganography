clear all
close all
 
fid = fopen('message_to_be_encoded.txt','r');
textInAscii = double(fgetl(fid)); % ascii values of characters.
fclose(fid);
 
[y,Fs] = audioread('source_music.wav'); % where Fs is the sampling frequency.
y = y(:, 1); % converts from stereo to mono
low_y = lowpass(y, 13000, Fs);
audioLength = length(low_y);
 
N = length(textInAscii); % no. of characters.
% normalise values
for i = 1 : N
    textInAscii(i) = textInAscii(i) - 31; % 1st char (space) = index 1, this index corresponds to their frequency
end
 
startingFreq = 16000; % in Hertz
segmentLength = 1400; % self-declared.
dF = Fs/segmentLength;
fundamentalPeriod = 1 / dF;
dt = fundamentalPeriod / segmentLength;

t = [0 : dt : fundamentalPeriod - dt];
freqMultiplesOfDF = multiplesOfDF(startingFreq, dF, 127 - 32 + 1);
 
result = [];
 
for i = 1 : N
    freq = freqMultiplesOfDF(textInAscii(i));
    cosWave = 0.012*cos(2*pi*freq*t); % 0.012 so that it isn't obvious to the ear.
    result = [result cosWave];
end

startMarkerFreq = startingFreq + (116 * dF); % high enough frequency that will not correspond to any ascii value (max = 95 (~), after normalising)
endMarkerFreq = startingFreq + (126 * dF); % higher than startMarker Freq to distinguish itself in case sliding window is wonky.
startMarker = 0.01*cos(2*pi*startMarkerFreq*t); % to mark the start of the embedded message, 0.01 so that it is softer than cosine waves a
endMarker = 0.01*cos(2*pi*endMarkerFreq*t); % to mark the start of the embedded message.

temp = [startMarker result endMarker];
 
pad = round((audioLength - length(temp)) / 2);
temp2 = [zeros(1, pad) temp]; % pads 0s at the front.
temp2(numel(low_y)) = 0; % pad 0s at the end
 
embedded = (1.2*low_y) + (temp2.'); % amplify audio mask to conceal inserted sound.
audiowrite('text2audio3.wav', embedded, Fs); 