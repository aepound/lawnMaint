classdef lawnMower < handle

% The idea is to 
%
%
%
%
%
properties
  gasTankSize = 1.0; % Units = gallons;
  gasGallons = 0.0;
  gasUsageRate = .5/60; % half Gallon / hour... Units = gallons/min
end

methods
  % Constructor:
  
end

properties(Dependent)
  gasLevel
end
methods
  function out = get.gasLevel(obj)
    out = obj.gasGallons./obj.gasTankSize;
  end
end

methods
  % Gas methods...
  function out = fillGas(obj,amount)
    % obj: mower
    % amount: Amount of gallons adding to tank
    % out: Actual amount added.
    if nargin < 2
      amount = inf;
    end
    if obj.gasTankSize - obj.gasGallons < amount
      amount = obj.gasTankSize - obj.gasGallons;
      obj.gasGallons = obj.gasTankSize;
    else
      gallons = amount + obj.gasGallons;
      obj.gasGallons = gallons;
    end
    out = amount;
  end
  function out = siphonGas(obj,amount)
    % obj: mower
    % amount: Amount of gallons requested to be siphoned
    % out: Actual amount siphoned.
    if nargin < 2
      amount = inf;
    end
    if obj.gasGallons > amount
      obj.gasGallons = obj.gasGallons - amount;
    else
      amount = obj.gasGallons;
      obj.gasGallons = 0;
    end
    out = amount;
  end
end

methods

  function run(obj,nMins)
    gallonsUsed = nMins.*obj.gasUsageRate;
    realGallons = obj.siphonGas(gallonsUsed);
  end
    
end


end
