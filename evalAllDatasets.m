% This script evaluates default shim setting, tailored pulses and universal
% pulses using the CV in the 3D heart target region (small tip angle) in 
% each of the B1+ datasets. 
% 
% Created by Christoph S. Aigner, PTB, June 2021.
% Email: christoph.aigner@ptb.de

%initialize the arrays for the first time
if ~(exist('CV_pre_all_subectrob','var'))
    CV_post_all_subectrob = zeros(max(numkTpoints),length(allmaps));
%     farmse_subectrob = zeros(max(numkTpoints),length(allmaps));
end

load('cmap.mat'); %load the external colormap
c_pos = 1;        %always start with the first subplot position
figure(1);        %always assure that Fig1 exits for the CV evaluation
figure;           %open a second window for the FA prediction

%set the errors to 0 for the current c_kTpoints
CV_post_all_subectrob(c_kTpoints,:) = zeros(1,length(allmaps));
% farmse_subectrob(c_kTpoints,:)      = zeros(1,length(allmaps));

for c_subj=1:(length(allmaps)) %loop over the B1+ datasets

    %evaluate and plot only one B1+ dataset in each loop
    numberofmaps = 1;

    % initialize maps (to be sure to have the right size)
    maps.numberofmaps = numberofmaps;
    maps.b1           = zeros(80,80,64*numberofmaps,8);
    maps.mask         = zeros(80,80,64*numberofmaps);
    maps.b0           = zeros(80,80,64*numberofmaps);
    
    % get the maps from allmaps
    maps.b1   = allmaps{c_subj}.b1;
    maps.mask = allmaps{c_subj}.mask;
    maps.b0   = allmaps{c_subj}.b0;

    maps.mask = logical(maps.mask);

    % set the parameters used for preparation and quality check  
    fov     = maps.fov;               % field of view, cm
    Nc      = size(maps.b1,4);        % # tx channels
    dimxyz  = size(maps.b1(:,:,:,1)); % pixels, dim of design grid
    Ns      = prod(dimxyz);           % total # pixels
    Npulset = size(rfw,1);            % number of subpulses
    k       = wvfrms.k;               % phase encoding position
    rf      = rfw;                    % complex RF weights for each kT-point
    dt      = prbp.dt;                % dt, s
    gambar  = 4257;                   % gamma/2pi, Hz/T
    gam     = gambar*2*pi;            % gamma, radians/g

    % so far B0 is not included
    % f0 = maps.b0(:);
    f0 = maps.b1(:,:,:,1)*0; %to cope for different B1 sizes
    f0 = f0(:);

    % set up the RF vector of one subpulse for the FA prediction
    rfss = [ones(prbp.Nsubpts,1);zeros(prbp.nblippts,1)];
    Nrp  = length(rfss);                 % number of samples in subpulse
    tr   = 0:dt:(length(rfss)-1)*dt;     % time vector for one subpulse
    A    = 1i*gam*dt*exp(1i*2*pi*f0*tr); % system matrix for first subpulse
    m1rung = A*rfss;

    % define the grid
    xg = -fov(1)/2:fov(1)/dimxyz(1):fov(1)/2-fov(1)/dimxyz(1);
    yg = -fov(2)/2:fov(2)/dimxyz(2):fov(2)/2-fov(2)/dimxyz(2);
    zg = -fov(3)/2:fov(3)/dimxyz(3):fov(3)/2-fov(3)/dimxyz(3);
    [xx,yy,zz] = ndgrid(xg, yg, zg);
    xx = [xx(:) yy(:) zz(:)];

    % in case its not already done, subtract off first coil's phase
    sens = maps.b1.*exp(-1i*repmat(angle(maps.b1(:,:,:,1)),[1 1 1 Nc]));
    
    % reshape B1 maps and initialize system matrix A
    Ns   = size(sens,1)*size(sens,2)*size(sens,3); % number of voxels
    sensd = reshape(sens,[Ns Nc]);                 
    A = zeros(Ns,Nc*Npulset);

    % construct design matrix by modifying one rung excitation
    % patterns with appropriate k-space locations, sensitivities, and
    % off-resonance time offset
    for ii = 1:Npulset
        % blip-induced phase shift
        kphs = xx*k(ii,:)';
        % off res-induced phase shift - account for phase accrual to
        % end of pulse
        totphs = exp(1i*2*pi*(f0*((ii-1)*Nrp - Npulset*Nrp)*dt+kphs));
        tmp = m1rung.*totphs;
        for kk = 1:Nc
            % apply sens, stick it in the design matrix
            A(:,(kk-1)*Npulset+ii) = sensd(:,kk).*tmp;
        end
    end

    % get (complex) excitation pattern
    m   = reshape(A * rf(:),[Ns 1]);

    %reshape m back to the size of the B1+ maps to get FA predictions
    images=(reshape(m,size(maps.b1(:,:,:,1))));

    %compute the CV of the FA predictions in the ROI
    b1pat_post = abs(images)/max(max(max(abs(images)))); 
    tmp_post   = abs(b1pat_post(~~maps.mask));
    CV_post    = std(tmp_post(:))/mean(tmp_post(:));
    
    %save the CV of each kT point and dataset
    CV_post_all_subectrob(c_kTpoints,c_subj) = CV_post;
    
    %get the 3D position of the heart center 
    [transpos, corpos, sagpos] = getHeartCenter(c_subj);

    %plot the sagital slice of the FA prediction
    subplot(ceil(length(allmaps)/5)+1,5,c_pos+4)
    imshow(rot90(squeeze(abs(images(sagpos,20:end,:))/pi*180).',2),[0 20])

    c_pos = c_pos+1; %update the position counter 
end
colormap(cmap);               %set the colormap
delete(subplot(6,5, [1 2 3])) %remove empty subplots

% add a proper title
if strcmp(pulseType,'default')
        name = [pulseType, ' shim setting'];
elseif strcmp(pulseType,'tailored')
        name = [pulseType,num2str(numTailored),'-',num2str(c_kTpoints),'kT, phaseinit=',num2str(c_diffrand), ', regularization=',num2str(lambdavec(c_lambdaexp))];
elseif strcmp(pulseType,'UP')
        name = [pulseType,num2str(Nm),'-',num2str(c_kTpoints),'kT, phaseinit=',num2str(c_diffrand), ', regularization=',num2str(lambdavec(c_lambdaexp))];
end
sgtitle (['FA predictions for ',name]);
           

%plot the CV evaluation for each B1+ dataset
figure(1);
plot(CV_post_all_subectrob(c_kTpoints,:),'DisplayName',name); hold all;

axis([0 32 0 0.7])
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'YTick'       , 0:0.1:1, ...
  'LineWidth'   , 2         );

xlabel('B1+ dataset');
ylabel('CV / %');
legend;