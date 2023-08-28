%                       MCMFit.m
%-------------------------------------------------------
%
%           Dr. Joakim Munkhammar, PhD 2023
%
% This function fits the transition matrix to the MCM model
% given inputs in terms of:
%
% - Training data set (InData)
% - Number of states (N)
%

function [P] = MCMFit(InData,N)

% Pb, base probability in transition matrix
Pb=0.0000000001;

% NaN-warning on input data
if sum(isnan(InData)>0)
    disp('Input data contains NaN')
end

% Define the N bins
for i=1:N+1
    Bin(i) = ((i-1)/N)*(max(InData)-min(InData));
end

% Setting a State time-series
State=floor(N*InData/max(InData))+1; % Make State the discrete "state" time-series
State(State<1)=1; % Picking closest state when outside
State(State>N)=N; % Picking closest state when outside

% Determine the transition matrix
P=zeros(N,N);
for t=1:size(InData,2)-1 % Train the transition matrix P
    P(State(t),State(t+1)) = P(State(t),State(t+1))+1;
end

P=P+Pb*ones(N,N); % Adding the Pb base probability

% Normalizing the Markov-chain transition matrix
for i=1:N
    P(:,i) = P(:,i)/sum(P(:,i));
end


