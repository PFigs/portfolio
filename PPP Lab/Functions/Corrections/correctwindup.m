function WU = correctwindup(WU,rcvenu,userxyz,satop)
%     return;
    if all(rcvenu==0),return;end;

    nSat   = size(satop,1);
    
    % Receiver unitary vectors
    R  = rcvenu./sqrt(sum(rcvenu.^2,2));

    % Satellite unitary vector
    ns = sqrt(sum(satop.^2,2));
    S  = zeros(nSat,3);
    for k  = 1:nSat
        S(k,:) = satop(k,:)./ns(k,:);
    end

    % Vector sat to user
    R  = repmat(R,nSat,1);
    nk = sum((satop-R).^2,2);
    k  = (satop-R);
    
    % Atributions
    Ar  = R(:,1);
    Br  = R(:,2);
    As  = S(:,1);
    Bs  = S(:,2); 
    
    for l  = 1:nSat
        K(l,:) = k(l,:)./nk(l,:);
        
%         Dr(l,:)  = Ar(l,:) - K(l,:).*(K(l,:).*Ar(l,:)) + K(l,:).*Br(l,:);
%         Ds(l,:)  = As(l,:) - K(l,:).*(K(l,:).*As(l,:)') - K(l,:).*Bs(l,:);
        
        Dr(l,:)  = [Ar(l,:),0,0] - K(l,:).*(K(l,:)*[Ar(l,:),0,0]') + cross(K(l,:),[0,Br(l,:),0]);
        Ds(l,:)  = [As(l,:),0,0] - K(l,:).*(K(l,:)*[As(l,:),0,0]') - cross(K(l,:),[0,Bs(l,:),0]);
        E(l,:)   = K(l,:)*cross(Ds(l,:),Dr(l,:))';
        dWU(l,:) = sign(E(l,:))*acos(Ds(l,:)*Dr(l,:)'./(norm(Ds(l,:))*norm(Ds(l,:))));
    end 
    % Final computation
%     dWU = sign(E)*acos(diag(Ds*Dr')./(sqrt(sum(Ds.^2,2))*sqrt(sum(Ds.^2,2))'));
    N   = round((WU-dWU)./(2*pi));
    WU  = 2*pi.*N + dWU;
    
end

% http://navipedia.org/index.php/Carrier_Phase_Wind-up_Effect#cite_note-2

% if all(rcvenu==0),return;end;
% 
% nSat   = size(satop,1);
% 
% % Receiver unitary vectors
% R  = rcvenu./sqrt(sum(rcvenu.^2,2));
% 
% % Satellite unitary vector
% ns = sqrt(sum(satop.^2,2));
% S  = zeros(nSat,3);
% for k  = 1:nSat
%     S(k,:) = satop(k,:)./ns(k,:);
% end
% 
% % Vector sat to user
% R  = repmat(R,nSat,1);
% nk = sum((satop-R).^2,2);
% k  = (satop-R);
% 
% % Atributions
% Ar  = R(:,1);
% Br  = R(:,2);
% As  = S(:,1);
% Bs  = S(:,2); 
% 
% for l  = 1:nSat
%     K(l,:) = k(l,:)./nk(l,:);
% 
% %         Dr(l,:)  = Ar(l,:) - K(l,:).*(K(l,:).*Ar(l,:)) + K(l,:).*Br(l,:);
% %         Ds(l,:)  = As(l,:) - K(l,:).*(K(l,:).*As(l,:)') - K(l,:).*Bs(l,:);
% 
%     Dr(l,:)  = Ar(l,:) - K(l,:).*(K(l,:).*Ar(l,:)') + cross(K(l,:),Br(l,:));
%     Ds(l,:)  = As(l,:) - K(l,:).*(K(l,:).*As(l,:)') - cross(K(l,:),Bs(l,:));
%     E(l,:)   = K(l,:).*(Ds(l,:).*Dr(l,:));
% 
% end
% 
% 
% 
% % Final computation
% dWU = sign(E)*acos(diag(Ds*Dr')./(sqrt(sum(Ds.^2,2))*sqrt(sum(Ds.^2,2))'));
% N   = round((WU-dWU)./(2*pi));
% WU  = 2*pi.*N + dWU;