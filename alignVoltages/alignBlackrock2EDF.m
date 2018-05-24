function [reAlignedData] = alignBlackrock2EDF(blackrockFileNames,EDFFileNnames)
% ALIGNBLACKROCK2EDF will load in and align data from blackrock files and
%   European Data Format files.
%
%   The first input is one or more blackrock (.nsx) file names
%   The second input is one or more .edf file names. 
%
%   dependencies:
%       - openNSx.m from NPMK [https://github.com/BlackrockMicrosystems/NPMK]
%       - edfread.m [https://www.mathworks.com/matlabcentral/answers/uploaded_files/23639/edfread.m]
%
%   If multiple files are being aligned, input file names in a cell array.
%
%   will down-sample the signals with higher smapling rates to match the
%   signals with lower sampling rates.
%


%% load xltek data
fprintf('loading xltek data...\n')
if iscell(EDFFileNames)
    xData = [];
    for fl = 1:length(EDFFileNames)
        [hdr,record] = edfread(EDFFileNames{fl});
        % cat data
        xData = cat(xData,2,record);
    end
    Fs_x = mode(hdr.samples);
else
    [hdr,xData] = edfread(EDFFileNames);
    Fs_x = mode(hdr.samples);
end


%% loading blakcrock data.
fprintf('loading blackrock data...\n')
if iscell(blackrockFileNames)
    % getting some deets
    report = openNSx(blackrockFileNames{1},'report');
    Fs_b = report.MetaTags.samplingFreq;
    % loading files.  
    brData = [];
    for fl = 1:length(blackrockFileNames)
        NS = openNSx('G:\Data\EMU\EPSD\20150923-114211\20150923-114211-001.ns3');
        tmp = resample(double(NS.Data),Fs_x,Fs_b);
        brData = cat(2,brData,tmp);
    end
else
    % getting some deets.
    NS = openNSx(blackrockFileNames);
    Fs_b = NS.MetaTags.samplingFreq;
    % in case there is a pause in the file. 
    if iscell(NS.Data)
        brData = resample(double(NS.Data{2}),Fs_x,Fs_b);
    else
        brData = resample(double(NS.Data),Fs_x,Fs_b);
    end
end

% TODO:: compare channel names and make sure that the 

%% Now aligning data using alignSignals.
% first check that there are the same numbers of channels in each matrix. 
if ~isequal(size(xData,1),size(brData,1))
    fprintf('oops. number of channels do not accord between the two matrices.\n')
    % TODO:: show the user the electrode labels and ask them to pick which
    % channels they would like to retain from both files. 
else
    nChans = size(brData,1);
    for ch = 1:nChans
        [offset(ch),leadingSignal(ch),inverted(ch)] = findOffset(xData(ch,:),brData(ch,:));
    end
end

fprintf('the median offset is %s samples.\n',median(offset));
offset = mode(offset);

% TODO:: make a function called align signals in which the signals are
% trimmed and aligned based off of the output of findOffset. I may need
% osome data for this task...

%TODO:: figure out how ot align these signals...
alignedData = 

