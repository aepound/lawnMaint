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
    function breaksDownWhenRandomBreakTriggered(testCase)
      
    end
  end
    
    
end
