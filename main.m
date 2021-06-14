% This test script loads 31 invivo B1+ datasets of the human body at 7T 
% and computes tailored and universal (22 B1+ datasets) kT-point pulses.
% This script also evaluates default shim setting, tailored pulses and 
% universal pulses using the CV in the 3D heart target region in 31 B1+ 
% datasets as described in:
%
% Christoph S. Aigner, Sebastian Dietrich, Tobias Schaeffter and Sebastian
% Schmitter, Calibration-free pTx of the human heart at 7T via 3D universal 
% pulses, submitted to Magn. Reson. Med. 2021
%
% The 31 channel-wise invivo B1+ datasets of the human body at 7T are 
% available at: 
% https://figshare.com/articles/dataset/31_channel-wise_invivo_B1_maps_of_the_human_body_at_7T/14778345
%
% The optimization of the kT-points is performed using code by Will Grissom
% and Zhipeng Cao (https://bitbucket.org/wgrissom/acptx/) who have given 
% permission for inclusion within this package. Please cite appropriately.
% 
% Created by Christoph S. Aigner, PTB, June 2021.
% Email: christoph.aigner@ptb.de
%
% This code is free under the terms of the GPL-3.0 license.

addpath ktutil   % add code by Will Grissom and Zhipeng Cao
pathDat = 'B1R'; % set the folder that contains the in vivo B1+ datasets

% parameters
% allIndices     ... all B1+ datasets (library + test-cases)
% libraryIndices ... datasets used in the optimization (library)
allIndices     = 1:31; % there are 31 B1+ datasets in total
libraryIndices = 1:22; % the paper used the first 22 B1+ datasets
allmaps        = cell(1, length(allIndices));     % pre-allocate the cell 
librarymaps    = cell(1, length(libraryIndices)); % pre-allocate the cell 
c_dat          = 1;     % initialize dataset counter
prbp.dt        = 10e-6; % dwell time in sec
prbp.Nsubpts   = 10;    % # of time points for RF subpulses 
prbp.nblippts  = 20;    % # of time points for gradient blips
prbp.delta_tip = 10;    % flip angle in degrees

%% load the B1R datasets and create the library and unseen test cases
loadB1R_OK = 0;
loadB1R;

if ~loadB1R_OK
	disp('The 31 channel-wise invivo B1+ datasets of the human body at 7T');
    disp('are available at:');
    disp('https://figshare.com/articles/dataset/31_channel-wise_invivo_B1_maps_of_the_human_body_at_7T/14778345');
    return;
end

%% default shim setting
pulseType   = 'default';
numkTpoints = 1; 
c_kTpoints  = 1;
wvfrms.k    = zeros(numkTpoints,3);
rfw         = ones(numkTpoints,Nc)*0.1;
evalAllDatasets;

%% tailored design
pulseType         = 'tailored';
numkTpoints       = 4;      % number of kT points; tested for 1:5
numPhaseInit      = 165;    % 1-200, #165 performed best for the library
lambdavec         = [4.64];  % result of the L curve optimization; 10^0-10^7
phsinitmode       = 'randphase'; % performed best
b_evalAllDatasets = true;   % evaluate the tailored pulse in allmaps
numTailored       = 1;      % just compute one tailored pulse

%do the tailored design and evaluate the tailored pulse in allmaps
designTailored; 

%% do the UP design
pulseType         = 'UP';
numkTpoints       = 4;        % number of kT points; tested for 1:5
numPhaseInit      = 165;      % 1-200, #165 performed best for the library
lambdavec         = [107.97]; % result of the L curve optimization; 10^0-10^7
phsinitmode       = 'randphase';
b_evalAllDatasets = true;   % evaluate the tailored pulse in allmaps

%do the UP design and evaluate the universal pulse in allmaps
designUP; 

%% prepare the UP
% modify timing of the RF pulse
prbp.Nsubpts  = 14; %optimized for 10
gradblipred   = 2;  %optimized for 20ms BE CAREFUL WITH THE SLEW RATE

%prepare and plot the UP 
preparekTpoints;

% brfvec and gvec can then be used to generate pulse files for the scanner


