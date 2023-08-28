%                           MCMForecastSample.m
%-----------------------------------------------------------------------------------
%
%                   Dr. Joakim Munkhammar, PhD 2023
%
% This function generates samples from the MCM predictive distribution with 
% settings:
%
% InData = Training data (used primarily for ECDF setting)
% ObsPoint = Observation point to forecast from
% TransMatrix = Transition matrix (typically set by MCMFit)
% NumSamples = Number samples from the predictive distribution
% EmissionDistribution = Emission distribution choice of either "ECDF" or "Uniform"
%

function [X] = MCMForecast(InData,ObsPoint,TransMatrix,NumSamples,EmissionDistribution)

% Failsafe if not having properly formatted type of distribution
% EmissionDistribution
if ~(strcmp(EmissionDistribution,'Uniform')||strcmp(EmissionDistribution,'ECDF'))
    disp('Warning, use setting Uniform or ECDF, ECDF is default')
    A = 'ECDF';
end

% Identifying N
N=size(TransMatrix,1);

% Set the bins
for i=1:N+1
    Bin(i) = ((i-1)/N)*(max(InData)-min(InData));
end

% Identifying the observation state of the observation point
ObsState = floor(N*ObsPoint/max(InData))+1;
% Failsafe for observations outside
if ObsState>N
    ObsState = N;
elseif ObsState<1
    ObsState = 1;
end

% Setting up ECDF samples for the ECDF forecasts 
if strcmp(EmissionDistribution,'ECDF')
    State=floor(N*InData/max(InData))+1; % Make State the discrete "state" time-series
    State(State<1)=1; % Picking closest state when outside
    State(State>N)=N; % Picking closest state when outside

    for i=1:N % The code for generating random ECDF samples
        if size(InData(find(State==i)),1)>1 % Failsafe for empty bins
            RandAll(i,:) = randsample(All(find(State==i)),NumSample,true);
        else % If bins are empty, then use regular N-state
            RandAll(i,:) = min(InData)+(max(InData)-min(InData))*rand(NumSamples,1);
        end
    end
end

% Setting the matrix Prow as CDF of transition matrix rows
for i=0:N
    for j=1:N
        if i==1
            Prow(i+1,j) = 0;
        else
            Prow(i+1,j) = sum(TransMatrix(1:i,j));
        end
    end
end

% Setting the uniform sampling for the MCM uniform
RandPart = (1/N)*(max(InData)-min(InData))*rand(NumSamples,1);

% Main routine for sampling from the predictive distribution
X = zeros(NumSamples,1); % Setting the sampling vector
for i=1:NumSamples
	r = rand(1);
    for j=1:N 
        if (r>Prow(j,ObsState))&&(r<=Prow(j+1,ObsState)) % Chk bin for observation
            if strcmp(EmissionDistribution,'ECDF') % Check which memission distribution
                X(i) = RandAll(j,i); % MCM ECDF
            else
                X(i) = Bin(j)+RandPart(i); % MCM Uniform
            end
        end
    end
end
