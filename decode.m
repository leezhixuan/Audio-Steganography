clear all
close all
 
% [y,Fs] = audioread('text2audio3.wav'); % where Fs is the sampling frequency
% y = y(:, 1); % converts from stereo to mono

Fs = 44100;  % sampling frequency
recObj = audiorecorder(Fs, 16, 1); % 16-bit, 1 channel

disp('Start recording...');
recordblocking(recObj, 30);
disp('End of Recording.');
y = getaudiodata(recObj);

% spectrogram(y, 1400); % for analysis

high_y = highpass(y, 14200, Fs); 

 
sampleLength = length(high_y);
segmentLength = 1400; % as per encoding
dF = Fs/segmentLength;
 
message = "";
noOfIterations = fix((sampleLength - segmentLength) / segmentLength);

left = 1;
right = segmentLength;
 
for i = 1 : noOfIterations
    process = high_y(left : right);
    fft_process = fft(process, segmentLength);
    mx = max(abs(fft_process));
    index = find(abs(fft(process, segmentLength)) == mx);
    
    left = left + 1400; % slide left pointer
    right = right + 1400; % slide right pointer
    if isempty(index)
        continue
    else
        freq = index(1) * dF;
        if (freq > 19600) % start decoding
            embedded = high_y(left : sampleLength);
            message = decodeMessage(embedded);
            break
        end
    end
end

disp(message);
% length(char(message))
