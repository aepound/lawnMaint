classdef lawnMowerTest < matlab.unittest.TestCase
   
  
  properties
    mower
    
  end
  
  methods(TestMethodSetup)
    function createMower(testCase)
      testCase.mower = lawnMower;
    end
  end
  methods(Test)
    function createLawnMower(testCase)
      testCase.assertInstanceOf(lawnMower(),'lawnMower')
    end
    
    function checkGasTankSizeGreaterThan0(testCase)
      tankSz = testCase.mower.gasTankSize;
      testCase.assertTrue(tankSz > 0);
    end
    
    
    function checkGasLevelBtwn0and1(testCase)
      testCase.assertTrue(testCase.mower.gasLevel >= 0 && ...
                          testCase.mower.gasLevel <= 1);
    end
    
    function fillGasNoArgsYieldsFull(testCase)
      testCase.mower.fillGas();
      testCase.assertEqual(testCase.mower.gasLevel,1);
    end
    
    function fillGasWhenEmptyWHalfGallonYieldsHalfGallon(testCase)
      amount = 0.5;
      testCase.mower.siphonGas();
      testCase.mower.fillGas(amount);
      testCase.assertEqual(testCase.mower.gasGallons,amount);
    end
    
    function fillGasWTooMuchFillsTank(testCase)
      testCase.mower.siphonGas();
      testCase.mower.fillGas(100);
      testCase.assertEqual(testCase.mower.gasGallons,...
                           testCase.mower.gasTankSize);
    end
    

    
    function siphonAllGasYeildsEmpty(testCase)
      testCase.mower.siphonGas(testCase.mower.gasTankSize);
      testCase.assertTrue(testCase.mower.gasLevel == 0)
    end
    
    function siphonGasWOArgSiphonsAllGas(testCase)
      testCase.mower.siphonGas();
      testCase.assertTrue(testCase.mower.gasLevel == 0)
    end
  end
  
  methods(Test)
    % Running the mower...
    function runMowerUsesGas(testCase)
      time = 15; % mins
      testCase.mower.fillGas();
      gaslvl1 = testCase.mower.gasLevel;
      testCase.mower.run(time);
      gaslvl2 = testCase.mower.gasLevel;
      
      testCase.assertTrue(gaslvl2 < gaslvl1);
    end
    function runMowerTwiceAsLongUsesTwiceTheGas(testCase)
      time = 15; % mins
      testCase.mower.fillGas();
      gaslvl1 = testCase.mower.gasLevel;
      testCase.mower.run(time);
      gaslvl2 = testCase.mower.gasLevel;
      gasDiff = gaslvl1 - gaslvl2;
      
      testCase.mower.run(2*time);
      gaslvl3 = testCase.mower.gasLevel;
      gasDiff2 = gaslvl2 - gaslvl3;
      
      testCase.assertTrue(gasDiff2 > gasDiff);
    end
    % Empty error testing:
    function runMowerForeverRunsOutOfGas(testCase)
      testCase.mower.fillGas();
      testCase.assertError(@()testCase.mower.run(inf), 'lawnMwr:OutOfGas');
    end
    function throwsExceptionWhenRunningOnEmpty(testCase)
      testCase.mower.siphonGas();
      testCase.assertError(@()testCase.mower.run(1),'lawnMwr:OutOfGas');
    end
    function noThrowWhenRunningToExactEmpty(testCase)
      testCase.mower.siphonGas();
      testCase.mower.fillGas(testCase.mower.gasUsageRate);
      testCase.mower.run(1);
      testCase.assertTrue(testCase.mower.gasLevel == 0);
    end
    
    function runningMowerChangesState(testCase)
      testCase.mower.fillGas();
      prevState = testCase.mower.state;
      testCase.mower.run(10);
      newState  = testCase.mower.state;
      testCase.verifyNotEqual(prevState,newState);
    end
    
  end
  methods(Test)
    % Longer-term issues???
    function throwsErrorWhenPartFails(testCase)
      testCase.mower.fillGas();
      func = @(obj) true;
      testCase.mower.Fs_run = 1/60;
      testCase.mower.hasPartFailed = func;
      testCase.verifyError(@()testCase.mower.run(3),'lawnMwr:partFailed');
    end
    
    function throwsErrorOn3rdSampleWhenPartFails(testCase)
      testCase.mower.fillGas();
      testCase.mower.state.counter = 0;
      func = @(obj) incrementStateCounterReturnTrueAtN(obj,3);
      testCase.mower.hasPartFailed = func;
      testCase.mower.Fs_run = 1/60;
      try
        testCase.mower.run(5); % This will fail..
      catch
      end
      testCase.verifyTrue(testCase.mower.state.counter == 3);      
    end
    function setRunSampleFrequency(testCase)
      testCase.mower.Fs_run = 1/60; % Hz = 1 min;
    end
    function setHasPartFailedFunction(testCase)
      func = @(obj) true;
      testCase.mower.hasPartFailed = func;
      testCase.verifyEqual(testCase.mower.hasPartFailed, func)
    end
    function checkRunUsesHasPartFailed(testCase)
      testCase.mower.fillGas();
      testCase.mower.state.counter = 0;
      func = @(obj) incrementStateCounterReturnFalse(obj);
      testCase.mower.hasPartFailed = func;
      testCase.mower.Fs_run = 1/60;
      testCase.mower.run(2);
      testCase.verifyTrue(testCase.mower.state.counter == 2);
    end
  end
  
    
    
end
function out = incrementStateCounterReturnTrueAtN(obj,N)
obj.state.counter = obj.state.counter+1;
if obj.state.counter == N
  out = true;
else
  out = false;
end
end
function out = incrementStateCounterReturnFalse(obj)
obj.state.counter = obj.state.counter+1;
out = false;
end
