%                     MCMSampleExample.m
%-----------------------------------------------------------
%
%               Dr. Joakim Munkhammar, PhD 2023
%
% This program is used as an example to create a predictive 
% distribution from a value and generate a number of 
% samples from that.
%
% This program utilizes:
%
% - A training data set (here TrainData.txt)
% - Function MCMFit
% - Function MCMForecastSample
%

% Importing training data
InData = importdata('TrainData.txt');

% Setting number of states N
N=30;

% Training the MCM-model
TransMatrix = MCMFit(InData,N);

% Setting a random observation point in the data
ObsPoint = InData(1249);

% Setting the number of samples
NumSamples = 1000;

% Emission distribution (the choice is 'ECDF' or 'Uniform')
EmissionDistribution = 'Uniform';

% Generating 1000 data points from MCM ECDF
X = MCMForecastSample(InData,ObsPoint,TransMatrix,NumSamples,EmissionDistribution);

% Example histogram of forecast samples
figure(2)
histogram(X,20)
