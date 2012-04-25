package VehicleDesign
  model Chassis
    parameter Real mass_vehicle = 1200.0;
    parameter Real Cf = 0.035;
    parameter Real Cd = 0.3;
    parameter Real area = 2.164;
    parameter Real tire_circ = 1.905;
    Real engine_torque;
    Real mass_engine;
    Real torque_ratio;
    Real velocity;
    Real acceleration;
    constant Real pi = Modelica.Constants.pi;
    constant Real g_n = Modelica.Constants.g_n;
  protected
    Real torque;
    Real tire_radius;
    Real mass;
    Real friction;
    Real drag;
  equation
    torque = engine_torque * torque_ratio;
    tire_radius = tire_circ / (2.0 * pi);
    mass = mass_vehicle + mass_engine;
    friction = Cf * mass * g_n;
    drag = 0.5 * 1.225 * Cd * area * velocity ^ 2;
    acceleration = (torque / tire_radius - drag) / mass;
  end Chassis;
  model Transmission
    parameter Real ratio1 = 3.54;
    parameter Real ratio2 = 2.13;
    parameter Real ratio3 = 1.36;
    parameter Real ratio4 = 1.03;
    parameter Real ratio5 = 0.72;
    parameter Real final_drive_ratio = 2.8;
    parameter Real tire_circ = 1.905;
    Real velocity;
    Integer current_gear;
    Real RPM(start = 1000);
    Real torque_ratio;
  protected
    Real current_ratio;
    Real testRPM;
    Real vel_meter_per_min;
  algorithm
    current_ratio:=if current_gear == 1 then ratio1 elseif current_gear == 2 then ratio2 elseif current_gear == 3 then ratio3 elseif current_gear == 4 then ratio4 else ratio5;
    torque_ratio:=current_ratio * final_drive_ratio;
    vel_meter_per_min:=velocity * 60;
    testRPM:=(current_ratio * final_drive_ratio * vel_meter_per_min) / tire_circ;
    if testRPM < 1000 and current_gear <= 1 then 
        RPM:=1000;

    else     RPM:=testRPM;

    end if;
  end Transmission;
  model Engine
    parameter Real stroke = 78.8;
    parameter Real bore = 82.0;
    parameter Real conrod = 115.0;
    parameter Real comp_ratio = 9.3;
    parameter Real spark_angle = -37.0;
    parameter Real ncyl = 6;
    parameter Real IVO = 11.0;
    parameter Real IVC = 53.0;
    parameter Real L_v = 8.0;
    parameter Real D_v = 41.2;
    constant Real k = 1.3;
    constant Real R = 287.0;
    constant Real Ru = 8.314;
    constant Real Hu = 44000.0;
    constant Real Tw = 400.0;
    constant Real AFR = 14.6;
    constant Real P_exth = 152;
    constant Real P_amb = 101.325;
    constant Real T_amb = 298;
    constant Real air_density = 1.2;
    constant Real fuel_density = 740.0;
    constant Real mw_air = 28.97;
    constant Real mw_fuel = 114;
    constant Real pi = 3.14;
    Real RPM;
    Real throttle;
    Real power;
    Real torque;
    Real fuel_burn;
    Real engine_weight;
    Boolean overspeed;
    Boolean underspeed;
  protected
    Real stroke_m;
    Real bore_m;
    Real conrod_m;
    Real L_v_m;
    Real D_v_m;
    Real spark_angle_rad;
    Real disp;
    Real l_a;
    Real resVol;
    Real n;
    Real t_to_theta;
    Real thetastep;
    Real intake_close;
    Real intake_open;
    Real burn_duration;
    Real burn_end;
    Real r_burn_duration;
    Real T_exh;
    Real m_res;
    Real Cm;
    Real Cf;
    Real C_heat;
    Real Pratio_crit;
    Real mw;
    Real h_ind;
    Real FMEP;
    Real P0;
    Real T0;
    Real C1;
    Real C2;
    Real e1;
    Real e2;
    Real Qfac;
    Real valve1;
    Real mass_in;
    Real Qloss;
    Real P;
    Real Pmix;
    Real pmi;
    Real theta;
    Real s_theta;
    Real c_theta;
    Real term;
    Real term2;
    Real V;
    Real dV_dtheta;
    Real A;
    Real thetaSinceSpark;
    Real fac1;
    Real dWeibe_dtheta;
    Real Q;
    Real dQ_dtheta;
    Real phi;
    Real Lv;
    Real Ar;
    Real LD;
    Real CD;
    Real Pratio;
    Real flow_direction;
    Real dm_dtheta;
    Real Tg;
    Real h;
    Real BMEP;
  algorithm
    if RPM > 6000 then 
        overspeed:=true;

    else     overspeed:=false;

    end if;
    if RPM < 1000 then 
        underspeed:=true;

    else     underspeed:=false;

    end if;
    thetastep:=1;
    stroke_m:=stroke * 0.001;
    bore_m:=bore * 0.001;
    conrod_m:=conrod * 0.001;
    L_v_m:=L_v * 0.001;
    D_v_m:=D_v * 0.001;
    spark_angle_rad:=(spark_angle * pi) / 180.0;
    disp:=0.25 * pi * bore_m * bore_m * stroke_m * ncyl;
    l_a:=conrod_m / (0.5 * stroke_m);
    resVol:=1.0 / (comp_ratio - 1.0);
    n:=RPM * 0.001;
    t_to_theta:=RPM / 60.0 * 2.0 * pi;
    thetastep:=(thetastep * pi) / 180.0;
    intake_close:=((IVC - 180.0) * pi) / 180.0;
    intake_open:=((IVO - 360.0) * pi) / 180.0;
    burn_duration:=((-1.6189 * n * n + 19.886 * n + 39.951) * pi) / 180.0;
    burn_end:=2.0 * burn_duration;
    r_burn_duration:=1.0 / burn_duration;
    T_exh:=3.3955 * n * n * n - 51.9 * n * n + 279.49 * n + 676.21;
    m_res:=(1.52 * 101.325 * 30.4 * disp) / ((comp_ratio - 1.0) * T_exh * Ru);
    Cm:=(2 * stroke_m * RPM) / 60.0;
    Cf:=-0.019738 * n + 0.986923;
    C_heat:=-0.043624 * n + 1.2953;
    Pratio_crit:=(2 / (k + 1)) ^ (k / (k - 1));
    mw:=(AFR * mw_air + mw_fuel) / (1.0 + AFR);
    h_ind:=130.0 * disp ^ (-0.06) * (Cm + 1.4) ^ 0.8;
    FMEP:=0.05 * n * n + 0.15 * n + 0.97;
    P0:=P_amb * Cf;
    T0:=T_amb * C_heat;
    C1:=((2000.0 * mw) / (Ru * T0) * k) / (k - 1);
    C2:=(thetastep * throttle * P0) / t_to_theta;
    e1:=2.0 / k;
    e2:=(k + 1.0) / k;
    Qfac:=(0.95 * Hu) / (1.0 + AFR);
    valve1:=pi / (IVO + IVC + 180);
    when sample(0, 0.1) then
          mass_in:=0.0;
      Qloss:=0.0;
      P:=P_exth;
      Pmix:=0.0;
      pmi:=0.0;
      for thetad in -360:180 loop
              theta:=thetad * thetastep;
        s_theta:=sin(theta);
        c_theta:=cos(theta);
        term:=(l_a ^ 2 - s_theta ^ 2) ^ 0.5;
        term2:=l_a + 1.0 - c_theta - term;
        V:=disp * (resVol + 0.5 * term2);
        dV_dtheta:=0.5 * disp * s_theta * (1.0 + c_theta / term);
        A:=0.5 * pi * bore_m * (bore_m + stroke_m * term2);
        thetaSinceSpark:=theta - spark_angle_rad;
        if thetaSinceSpark > 0 and thetaSinceSpark < burn_end then 
                fac1:=thetaSinceSpark * r_burn_duration;
        dWeibe_dtheta:=-exp(-5.0 * fac1 ^ 3.0) * (-15.0 * fac1 ^ 2.0) * r_burn_duration;
        Q:=Qfac * mass_in;
        dQ_dtheta:=Q * dWeibe_dtheta;

        else         dQ_dtheta:=0.0;

        end if;
        P:=P + ((k - 1) * (dQ_dtheta - Qloss) - k * P * dV_dtheta) / V * thetastep;
        if theta <= intake_close and theta >= intake_open then 
                phi:=valve1 * (IVO - IVC + 540 + 2.0 * thetad);
        Lv:=0.5 * L_v_m * (1 + cos(phi));
        Ar:=pi * D_v_m * Lv;
        LD:=Lv / D_v_m;
        CD:=190.47 * LD * LD * LD * LD - 143.13 * LD * LD * LD + 31.248 * LD * LD - 2.5999 * LD + 0.6913;
        Pratio:=(P + 5.5 * Pmix) / P0;
        if Pratio > 1 then 
                Pratio:=1.0 / Pratio;
        flow_direction:=-1.0;

        else         flow_direction:=1.0;

        end if;
        if Pratio < Pratio_crit then 
                Pratio:=Pratio_crit;

        else 
        end if;
        dm_dtheta:=flow_direction * CD * Ar * C2 * (C1 * (Pratio ^ e1 - Pratio ^ e2)) ^ 0.5;
        mass_in:=mass_in + dm_dtheta;

        else 
        end if;
        Tg:=(P * V * mw) / ((mass_in + m_res) * Ru);
        Pmix:=(mass_in * T0 * Ru) / (mw * V);
        h:=h_ind * P ^ 0.8 * Tg ^ (-0.4);
        Qloss:=(0.001 * h * A * (Tg - Tw)) / t_to_theta;
        pmi:=pmi + (P + Pmix) * dV_dtheta;

      end for;
      BMEP:=(pmi * thetastep) / disp - FMEP;
      power:=(0.5 * BMEP * RPM * disp * ncyl) / 60;
      torque:=(30.0 * power) / (pi * RPM) * 1000.0;
      fuel_burn:=(ncyl * mass_in * 1000.0 * RPM) / (60.0 * fuel_density * (1.0 + AFR) * 2.0);
      engine_weight:=100.0 / 0.002 * (disp - 0.001) + 75.0;
    
    end when;
  end Engine;
  model Engine2
    parameter Real stroke = 78.8;
    parameter Real bore = 82.0;
    parameter Real conrod = 115.0;
    parameter Real comp_ratio = 9.3;
    parameter Real spark_angle = -37.0;
    parameter Real ncyl = 6;
    parameter Real IVO = 11.0;
    parameter Real IVC = 53.0;
    parameter Real L_v = 8.0;
    parameter Real D_v = 41.2;
    constant Real k = 1.3;
    constant Real R = 287.0;
    constant Real Ru = 8.314;
    constant Real Hu = 44000.0;
    constant Real Tw = 400.0;
    constant Real AFR = 14.6;
    constant Real P_exth = 152;
    constant Real P_amb = 101.325;
    constant Real T_amb = 298;
    constant Real air_density = 1.2;
    constant Real fuel_density = 740.0;
    constant Real mw_air = 28.97;
    constant Real mw_fuel = 114;
    constant Real pi = 3.14;
    Real RPM;
    Real throttle;
    Real power;
    Real torque;
    Real fuel_burn;
    Real engine_weight;
    Boolean overspeed;
    Boolean underspeed;
  protected
    Real stroke_m;
    Real bore_m;
    Real conrod_m;
    Real L_v_m;
    Real D_v_m;
    Real spark_angle_rad;
    Real disp;
    Real l_a;
    Real resVol;
    Real n;
    Real t_to_theta;
    Real thetastep;
    Real intake_close;
    Real intake_open;
    Real burn_duration;
    Real burn_end;
    Real r_burn_duration;
    Real T_exh;
    Real m_res;
    Real Cm;
    Real Cf;
    Real C_heat;
    Real Pratio_crit;
    Real mw;
    Real h_ind;
    Real FMEP;
    Real P0;
    Real T0;
    Real C1;
    Real C2;
    Real e1;
    Real e2;
    Real Qfac;
    Real valve1;
    Real mass_in;
    Real Qloss;
    Real P;
    Real Pmix;
    Real pmi;
    Real theta;
    Real s_theta;
    Real c_theta;
    Real term;
    Real term2;
    Real V;
    Real dV_dtheta;
    Real A;
    Real thetaSinceSpark;
    Real fac1;
    Real dWeibe_dtheta;
    Real Q;
    Real dQ_dtheta;
    Real phi;
    Real Lv;
    Real Ar;
    Real LD;
    Real CD;
    Real Pratio;
    Real flow_direction;
    Real dm_dtheta;
    Real Tg;
    Real h;
    Real BMEP;
  algorithm
    if RPM > 6000 then 
        overspeed:=true;

    else     overspeed:=false;

    end if;
    if RPM < 1000 then 
        underspeed:=true;

    else     underspeed:=false;

    end if;
    thetastep:=1;
    stroke_m:=stroke * 0.001;
    bore_m:=bore * 0.001;
    conrod_m:=conrod * 0.001;
    L_v_m:=L_v * 0.001;
    D_v_m:=D_v * 0.001;
    spark_angle_rad:=(spark_angle * pi) / 180.0;
    disp:=0.25 * pi * bore_m * bore_m * stroke_m * ncyl;
    l_a:=conrod_m / (0.5 * stroke_m);
    resVol:=1.0 / (comp_ratio - 1.0);
    n:=RPM * 0.001;
    t_to_theta:=RPM / 60.0 * 2.0 * pi;
    thetastep:=(thetastep * pi) / 180.0;
    intake_close:=((IVC - 180.0) * pi) / 180.0;
    intake_open:=((IVO - 360.0) * pi) / 180.0;
    burn_duration:=((-1.6189 * n * n + 19.886 * n + 39.951) * pi) / 180.0;
    burn_end:=2.0 * burn_duration;
    r_burn_duration:=1.0 / burn_duration;
    T_exh:=3.3955 * n * n * n - 51.9 * n * n + 279.49 * n + 676.21;
    m_res:=(1.52 * 101.325 * 30.4 * disp) / ((comp_ratio - 1.0) * T_exh * Ru);
    Cm:=(2 * stroke_m * RPM) / 60.0;
    Cf:=-0.019738 * n + 0.986923;
    C_heat:=-0.043624 * n + 1.2953;
    Pratio_crit:=(2 / (k + 1)) ^ (k / (k - 1));
    mw:=(AFR * mw_air + mw_fuel) / (1.0 + AFR);
    h_ind:=130.0 * disp ^ (-0.06) * (Cm + 1.4) ^ 0.8;
    FMEP:=0.05 * n * n + 0.15 * n + 0.97;
    P0:=P_amb * Cf;
    T0:=T_amb * C_heat;
    C1:=((2000.0 * mw) / (Ru * T0) * k) / (k - 1);
    C2:=(thetastep * throttle * P0) / t_to_theta;
    e1:=2.0 / k;
    e2:=(k + 1.0) / k;
    Qfac:=(0.95 * Hu) / (1.0 + AFR);
    valve1:=pi / (IVO + IVC + 180);
    mass_in:=0.0;
    Qloss:=0.0;
    P:=P_exth;
    Pmix:=0.0;
    pmi:=0.0;
    for thetad in -360:180 loop
          theta:=thetad * thetastep;
      s_theta:=sin(theta);
      c_theta:=cos(theta);
      term:=(l_a ^ 2 - s_theta ^ 2) ^ 0.5;
      term2:=l_a + 1.0 - c_theta - term;
      V:=disp * (resVol + 0.5 * term2);
      dV_dtheta:=0.5 * disp * s_theta * (1.0 + c_theta / term);
      A:=0.5 * pi * bore_m * (bore_m + stroke_m * term2);
      thetaSinceSpark:=theta - spark_angle_rad;
      if thetaSinceSpark > 0 and thetaSinceSpark < burn_end then 
            fac1:=thetaSinceSpark * r_burn_duration;
      dWeibe_dtheta:=-exp(-5.0 * fac1 ^ 3.0) * (-15.0 * fac1 ^ 2.0) * r_burn_duration;
      Q:=Qfac * mass_in;
      dQ_dtheta:=Q * dWeibe_dtheta;

      else       dQ_dtheta:=0.0;

      end if;
      P:=P + ((k - 1) * (dQ_dtheta - Qloss) - k * P * dV_dtheta) / V * thetastep;
      if theta <= intake_close and theta >= intake_open then 
            phi:=valve1 * (IVO - IVC + 540 + 2.0 * thetad);
      Lv:=0.5 * L_v_m * (1 + cos(phi));
      Ar:=pi * D_v_m * Lv;
      LD:=Lv / D_v_m;
      CD:=190.47 * LD * LD * LD * LD - 143.13 * LD * LD * LD + 31.248 * LD * LD - 2.5999 * LD + 0.6913;
      Pratio:=(P + 5.5 * Pmix) / P0;
      if Pratio > 1 then 
            Pratio:=1.0 / Pratio;
      flow_direction:=-1.0;

      else       flow_direction:=1.0;

      end if;
      if Pratio < Pratio_crit then 
            Pratio:=Pratio_crit;

      else 
      end if;
      dm_dtheta:=flow_direction * CD * Ar * C2 * (C1 * (Pratio ^ e1 - Pratio ^ e2)) ^ 0.5;
      mass_in:=mass_in + dm_dtheta;

      else 
      end if;
      Tg:=(P * V * mw) / ((mass_in + m_res) * Ru);
      Pmix:=(mass_in * T0 * Ru) / (mw * V);
      h:=h_ind * P ^ 0.8 * Tg ^ (-0.4);
      Qloss:=(0.001 * h * A * (Tg - Tw)) / t_to_theta;
      pmi:=pmi + (P + Pmix) * dV_dtheta;

    end for;
    BMEP:=(pmi * thetastep) / disp - FMEP;
    power:=(0.5 * BMEP * RPM * disp * ncyl) / 60;
    torque:=(30.0 * power) / (pi * RPM) * 1000.0;
    fuel_burn:=(ncyl * mass_in * 1000.0 * RPM) / (60.0 * fuel_density * (1.0 + AFR) * 2.0);
    engine_weight:=100.0 / 0.002 * (disp - 0.001) + 75.0;
  end Engine2;
  class DriveProfile
    import Modelica.Utilities.*;
    parameter String fname = "C:/works/DARPA_Research/Codes/vehicle_simulation/EPA-highway.txt";
    annotation(experiment(StartTime = 0.0, StopTime = 765.0, Tolerance = 1e-006));
    Real desiredVelocity;
    Modelica.SIunits.Time nextTime(start = 0);
  protected
    String stringData;
    Integer lastLine = Streams.countLines(fname);
    Integer line(start = 0);
    Integer nextIndex;
  algorithm
    if nextTime <= time and line < lastLine then 
        line:=line + 1;
    stringData:=Streams.readLine(fname, line);

    else 
    end if;
    (nextTime,nextIndex):=Strings.scanReal(stringData, 1);
    desiredVelocity:=Strings.scanReal(stringData, nextIndex + 1);
  end DriveProfile;
  model SimEconomy
    parameter Real max_RPM = 6500;
    parameter Real min_RPM = 1000;
    parameter Real min_throttle = 0.07;
    parameter Real max_throttle = 1.0;
    parameter Real stroke = 78.8;
    parameter Real bore = 82.0;
    parameter Real conrod = 115.0;
    constant Real shiftPoint = 10;
    constant Real tol = 0.01;
    DriveProfile epaHwy(fname = "C:/works/DARPA_Research/Codes/vehicle_simulation/EPA-highway.csv");
    VehicleResponse car(stroke = stroke, bore = bore, conrod = conrod);
    VehicleResponse carR1(stroke = stroke, bore = bore, conrod = conrod);
    VehicleResponse carR2(stroke = stroke, bore = bore, conrod = conrod);
    Real commandAccel = 1;
    Integer gear(start = 1);
    Real throttle(start = min_throttle);
    annotation(experiment(StartTime = 0.0, StopTime = 10.0, Tolerance = 1e-006));
  protected
    Real tvel;
    Integer tgear;
    Real accel_min;
    Real accel_max;
  equation
    gear = 2;
    throttle = 0.5;
    car.throttle = throttle;
    car.current_gear = gear;
    carR1.velocity = car.velocity;
    carR1.throttle = min_throttle;
    carR1.current_gear = gear;
    carR2.velocity = car.velocity;
    carR2.throttle = max_throttle;
    carR2.current_gear = gear;
    accel_min = carR1.acceleration;
    accel_max = carR2.acceleration;
  algorithm
    tvel:=pre(car.velocity);
    tgear:=gear;
    if tvel < shiftPoint then 
        tgear:=1;

    else 
    end if;
    when sample(0, 0.01) then
          car.vChassis.velocity:=pre(car.vChassis.velocity) + 0.01 * car.vChassis.acceleration;
    
    end when;
  end SimEconomy;
  model SimAcceleration
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
  model VehicleResponse
    parameter Real stroke = 78.8;
    parameter Real bore = 82.0;
    parameter Real conrod = 115.0;
    parameter Real comp_ratio = 9.3;
    parameter Real spark_angle = -37.0;
    parameter Real n_cyl = 6;
    parameter Real IVO = 11.0;
    parameter Real IVC = 53.0;
    parameter Real L_v = 8.0;
    parameter Real D_v = 41.2;
    parameter Real ratio1 = 3.54;
    parameter Real ratio2 = 2.13;
    parameter Real ratio3 = 1.36;
    parameter Real ratio4 = 1.03;
    parameter Real ratio5 = 0.72;
    parameter Real final_drive_ratio = 2.8;
    parameter Real tire_circumference = 1.905;
    parameter Real mass_vehicle = 1200.0;
    parameter Real Cf = 0.035;
    parameter Real Cd = 0.3;
    parameter Real area = 2.164;
    Real velocity;
    Real throttle;
    Integer current_gear;
    Real RPM;
    Real acceleration;
    Chassis vChassis(mass_vehicle = mass_vehicle, Cf = Cf, Cd = Cd, area = area, tire_circ = tire_circumference);
    Transmission vTrans(ratio1 = ratio1, ratio2 = ratio2, ratio3 = ratio3, ratio4 = ratio4, ratio5 = ratio5, final_drive_ratio = final_drive_ratio, tire_circ = tire_circumference);
    Engine2 vEngine(stroke = stroke, bore = bore, conrod = conrod, comp_ratio = comp_ratio, spark_angle = spark_angle, ncyl = n_cyl, IVO = IVO, IVC = IVC, L_v = L_v, D_v = D_v);
  equation
    vChassis.velocity = 1000 / 60 / 60 * velocity;
    vTrans.velocity = vChassis.velocity;
    vTrans.current_gear = current_gear;
    vChassis.torque_ratio = vTrans.torque_ratio;
    vEngine.throttle = throttle;
    vEngine.RPM = vTrans.RPM;
    vChassis.engine_torque = pre(vEngine.torque);
    vChassis.mass_engine = pre(vEngine.engine_weight);
    RPM = vTrans.RPM;
    acceleration = 60 ^ 4 / 1000 * vChassis.acceleration;
  end VehicleResponse;
  function CarRespFun
    input VehicleResponse carR;
    input Real velocity;
    input Real throttle;
    input Integer gear;
    output Real acceleration;
    output Real RPM;
  algorithm
    carR.velocity:=velocity;
    carR.throttle:=throttle;
    carR.current_gear:=gear;
    acceleration:=carR.acceleration;
    RPM:=carR.RPM;
  end CarRespFun;
  model Vehicle
    parameter Real stroke = 78.8;
    parameter Real bore = 82.0;
    parameter Real conrod = 115.0;
    parameter Real comp_ratio = 9.3;
    parameter Real spark_angle = -37.0;
    parameter Real n_cyl = 6;
    parameter Real IVO = 11.0;
    parameter Real IVC = 53.0;
    parameter Real L_v = 8.0;
    parameter Real D_v = 41.2;
    parameter Real ratio1 = 3.54;
    parameter Real ratio2 = 2.13;
    parameter Real ratio3 = 1.36;
    parameter Real ratio4 = 1.03;
    parameter Real ratio5 = 0.72;
    parameter Real final_drive_ratio = 2.8;
    parameter Real tire_circumference = 1.905;
    parameter Real mass_vehicle = 1200.0;
    parameter Real Cf = 0.035;
    parameter Real Cd = 0.3;
    parameter Real area = 2.164;
    Real velocity;
    Real RPM;
    Real throttle;
    Integer current_gear;
    Real acceleration;
    Chassis vChassis(mass_vehicle = mass_vehicle, Cf = Cf, Cd = Cd, area = area, tire_circ = tire_circumference);
    Transmission vTrans(ratio1 = ratio1, ratio2 = ratio2, ratio3 = ratio3, ratio4 = ratio4, ratio5 = ratio5, final_drive_ratio = final_drive_ratio, tire_circ = tire_circumference);
    Engine vEngine(stroke = stroke, bore = bore, conrod = conrod, comp_ratio = comp_ratio, spark_angle = spark_angle, ncyl = n_cyl, IVO = IVO, IVC = IVC, L_v = L_v, D_v = D_v);
    annotation(experiment(StartTime = 0.0, StopTime = 10.0, Tolerance = 1e-006));
  equation
    vEngine.throttle = throttle;
    vEngine.RPM = vTrans.RPM;
    vChassis.engine_torque = vEngine.torque;
    vChassis.mass_engine = vEngine.engine_weight;
    vTrans.velocity = vChassis.velocity;
    vTrans.current_gear = current_gear;
    vChassis.torque_ratio = vTrans.torque_ratio;
    der(vChassis.velocity) = vChassis.acceleration;
    velocity = (vChassis.velocity * 60 * 60) / 1000;
    acceleration = (vChassis.acceleration * 60 ^ 4) / 1000;
    RPM = vTrans.RPM;
  end Vehicle;
end VehicleDesign;

