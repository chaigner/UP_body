% This function computes universal kT-point pulses as described in
% Christoph S. Aigner, Sebastian Dietrich, Tobias Schaeffter and Sebastian
% Schmitter, Calibration-free pTx of the human heart at 7T via 3D universal 
% pulses, submitted to Magn. Reson. Med. 2021
%
% The optimization of the kT-points is performed using code by Zhipeng Cao 
% and Will Grissom (https://bitbucket.org/wgrissom/acptx/) who have given 
% permission for inclusion within this package. Please cite appropriately.
% 
% Created by Christoph S. Aigner, PTB, June 2021.
% Email: christoph.aigner@ptb.de

function [wvfrms, designUP_OK] = designUP(pulseType, numkTpoints, numPhaseInit, lambdavec, phsinitmode, b_evalAllDatasets, numTailored, prbp) 

B1Dim = prbp.B1Dim;
Nc = prbp.Nc;
fov = prbp.fov;
librarymaps = prbp.librarymaps;

load('kTrandphases.mat');
for c_kTpoints = numkTpoints
    for c_diffrand = numPhaseInit
        for c_lambdaexp=1:length(lambdavec)
            disp(['design ',pulseType,num2str(length(prbp.libraryIndices)),'-',num2str(c_kTpoints),'kT, phaseinit=',num2str(c_diffrand), ', regularization=',num2str(lambdavec(c_lambdaexp))]);
 
            Nm = length(librarymaps); %number of B1+datasets in the library
            
            % initialize maps (to be sure to have the right size)
            maps.numberofmaps = Nm;
            maps.b1   = zeros(B1Dim(1),B1Dim(2),B1Dim(3)*Nm,Nc);
            maps.mask = zeros(B1Dim(2),B1Dim(2),B1Dim(3)*Nm);
            maps.b0   = zeros(B1Dim(2),B1Dim(2),B1Dim(3)*Nm);
            maps.fov = fov;

            % get the maps from allmaps
            for c_dat=1:Nm
                maps.b1(:,:,(1:B1Dim(3))+(c_dat-1)*B1Dim(3),:) = librarymaps{c_dat}.b1;
                maps.mask(:,:,(1:B1Dim(3))+(c_dat-1)*B1Dim(3)) = librarymaps{c_dat}.mask;
                maps.b0(:,:,(1:B1Dim(3))+(c_dat-1)*B1Dim(3))   = librarymaps{c_dat}.mask*0;
            end

            maps.mask = logical(maps.mask);

             % set initial target phase to zero or default phase mode 
            switch phsinitmode
                case 'zerophase'
                    disp('zero phase initial')
                    maps.phsinit = zeros(size(maps.mask)); 
                case 'defaultphase'
                    disp('default phase initial')
                    maps.phsinit = angle(sum(maps.b1,4));%default phase 
                case 'quadmode' %quad mode does not perform in the body
                    bcb1 = 0;
                    for ii = 1:Nc
                       bcb1 = bcb1 + maps.b1(:,:,:,ii)*...
                                     exp(1i*(ii-1)*2*pi/Nc).*...
                                     exp(-1i*angle(maps.b1(:,:,:,1)));
                    end
                    maps.phsinit = angle(bcb1);
                case 'randphase'
                    bcb1 = 0;
                    for ii = 1:Nc
                        bcb1 = bcb1 + maps.b1(:,:,:,ii)*...
                                     exp(1i*randphases(c_diffrand,ii)).*...
                                     exp(-1i*angle(maps.b1(:,:,:,1)));
                    end
                    maps.phsinit = angle(bcb1);
            end

            % Algorithm and problem parameters
            prbp.ndims = ndims(maps.mask);     % # spatial dimensions 
            prbp.kmaxdistance = [Inf Inf Inf]; % maximum kT-point location
            prbp.beta = lambdavec(c_lambdaexp);% initial RF regularization
            prbp.betaadjust = 0;               % automatically adjust RF regularization parameter
            prbp.dimxyz = size(maps.b0);
            prbp.filtertype = 'Lin phase';     % alternately add kT-points on either size of the DC point
            prbp.trajres = 2;                  % maximum spatial frequency of OMP search grid (was 2 for most August 2015 results)
            prbp.Npulse = c_kTpoints;          % number of kT-points subpulses
            algp.nthreads  = 10;               % number of compute threads (for mex only)
            algp.computemethod = 'mex';
            algp.ncgiters = 3; 
            algp.cgtol = 0.9999;
            prbp.Ncred = inf;

            % Run the kT point design 
            %   m ... STA solution 
            %   wvfrms ... optimized RF and gradient blips)        
            [all_m, wvfrms] = dzktpts(algp,prbp,maps); 
            rfw = wvfrms.rf;

            %evaluate the optimized results
            farmse = sqrt(mean((abs(all_m.images(maps.mask))/pi*180 - prbp.delta_tip).^2));
            rfrms = norm(rfw);
            fprintf('Flip angle RMSE: %.4f, RMS RF power: %.4f.\n\n',farmse,rfrms);
            
            %save the results for later
            farmse_all(c_kTpoints, c_diffrand, c_lambdaexp)    = farmse;
            rfrms_all(c_kTpoints, c_diffrand, c_lambdaexp)     = rfrms;
            waveforms_all{c_kTpoints, c_diffrand, c_lambdaexp} = wvfrms;
            
            if b_evalAllDatasets == true
                evalAllDatasets('tailored',wvfrms, numTailored, numkTpoints, c_diffrand, c_lambdaexp, lambdavec, c_kTpoints, prbp); drawnow;
            end
        end
        
        %plot l-curve if more than one runs with different beta were done
        if (c_lambdaexp == length(lambdavec)) && c_lambdaexp > 1
            figure;hold all;
            loglog(squeeze(farmse_all(c_kTpoints,:,1:end)).',squeeze(rfrms_all(c_kTpoints,:,1:end)).');
            xlabel('log_{10}(FA RMSE / deg)');
            ylabel('log_{10}(RF RMSE / a.u.)');
            sgtitle (['L-curve for ',pulseType,num2str(length(libraryIndices)),'-',num2str(c_kTpoints),'kT phaseinit=',num2str(numPhaseInit)]);
        end
    end
end
designUP_OK = 1;
end