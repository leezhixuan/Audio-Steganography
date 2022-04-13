function result = decodeMessage(embedded)
    segmentLength = 1400; % tried: 1400, 2100
    dF = 44100 / segmentLength;
    iterations = length(embedded) / segmentLength;
    
    result = "";
    
%     disp('hello');
    for i = 1 : iterations
        process = embedded(i + ((i - 1) * segmentLength) : i * segmentLength);
        fft_process = fft(process, segmentLength);
        mx = max(abs(fft_process));
        index = find(abs(fft_process) == mx);
        freq = index(1) * dF;
        if (freq > 19950) % end decoding
            break
        else
            asciiValue = fix((freq - 16000) / dF);
            if (1 < asciiValue) && (asciiValue < 95)
                result = result + char(asciiValue + 30); % 30 is experimental
            end
        end
    end
end