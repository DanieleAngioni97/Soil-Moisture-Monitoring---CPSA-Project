channelID = 1429676; 

readAPIKey = 'TBIGZEK1GKWDEA82';
writeAPIKey = 'WPCX76VZK3J0F0FI';

voltage_field = 1;
soilmoisture_field = 2;
sand_field = 3;
clay_field = 4;
loam_field = 5;


[data,time] = thingSpeakRead(channelID,'Fields',[voltage_field,soilmoisture_field,sand_field,clay_field,loam_field],'NumPoints', 1000)

perc = data(:,3:5)
idxs = not(isnan(perc))

sand_perc = perc(idxs(:,1),1)
clay_perc = perc(idxs(:,2),2)
loam_perc = perc(idxs(:,3),3)

last_hums = data(:,2)

vin = data(end,1)

% if total is not 1 rescale all values to sum up to 1
tot = (sand_perc(end)+clay_perc(end)+loam_perc(end))
sand_perc = sand_perc(end)/tot
clay_perc = clay_perc(end)/tot
loam_perc = loam_perc(end)/tot


if not(isnan(vin))

    mv = [2800 2700 2600 2500 2400 2300 2200 2100 2000 1900 1800 1700 1600 1500 1400];
    hum_curve_sand = [0 1 3 5 9 12 15 20 25 30 40 50 60 80 100];
    hum_curve_clay = hum_curve_sand*0.9;
    hum_curve_loam = hum_curve_sand*1.1;
    
    if vin >= mv(1)
        vin = mv(1);
    end
    if vin <= mv(end)
        vin = mv(end);
    end
    
    hum_sand = interp1(mv,hum_curve_sand,vin)
    hum_clay = interp1(mv,hum_curve_clay,vin)
    hum_loam = interp1(mv,hum_curve_loam,vin)
    
    hum = hum_sand*sand_perc + hum_clay*clay_perc + hum_loam*loam_perc
   
    response = thingSpeakWrite(...
    channelID, [hum,sand_perc*100,clay_perc*100,loam_perc*100],...
    'WriteKey',writeAPIKey,...
    'Fields',[soilmoisture_field,sand_field,clay_field,loam_field]);
    
    response    
     
end


