% This function loads 31 in vivo B1+ datasets used in
% Christoph S. Aigner, Sebastian Dietrich, Tobias Schaeffter and Sebastian
% Schmitter, Calibration-free pTx of the human heart at 7T via 3D universal 
% pulses, submitted to Magn. Reson. Med. 2021
% The 31 channel-wise invivo B1+ datasets of the human body at 7T are 
% available at: 
% https://figshare.com/articles/dataset/31_channel-wise_invivo_B1_maps_of_the_human_body_at_7T/14778345
% 
% Created by Christoph S. Aigner, PTB, June 2021.
% Email: christoph.aigner@ptb.de

function [allmaps, librarymaps, B1Dim, Nc, fov, loadB1R_OK] = loadB1R(prbp)

c_dat = 1;

disp(['load ', num2str(length(prbp.allIndices)), ' invivo B1+ maps']);
for c_subj=1:length(prbp.allIndices) 
    %load the Matlab container for dataset #countsubj
    if ~isfile([prbp.pathDat '\lightB1R_' num2str(prbp.allIndices(c_subj)) '.mat'])
        disp('NO B1 MAPS FOUND!');
        return;
    end
    load([prbp.pathDat '\lightB1R_' num2str(prbp.allIndices(c_subj)) '.mat']);
    B1R = non_respiration_resolved_B1R;
    
    %rearrange the dimensions 
    B1ptemp.cxmap = permute(squeeze(B1R.B1Rp),[3 2 1 4]);
    B1ptemp.cxmap = B1ptemp.cxmap(end:-1:1,:,end:-1:1,:);

    %normalization wrt to the mean in the heart ROI
    sumabsB1 = sum(abs(B1ptemp.cxmap),4);
    meansumabsB1mask = mean(sumabsB1(B1R.kTpoints.maps.mask));
    maps.b1 = B1ptemp.cxmap/meansumabsB1mask;

    if c_subj == 1
        B1Dim = size(maps.b1);
        Nc = B1Dim(4); %number of transmit channels
        fov = B1R.kTpoints.maps.fov; %fov in cm
    else
        if B1Dim ~= size(maps.b1)
            disp(['loaded B1 map #',num2str(c_subj), ...
                  ' has a different size as B1 map #1 !!!']);
        end
    end

    %save the other parameters. So far, B0 maps are set to 0
    maps.b0      = maps.b1*0;
    maps.mask    = B1R.kTpoints.maps.mask;
    maps.fov     = B1R.kTpoints.maps.fov;
    maps.DatNum  = prbp.allIndices(c_subj);

    % add the data to a cell array containing all datasets
    allmaps{c_subj} = maps;

    % add the data to a cell array for the optimization (library)
    if ismember(prbp.allIndices(c_subj),prbp.libraryIndices)
        librarymaps{c_dat} = maps;
        c_dat = c_dat+1;
    end
    loadB1R_OK = 1;
end
end