function [offset,leadingSignal,inverted] = findOffset(X1,X2)
% FINDOFFSET finds the offset between two signals
%
%   - signals do not need to be the same length, but if they aren't, the
%       shorter signal will be padded with zeros.
%   - signals should be the same sampling rate.
%
%   This fucntion tests whether the two signals are more correlated if one
%       is inverted. The second output argument is a boolean inidcating
%       whether inversion yielded a greater peak cross-correlation.
%


% how much to smooth the data. 50 - 100 is reasonable, but TODO:: add
% some more options to make this function super general without
% impacting fucntionality.
smoothFactor = 50;

% doing cross correlation on the two signals. This is where the signals
% are smoothed and the shorter signal is padded
[C,lags] = xcorr(smooth(X1,smoothFactor),smooth(X2,smoothFactor));
% cross correlating for inverteed signals too.
[Cinv,lagsinv] = xcorr(-1*smooth(X1,smoothFactor),smooth(X2,smoothFactor));

% finding the maximum value of the cross correlation.
[Cmax,loc] = max(C);
[Cmaxinv, locinv] = max(Cinv);

if lt(Cmax,Cmaxinv)
    offset = lagsinv(locinv);
    inverted = true; 
else
    offset = lags(loc);
    inverted = false;
end

if gt(offset,0)
    leadingSignal = 1;
elseif lt(offset,0)
    leadingSignal = 2;
elseif isequal(offset,0)
    display('whoa!!! Your signals are already synchronized.')
end


end