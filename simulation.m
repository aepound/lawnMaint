%% LawnMower Simulation
%


%% A single LawnMower:
% Let's look at the lawn mower over it's time being used during a week.


avgRuntimeHrsPerDay = 6.25;
avgRuntimeMinsPerDay = avgRuntimeHrsPerDay*60;


mower = lawnMower;
runtimeIfFull = mower.runtimeIfFull();
mower.fillGas();

gasUsed = 0;
fillUps = cell(1,6);
for day = 1:6
  % Run the mower for the avgRuntimePerDay...
  timeLeftThisDay = avgRuntimeMinsPerDay;
  fillUpTimes = [];
  while timeLeftThisDay > 0
    runtime = mower.run(min(mower.runtimeLeft(),timeLeftThisDay));
    gasUsed = gasUsed + mower.gallonsUsed(runtime);
    timeLeftThisDay = timeLeftThisDay - runtime;
    
    if mower.gasEmpty()
      mower.fillGas();
      fillUpTimes = [fillUpTimes timeLeftThisDay];
    end
  end
  fillUps{day} = avgRuntimeMinsPerDay - fillUpTimes;
end

close all
figure, 
for iter = 1:length(fillUps)
  plot(fillUps{iter},'*')
  hold on
end
legend('mon','tues','weds','thurs','fri','sat')
grid on

