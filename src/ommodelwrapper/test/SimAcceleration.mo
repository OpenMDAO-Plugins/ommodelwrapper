  model SimAcceleration
    import VehicleDesign.*;
    parameter Real end_speed = 100;
    parameter Real max_RPM = 6500;
    parameter Real stroke = 78.8;
    parameter Real bore = 82.0;
    parameter Real conrod = 115.0;
    Real throttle = 1;
    Integer test(start = 1);
    Integer gear(start = 1);
    Modelica.SIunits.Time accel_time(start = 0);
    Vehicle car(stroke = stroke, bore = bore, conrod = conrod, current_gear.start = 1);
    annotation(experiment(StartTime = 0.0, StopTime = 10.0, Tolerance = 1e-005));
  equation
    when sample(0, 0.001) then
          car.throttle = throttle;
      car.current_gear = gear;
      test = 1;
      gear = if pre(car.vEngine.RPM) >= max_RPM then pre(gear) + 1 else pre(gear);
    
    end when;
  algorithm
    if car.velocity >= end_speed and accel_time <= 0.001 then 
        accel_time:=time;

    else 
    end if;
  end SimAcceleration;