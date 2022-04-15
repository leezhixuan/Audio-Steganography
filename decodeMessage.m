function result = decodeMessage(embedded)
    segmentLength = 1400; % as per encoding
    dF = 44100 / segmentLength;
    iterations = length(embedded) / segmentLength;
    
    result = "";

    for i = 1 : iterations
        process = embedded(1 + ((i - 1) * segmentLength) : i * segmentLength);
        division = fix(length(process) / 20); % round to the nearest integer toward 0.
        chunk = process(1 + (7*division) : 15*division); % take the central portion of the signal (in time) for fft().
        fft_process = fft(chunk, 1400);

        mx = max(abs(fft_process));
        index = find(abs(fft_process) == mx);
        freq = index(1) * dF;
        
        if (freq > 19950) % end marker met, stop decoding.
            break
        else
            asciiValue = (freq - 16000) / dF;
            if (1 < asciiValue) && (asciiValue < 95)
                result = result + char(asciiValue + 30); % add 30 to convert back to unnormalised ascii value.
            end
        end
    end
end