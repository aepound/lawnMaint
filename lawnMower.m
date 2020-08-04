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

properties(Hidden)
  state
end

methods
  % Constructor:
  function obj = lawnMower(varargin)
    obj.state.usage.lifetime = 0;
    obj.state.usage.blade = 0;
  end
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
  function amountAdded = fillGas(obj,amount)
    % obj: mower
    % amount: Amount of gallons adding to tank
    % out: Actual amount added.
    if nargin < 2
      amount = inf;
    end
    
    amountAdded = calculateGasToAdd(obj,amount);
    obj.addGas(amountAdded);
    
  end
  function amountRemoved = siphonGas(obj,amount)
    % obj: mower
    % amount: Amount of gallons requested to be siphoned
    % out: Actual amount siphoned.
    if nargin < 2
      amount = inf;
    end
    
    amountRemoved = calculateGasToRemove(obj, amount);
    obj.removeGas(amountRemoved);
    
  end
  
  
  
  function amountRemoved = useGas(obj,amount)
    % throws error when out of gas
    amountRemoved = obj.siphonGas(amount);
    obj.addTimeToState(obj.runtime(amountRemoved));
    
    if amountRemoved < amount
      error('lawnMwr:OutOfGas','Ran out of gas!')
    end
  end
end


methods

  function run(obj,nMins)
    maxGallonsUsed = obj.gallonsUsed(nMins);
    try
      realGallons = obj.useGas(maxGallonsUsed); %#ok<NASGU>
    catch me
      if strcmp(me.identifier,'lawnMwr:OutOfGas')
        rethrow(me);
      end
    end
  end
    
end

methods(Hidden)
  function amountRemoved = calculateGasToRemove(obj,amount)  
    amountRemoved= min(obj.gallonsUntilEmpty(), amount);
  end
  function amountToAdd = calculateGasToAdd(obj,amount)
    amountToAdd = min(obj.gallonsUntilFull(), amount);
  end
  function obj = addGas(obj,amount)
    obj.gasGallons = obj.gasGallons + amount;
  end
  function obj = removeGas(obj,amount)
    obj.gasGallons = obj.gasGallons - amount;
  end
  function addTimeToState(obj,time)
    obj.state.usage = structfun(@(x) x+time,obj.state.usage,'uni',0);
    %obj.state.usage.lifetime = obj.state.usage.lifetime + time;
  end
  function amount = gallonsUntilFull(obj)
    amount = obj.gasTankSize - obj.gasGallons;
  end
  function amount = gallonsUntilEmpty(obj)
    amount = obj.gasGallons;
  end
  function time = runtimeIfFull(obj)
    time = runtime(obj.gasTankSize);
  end
  function time = runtimeLeft(obj)
    time = runtime(obj.gasGallons);
  end
  function time = runtime(obj,gallons)
    time = gallons./obj.gasUsageRate;
  end
  function gallons = gallonsUsed(obj,time)
    gallons = time.*obj.gasUsageRate;
  end
end


end
