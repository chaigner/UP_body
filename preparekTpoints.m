% This function prepares the universal kT-point pulse
% 
% usage: [brfvec, gvec] = preparekTpoints(Nsubpts, gradblipred, wvfrms, 
%                                         prbp)
%                   Nsubpts     = number of sample points for RF blocks
%                   gradblipred = reductionfactor of gradient blip duration
%                   prbp        = struct with most problem related params
%                   wvfrms      = struct that contains the waveforms
%                   brfvec      = array with RF samples for the scanner
%                   gvec        = array with gradient samples for the scanner
%
% Be careful with the slew rate constraints!
%
% Created by Christoph S. Aigner, PTB, June 2021.
% Email: christoph.aigner@ptb.de

function [brfvec, gvec] = preparekTpoints(Nsubpts, gradblipred, wvfrms, prbp)

    Nrungs  = size(wvfrms.rf,1);  % # rungs
    dt      = prbp.dt*1e3;  % in ms
    gambar  = 42.57;        % gyromagnetic ratio gamma [MHz/T]

    % perform some kind of modifications (abs, etc)
    %compute the required gradient area to move to the optimized k-locations
    garea   = diff([ wvfrms.k; zeros(1,size(wvfrms.k,2)) ],1)/gambar*100; %convert to SI units (cm -> m)

    %init RF structure for one rung
    rfss    = [ones(Nsubpts,1); zeros(prbp.nblippts/gradblipred,1)]; %init RF for one rung
    rfss = rfss/10; % to match the simulations Gauss->mT; anyways.. we are using relative B1 maps???

    %compute the gradients and RF for each rung and initialize them with []
    %just to be sure ;)
    gvec = [];
    brfvec = [];
    blip = [linspace(0,1,10/gradblipred), linspace(1,0,10/gradblipred)].'/(10*dt)*gradblipred; 

    for counter=1:Nrungs
        gvec = [gvec; [ zeros(Nsubpts,3); repmat(blip, [1 3])].*garea(counter,:)];
        brfvec = [brfvec; repmat(rfss,[1 prbp.Nc]).*wvfrms.rf(counter,:)];
    end

    %compute the kspaceloc of the gradients to double check them
    kspaceloc=cumsum(gvec)*(gambar)/100*dt;

    % plot the RF and Gradient vectors
    figure;
    subplot(4,1,1)
    plot(abs(brfvec)); hold all
    ylabel('|RF| / a.u.');

    subplot(4,1,2)
    plot(angle(brfvec));
    ylabel('angle(RF) / rad');

    subplot(4,1,3)
    plot(gvec)
    ylabel('grad / mT/m');

    subplot(4,1,4)
    plot(diff(gvec)/dt);
    ylabel('slew / T/m/s')
    xlabel('samples')

    %Check the slew rate constrain
    maxslew = max(max(diff(gvec)/dt));
    totalduration_in_ms=size(gvec,1)*dt*1000;

    if(maxslew > 170)
        disp('ERROR: MAX SLEW (170T/m/s) is exceeded! DO NOT USE THE GRADIENTS'); 
    %     error;
    end

    % Simulate the pulses based on the whole RF and gradient vectors
    % cut the vectors into the individual rungs (each one has a different shim)
    tprung = length(rfss);
    brfvecrung = reshape(brfvec, [tprung, Nrungs, prbp.Nc]);
    gvecrung = reshape(gvec, [tprung, Nrungs, size(gvec,2)]);
    Brfrung = [];
    grung = [];    
    for counter=1:Nrungs
        Brfrung{counter} = squeeze(brfvecrung(:,counter,:));
        grung{counter} = squeeze(gvecrung(:,counter,:));
    end

    % to check the validity of the pulses
    % sensBloch=sensd;
    % TXsc_simBloch;

    % the following transformation assure using the right coordinate system at
    % the scanner (transversal)
    brfvec = conj(brfvec);
    gvec(:,3)=-gvec(:,3);

    fprintf('RF and Gradients prepared. duration: %d ms, peak slew rate: %.4f T/m/s.\n\n',totalduration_in_ms,maxslew);

end
