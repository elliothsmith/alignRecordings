%% [20151120] align EPSD data for DQ

%% load blackrock data and downsample blackrock to 500
% first file
NS3_1 = openNSx('G:\Data\EMU\EPSD\20150923-114211\20150923-114211-001.ns3');
for ch = 1:size(NS3_1.Data,1)
    dsBRrecord_1(ch,:) = DownSampleLFP(double(NS3_1.Data(ch,:)),2e3,500);
end

% blackrock electrode labels.
BRlabels = {NS3_1.ElectrodesInfo.Label}

% second file
NS3_2 = openNSx('G:\Data\EMU\EPSD\20150923-114211\20150923-114211-002.ns3');
for ch = 1:size(NS3_2.Data,1)
    dsBRrecord_2(ch,:) = DownSampleLFP(double(NS3_2.Data(ch,:)),2e3,500);
end

% concatenating the blackrock data files. 
dsBRrecord = cat(2,dsBRrecord_1,dsBRrecord_2);
clear dsBRrecord_1 dsBRrecord_2 NS3_1 NS3_2


%% load xltek data
load('DQ_EPSD.mat')

% xltek electrode labels
XLlabels = hdr.label

% difference in size of two arrays
sampsDiff = size(record,2)-size(dsBRrecord,2);


%% trim the xltek to the blackrock length
% size(record) = [129     5952142]

% removing N samples from the end of the xltek record.
recordTrimmed = record(:,1:end-sampsDiff);

% throw error if the records aren't the same size.
if ~isequal(size(recordTrimmed,2),size(dsBRrecord,2))
    error('records are not the same length')
end


%% do lagged cross-correlation in order to determine offset among recordings. 
smoothFactor = 100;
duplicatedChannels_xltekIndices = [2:13 66:73];

% looping over shared channels. 
for cs = 1:size(dsBRrecord,1)
    
    % cross-correlation step
    [C,lags] = xcorr(smooth(recordTrimmed(duplicatedChannels_xltekIndices(cs),:),smoothFactor),smooth(dsBRrecord(cs,:),smoothFactor));
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % plotting Cross-Correlation series
    figure(cs)
    plot(lags,C)
    axis tight
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    % maximum of cross-correlation
    [Cmax,loc] = max(C);
    
    % maximum of cross-correlation in time (samples)
    maxLags(cs) = lags(loc);
    
end


%% Sanity Check: How different are the max lags over channels.
figure
histogram(maxLags,min(maxLags):5:max(maxLags))

maxLag = median(maxLags);


%% align xltek recording wtih blackrock.
XLrecordAligned = record(:,maxLag:maxLag+length(dsBRrecord));


for chz = 1:size(dsBRrecord,1)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% plotting aligned data.
figure(10*chz)
hold on
plot(smooth(dsBRrecord(chz,:),smoothFactor),'color',rgb('dimgray'));
plot(smooth(XLrecordAligned(duplicatedChannels_xltekIndices(chz),:),smoothFactor),'color',rgb('orange'));
axis tight
hold off
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
end


%% organizing pulse data so it's the same size as the aligned data. 

% loading the pulses. 
NS4_1 = openNSx('G:\Data\EMU\EPSD\20150923-114211\20150923-114211-001.ns4');
NS4_2 = openNSx('G:\Data\EMU\EPSD\20150923-114211\20150923-114211-002.ns4');

% concatenating the blackrock data files for pulses. 
pulses = cat(2,double(NS4_1.Data),double(NS4_2.Data));
decFactor = 1e4/500;

pulses = pulses(1:decFactor:size(XLrecordAligned,2));


%% Now pulses recorded on blackrock are aligned to xltek data.
