    close all;
numids = 1:userparams('MAXSAT');
init = 1;
last = 3000;
for counter = init : last
        
        % Validates entries
        if isempty(ranges(1,counter).TOW) || ranges(1,counter).TOW ~= ranges(2,counter).TOW
            disp('nothing to do');
            continue
        end
        
        % Gets visible sats
        satids1 = numids((ranges(1,counter).CPCA ~= 0));
        satids2 = numids((ranges(2,counter).CPCA ~= 0));

        % Trims not common
        if length(satids1) < length(satids2)
            valid = satids1;
        else
            valid = satids2;
        end
        
        % Computes single difference
        single(valid,counter) = ranges(1,counter).CPCA(valid)-ranges(2,counter).CPCA(valid);

        % Obtains reference sat (highest elevation)
        satid = getreferencesat(ranges(1,counter).SATELV);

        % Computes double difference
        double(valid,counter) = single(valid,counter) - single(satid,counter);

        % Computes triple difference
        if counter > init
            triple(valid,counter) = double(valid,counter) - double(valid,counter-1);
        end
end


for k=1:size(triple,1)
   if all(triple(k,:) == 0), continue; end;
   figure
   plot(triple(k,:));
    
end