clc; close all;
datadir = './'; 
downloadCIFARData(datadir);

[XTrain,YTrain,XValidation,YValidation] = loadCIFARData(datadir);

% Create an augmentedImageDatastore object to use for network training
imageSize = [32 32 3];
pixelRange = [-4 4];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(imageSize,XTrain,YTrain, ...
    'DataAugmentation',imageAugmenter, ...
    'OutputSizeMode','randcrop');

% ResNet 
numUnits = 18;
netWidth = 16;
lgraph = residualCIFARlgraph(netWidth,numUnits,"standard");
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
% plot(lgraph)

% Training
miniBatchSize = 1024;
learnRate = 0.01;
valFrequency = floor(size(XTrain,4)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'InitialLearnRate',learnRate, ...
    'MaxEpochs',30, ...
    'MiniBatchSize',miniBatchSize, ...
    'VerboseFrequency',valFrequency, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',true, ...
    'ValidationData',{XValidation,YValidation}, ...
    'ValidationFrequency',valFrequency, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.7, ...
    'LearnRateDropPeriod',60);

trainedNet = trainNetwork(augimdsTrain,lgraph,options);

% Save the model
resnet_model = trainedNet;
save ('resnet_model.mat', 'resnet_model');