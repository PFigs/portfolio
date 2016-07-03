function [sAlgo, sStat] = myworkspace( sEpoch, sAlgo, sStat )
% WORKFLOW describes the general flow of the program
%   The function receives a structure with the data known for the current
%   epoch (or all of them if processing offline data)
%  
%   The structure is defined by CONFIGPPPLAB
%  
%   WARNING
%   IT IS EXPECTED TO RECEIVE DATA IN MATRIX FORMAT TO EXPEDITE THE SEARCH
%   FOR SATELLITES WITH DATA. Thus, saving satellite data and ephemerides
%   must be done in a consistent way, for example, matrix Nx32.
%
%   INPUT
%   EPOCH - Structure with relevant data for data processing
%
%   OUTPUT
%   sALGO - Structure updated with Algorithm(s) results
%  
%   Pedro Silva, Instituto Superior Tecnico, December 2011
%   Last revision: January 2012

    
    % Retrieves data for the available satellites and applies masks
    sAlgo = masksatellites(sEpoch, sAlgo); % to improve
    
    % Check if there is enough satellites to obtain a position fix and
    % retrieve measurements for the available satellites
    if sAlgo.nSat >= 4
        sAlgo = filtermes(sEpoch, sAlgo);
        sAlgo = processdata( sEpoch, sAlgo, sEpoch.TOW, sEpoch.DOY, sEpoch.WD);
    else
        % Marks structure for caller to know nothing was done
        fprintf('Not enough satellites (%d) at epoch: %d\n',sAlgo.nSat,sEpoch.iEpoch);
        sAlgo.lastAvlbSat = [];
        sAlgo.lastNSat    = NaN;
    end
        
end


function sAlgo = masksatellites(sEpoch, sAlgo)
%MASKSATELLITES will mask the unwanted satellites for the algorithm
%processing
%   The function can mask them by elevation, type GPS, GLONASS, SBAS and so
%   on.
%
%   Pedro Silva, Instituto Superior Tecnico, December 2011
    

    valid = sEpoch.ranges.PRL1(sEpoch.iEpoch,:) ~= 0;
    sAlgo.availableSat = find(valid(1:32));
   
    sAlgo.nSat = size(sAlgo.availableSat,2);
        
end


function sAlgo = filtermes( sEpoch, sAlgo )
%FILTERMES retrieves the ranges to the available SATS from the current epoch
%  This can further be improved in a per algorythm basis
%  The WD is also calculated for offline data
%
%  INPUT
%  EPOCH - Epoch data
%  SATS  - Satellites to use
%
%  OUTPUT
%  RANGES - Measurements for the given SATS
%  EPH    - Ephemerides for given SATS
%
% Pedro Silva, Instituto Superior Tecnico, January 2012

    % Init local variables to ease reading
    sats   = sAlgo.availableSat;
    mes    = sEpoch.ranges;
    iEpoch = sEpoch.iEpoch;
    
    % Offline data has already been parsed into a structure            

        sAlgo.ranges.PRL1 = mes.PRL1(iEpoch,sats)';        
        sAlgo.ranges.CPL1 = mes.CPL1(iEpoch,sats)';        
        sAlgo.ranges.PRL2 = mes.PRL2(iEpoch,sats)';        
        sAlgo.ranges.CPL2 = mes.CPL2(iEpoch,sats)';
%       sAlgo.ranges.PRCA = mes.PRCA(iEpoch,sats)';

    
    % Converts ephemerides matrix to struct
    if strcmpi(sAlgo.freqmode,'L1')
        sAlgo.iono    = sEpoch.iono;
    end
    
    sAlgo.eph     = buildsEph(sEpoch.eph.data(:,sats)); 
    sAlgo.eph.tow = sEpoch.TOW;
    
end


function sAlgo = processdata( sEpoch, sAlgo, TOW, DOY, WD )
%PROCESSDATA uses a GPS position algorithm to process the given data
%   For the given data RANGES and EPH the algorithm specified by ALGTYPE
%   will be used to evaluate the data at the current TOW
%
%   Pedro Silva, Instituto Superior Tecnico, Dezembro 2011

    % Process data - Receiver independent 
    
    algtype = sAlgo.algtype;
    if strcmpi(algtype,'slip')
        sAlgo = slipdetector( sEpoch, sAlgo, TOW, DOY, WD );

    elseif strcmpi(algtype,'mwslip')
        sAlgo = realslipdetector( sEpoch, sAlgo, TOW, DOY, WD );
        
        
    end
    
    % Keep information on last used satellites
    sAlgo.lastAvlbSat = sAlgo.availableSat;
    sAlgo.lastNSat    = sAlgo.nSat;
    
end
