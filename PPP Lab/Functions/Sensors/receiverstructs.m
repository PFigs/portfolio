function st = receiverstructs(receiver, st)
%RECEIVERSTRUCTS fills the structure ST with the default data for
%aquisition from this receiver
%
%   Pedro Silva, Instituto Superior Tecnico, May 2012
        
    if strcmpi('proflex',receiver)
        st.name     = 'proflex';
        st.port     = 'A';
        st.com      = 'COM1';
        st.messages = 'SNV,DPC,ION';
        st.rate     = '1';
        st.format   = 'BIN';
        st.mtp      = '3';
        st.logpath  = 'Aquisition/';
        
    elseif strcmpi('zxw',receiver)
        st.name     = 'zxw';
        st.com      = 'COM1';
        st.port     = 'A';
        st.messages = 'SNV,DBN'; %MBN
        st.rate     = '1';
        st.format   = 'BIN';
        st.mtp      = '3';
        st.logpath  = 'Aquisition/';
        
    elseif strcmpi('ublox',receiver)
        st.name     = 'ublox';
        st.com      = 'COM1';
        st.messages = 'EPH,HUI,RAW';
        st.rate     = '1';
        st.logpath  = 'Aquisition/';
        
    elseif strcmpi('ac12',receiver)
        st.name     = 'ac12';
        st.com      = 'COM1';
        st.port     = 'A';
        st.messages = 'MCA,SNV';
        st.rate     = '1';
        st.format   = 'BIN';
        st.mtp      = '3';
        st.logpath  = 'Aquisition/';
        
    end

end