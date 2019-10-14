function [cut_off] = auto_corr(Data, SR, pad)
 
% Computes the autocorrelation algorithm according to
% Challis (1999) for each marker. Inputs include the data and the video
% sampling frequency. 
% Data = Input data to be filtered
% SR = Sampling Rate
% pad = 1 if padding is required, else pad = 0
% 
% Requires bw_filter function
% Adapted from T. Exell by LN - Jan 2016


N = size(Data,1);
step = 10; % number of steps per Hz
Auto = zeros(1,((SR/2)-5)/0.1);   % Preassign 'Auto' 
Data_filt = zeros(size(Data));  % Preassign 'Data_filt'    
cut_off = zeros(size(Data));   % Preassign 'cut_off'

for i=1:size(Data,2)
    j=1;
    % Run butterworth filter at incrimental steps of 0.1 Hz
    for cf = 0.1:0.1:(SR/2)-5
        Data_filt(:,j) = bw_filter(Data(:,i),SR,cf,pad);
        Data_r = Data_filt(:,j)-Data(:,i);
        % start auto corr 
        tempxcorr = xcorr(Data_r,'coeff'); 
        xcright = tempxcorr(N:2*N-1);    % Grab only the positive lags
        xcrightsquare = xcright.^2;            % Square Autocorr values
        Rss = (sum(xcrightsquare));           % Sum squared autocorr values
        Auto(j) = Rss;                    % Calculate criterion by squaring Auto corr value and adding
        j = j+1;
    end                                 % End cutoff freq loop
    [~,z] = min(Auto);    % find minimum of criterion Auto
    cut_off(i) = z/step;          % Output cutoff freq auto corr
end

end

