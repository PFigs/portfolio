function [mx,my] = errorellipse(handle,Cov,varargin)
% ERROR_ELLIPSE - plot an error ellipse, or ellipsoid, defining confidence region
%    ERROR_ELLIPSE(C22) - Given a 2x2 covariance matrix, plot the
%    associated error ellipse, at the origin. It returns a graphics handle
%    of the ellipse that was drawn.
%
%    ERROR_ELLIPSE(C33) - Given a 3x3 covariance matrix, plot the
%    associated error ellipsoid, at the origin, as well as its projections
%    onto the three axes. Returns a vector of 4 graphics handles, for the
%    three ellipses (in the X-Y, Y-Z, and Z-X planes, respectively) and for
%    the ellipsoid.
%
%    ERROR_ELLIPSE(C,MU) - Plot the ellipse, or ellipsoid, centered at MU,
%    a vector whose length should match that of C (which is 2x2 or 3x3).
%
%    ERROR_ELLIPSE(...,'Property1',Value1,'Name2',Value2,...) sets the
%    values of specified properties, including:
%      'C' - Alternate method of specifying the covariance matrix
%      'mu' - Alternate method of specifying the ellipse (-oid) center
%      'conf' - A value betwen 0 and 1 specifying the confidence interval.
%        the default is 0.5 which is the 50% error ellipse.
%      'scale' - Allow the plot the be scaled to difference units.
%      'style' - A plotting style used to format ellipses.
%      'clip' - specifies a clipping radius. Portions of the ellipse, -oid,
%        outside the radius will not be shown.
%
%    NOTES: C must be positive definite for this function to work properly.

    data = struct(...
           'normal', 1,...
           'mu', [0 ,0], ... % Center of ellipse (optional)
           'conf', 0.95, ... % Percent confidence/100
           'scale', 1, ... % Scale factor, e.g. 1e-3 to plot m as km
           'style', '.k', ...  % Plot style
           'clip', inf); % Clipping radius


    % Overrides default value
    if nargin >= 2 && ~mod(nargin-2,2)
       for i=1:2:size(varargin,2)
           if strcmpi(varargin{i},'mu');
               data.mu    = varargin{i+1};
           elseif strcmpi(varargin{i},'conf');
               data.conf  = varargin{i+1};
           elseif strcmpi(varargin{i},'scale') && ~operation;
               data.scale = varargin{i+1};
           elseif strcmpi(varargin{i},'clip')
               data.clip  = varargin{i+1};
           elseif strcmpi(varargin{i},'style')
               data.style  = varargin{i+1};
           elseif strcmpi(varargin{i},'normal')
               data.normal = strcmpi(varargin{i+1},'on');
           end
       end
    end

    if isempty(data.mu)
      data.mu = zeros(length(Cov),1);
    end

    if data.conf <= 0 || data.conf >= 1
      error('conf parameter must be in range 0 to 1, exclusive')
    end

    [r,c] = size(Cov);
    if r ~= c || (r ~= 2 && r ~= 3)
      error(['Don''t know what to do with ',num2str(r),'x',num2str(c),' matrix'])
    end

    x0 = data.mu(1);
    y0 = data.mu(2);

    % Compute quantile for the desired percentile
%     if data.normal
    k = chi2inv(data.conf,r); % r is the number of dimensions (degrees of freedom)
%     else
%         [~,k] = crr(Cov,varargin);
%     end
    
    if r==2 && c==2
      % Make the matrix has positive eigenvalues - else it's not a valid covariance matrix!
      if any(eig(Cov) <=0)
        error('The covariance matrix must be positive definite (it has non-positive eigenvalues)')
      end

      [x,y,z] = getpoints(Cov,data.clip);
      plot(handle,data.scale*(x0+k*x),data.scale*(y0+k*y),data.style);
      axis(handle,'equal');
% ch=get(legend(handle),'children')
% m=findobj(ch, 'Type', 'line', '-and', '-not', 'Marker', 'none');
    else
      error('Cov (covaraince matrix) must be specified as a 2x2 or 3x3 matrix)')
    end
    %axis equal
    mx = data.scale*(x0+k*x);
    my = data.scale*(y0+k*y);
end
%---------------------------------------------------------------
% getpoints - Generate x and y points that define an ellipse, given a 2x2
%   covariance matrix, C. z, if requested, is all zeros with same shape as
%   x and y.
function [x,y,z] = getpoints(C,clipping_radius)

    n=100; % Number of points around ellipse
    p=0:pi/n:2*pi; % angles around a circle

    [eigvec,eigval] = eig(C); % Compute eigen-stuff
    xy = [cos(p'),sin(p')] * sqrt(eigval) * eigvec'; % Transformation
    x = xy(:,1);
    y = xy(:,2);
    z = zeros(size(x));

    % Clip data to a bounding radius
    if nargin >= 2
      r = sqrt(sum(xy.^2,2)); % Euclidian distance (distance from center)
      x(r > clipping_radius) = nan;
      y(r > clipping_radius) = nan;
      z(r > clipping_radius) = nan;
    end
    
end
%---------------------------------------------------------------
function x=qchisq(P,n)
% QCHISQ(P,N) - quantile of the chi-square distribution.
    if nargin<2
      n=1;
    end

    s0 = P==0;
    s1 = P==1;
    s = P>0 & P<1;
    x = 0.5*ones(size(P));
    x(s0) = -inf;
    x(s1) = inf;
    x(~(s0|s1|s))=nan;

    for ii=1:14
      dx = -(pchisq(x(s),n)-P(s))./dchisq(x(s),n);
      x(s) = x(s)+dx;
      if all(abs(dx) < 1e-6)
        break;
      end
    end
end

%---------------------------------------------------------------
function F=pchisq(x,n)
% PCHISQ(X,N) - Probability function of the chi-square distribution.
if nargin<2
  n=1;
end
F=zeros(size(x));

if rem(n,2) == 0
  s = x>0;
  k = 0;
  for jj = 0:n/2-1;
    k = k + (x(s)/2).^jj/factorial(jj);
  end
  F(s) = 1-exp(-x(s)/2).*k;
else
  for ii=1:numel(x)
    if x(ii) > 0
      F(ii) = quadl(@dchisq,0,x(ii),1e-6,0,n);
    else
      F(ii) = 0;
    end
  end
end
end
%---------------------------------------------------------------
function f=dchisq(x,n)
% DCHISQ(X,N) - Density function of the chi-square distribution.
if nargin<2
  n=1;
end
f=zeros(size(x));
s = x>=0;
f(s) = x(s).^(n/2-1).*exp(-x(s)/2)./(2^(n/2)*gamma(n/2));
end


