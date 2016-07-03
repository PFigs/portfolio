function data = readunbvmf(filepath,lat,long,neighbours)
%  lat, long (2.0x2.5 º) aw, ah, zhd, zwd

  % Open file and read file
    fid = fopen(filepath);
    if fid == -1
       error(['readigs: file not found: ' sprintf('%s',filepath)]); 
    end
    file  = textscan(fid,'%s','Delimiter','\n','whitespace','');
    fclose(fid);
    file  = file{1};
    fSize = size(file,1);
    
    [lat,long] = movetogrid(round(lat),round(long));
    
    state      = 'lat';
    for k=1:fSize
%         str     = file{k};
        info    = regexp(file{k},'\s*','split');
        info(1) = [];     
        %Find lat line
        if strcmpi(state,'lat')
            if str2double(info{1}) == lat
                state  = 'long';
            end
            
        %Find long line
        elseif strcmpi(state,'long')
            if str2double(info{2}) == long
                line = k;
                break;
            end
        end
    end
    
    l    = 0;
    data = zeros(neighbours*2,6);
    for k=line-neighbours:line+neighbours
        l=l+1;
        info    = regexp(file{k},'\s*','split');
        info(1) = [];
        lat  = str2double(info{1});
        long = str2double(info{2});
        aw   = str2double(info{3});
        ah   = str2double(info{4});
        zhd  = str2double(info{5});
        zwd  = str2double(info{6});
        data(l,:) = [lat,long,aw,ah,zhd,zwd];
        disp(['PUSHING: ',info{1},',',info{2}])
    end
    
end

function [lat,long] = movetogrid(lat,long)
    
    if mod(lat,2)
       left = mod(long,2);
       if left >= 2/2
           lat = lat-left;
       else
           lat = lat+2-left;
       end
    end
    if mod(long,2.5)
       left = mod(long,2.5);
       if left >= 2.5/2
           long = long-left;
       else
           long = long+2.5-left;
       end
    end
    if long < 0
       long = abs(long) +180;
    end
end
