% Demo script for Data Integration Via Analysis of Subspaces (DIVAS)
% This script demonstrates the usage of the DIVAS methodology on a toy dataset.

% Clear workspace and close all figures
clear; close all;

% Set random seed for reproducibility
rng(566, 'twister');

% Load toy data (or create a simple example)
% Uncomment and modify the following line to load your data
% load('toyDataThreeWay.mat');

% For demonstration purposes, we'll create a simple synthetic dataset
% with three data blocks and some shared structure

% Parameters
n = 100;   % Number of samples
d1 = 50;   % Dimensions of first data block
d2 = 40;   % Dimensions of second data block
d3 = 30;   % Dimensions of third data block

% Create shared structure
shared_score = randn(n, 2);   % 2D shared structure
unique_score1 = randn(n, 1);  % 1D structure unique to block 1
unique_score2 = randn(n, 2);  % 2D structure unique to block 2
unique_score3 = randn(n, 1);  % 1D structure unique to block 3

% Create loading matrices
shared_load1 = randn(d1, 2);
shared_load2 = randn(d2, 2);
shared_load3 = randn(d3, 2);
unique_load1 = randn(d1, 1);
unique_load2 = randn(d2, 2);
unique_load3 = randn(d3, 1);

% Create data blocks with noise
noise_level = 0.5;
X1 = shared_score * shared_load1' + unique_score1 * unique_load1' + noise_level * randn(n, d1);
X2 = shared_score * shared_load2' + unique_score2 * unique_load2' + noise_level * randn(n, d2);
X3 = shared_score * shared_load3' + unique_score3 * unique_load3' + noise_level * randn(n, d3);

% Store data in a cell array
datablock = {X1, X2, X3};

% Set parameters for DIVAS
params = struct();
params.nSim = 300;   % Number of simulations
params.colCent = 1;  % Column centering flag

% Run DIVAS analysis
outstruct = DJIVEMainJP(datablock, params);

% Print estimated ranks
fprintf('Estimated ranks:\n');
disp(outstruct.estRank);

% Generate diagnostic plots with block names
dataname = {'Block 1', 'Block 2', 'Block 3'};
DJIVEAngleDiagnosticJP(datablock, dataname, outstruct, 566, 'Synthetic Data Demo');

% Save the diagnostic figures (optional)
% saveas(gcf, 'loadings_diagnostic.png');
% figure(2);
% saveas(gcf, 'scores_diagnostic.png');

% Display results
fprintf('\nAnalysis complete!\n');
fprintf('Number of shared dimensions found: %d\n', sum(outstruct.estRank.rank(1,:)));
fprintf('Number of dimensions unique to Block 1: %d\n', sum(outstruct.estRank.rank(5,:)));
fprintf('Number of dimensions unique to Block 2: %d\n', sum(outstruct.estRank.rank(6,:)));
fprintf('Number of dimensions unique to Block 3: %d\n', sum(outstruct.estRank.rank(7,:)));

% Generate a reconstruction using the identified joint structure
reconstructed = DJIVEReconstructMJ(datablock, outstruct.dimsdir);

% Calculate reconstruction accuracy
fprintf('\nReconstruction error (Frobenius norm):\n');
for i = 1:3
    err = norm(datablock{i} - reconstructed{i}, 'fro') / norm(datablock{i}, 'fro');
    fprintf('Block %d: %.6f\n', i, err);
end 