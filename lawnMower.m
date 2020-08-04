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

properties
  % Having to do with part failures:
  Fs_run = 0;
  hasPartFailed;
end

properties(Hidden)
  state
end

methods
  % Constructor:
  function obj = lawnMower(varargin)
    obj.state.usage.lifetime = 0;
    obj.state.usage.blade = 0;
    obj.hasPartFailed = @(varargin) false;
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

  function timeRan = run(obj,nMins)
    nSamples = min2sec(nMins)*obj.Fs_run;
    
    partFailed = false;
    for iter = 1:nSamples
      % Call the function...
      partFailed = obj.hasPartFailed(obj);
      if partFailed
        % Then we only run up to this point
        nSecs = iter./obj.Fs_run;
        nMins = sec2min(nSecs);
        break
      end
    end
    
    maxGallonsUsed = obj.gallonsUsed(nMins);
    
    try
      realGallons = obj.useGas(maxGallonsUsed);
    catch me
      if strcmp(me.identifier,'lawnMwr:OutOfGas')
        rethrow(me);
      end
    end
    if partFailed
      error('lawnMwr:partFailed','Part has Failed!')
    end
    timeRan = obj.runtime(realGallons);
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
    % Using structfun() adds the time to all the usages...
    obj.state.usage = structfun(@(x) x+time,obj.state.usage,'uni',0);
  end
  function amount = gallonsUntilFull(obj)
    amount = obj.gasTankSize - obj.gasGallons;
  end
  function amount = gallonsUntilEmpty(obj)
    amount = obj.gasGallons;
  end
  function time = runtimeIfFull(obj)
    time = runtime(obj,obj.gasTankSize);
  end
  function time = runtimeLeft(obj)
    time = runtime(obj,gallonsUntilEmpty(obj));
  end
  function time = runtime(obj,gallons)
    time = gallons./obj.gasUsageRate;
  end
  function gallons = gallonsUsed(obj,time)
    gallons = time.*obj.gasUsageRate;
  end
  function tf = gasEmpty(obj)
    tf = true;
    if obj.gasLevel
      tf = false;
    end
  end
end


end

function sec = min2sec(min)
  sec = min*60;
end
function min = sec2min(sec)
  min = sec./60;
end
