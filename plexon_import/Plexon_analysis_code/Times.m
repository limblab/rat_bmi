





filename = 'A2_20160408_times';
times(1).range = [0 30]; times(1).type = 'chewing';
times(2).range = [40 55]; times(2).type = 'rearing';
times(3).range = [(4*60+55) (5*60+17)]; times(3).type = 'treadmill slow';
times(4).range = [(5*60+32) (5*60+45)]; times(4).type = 'treadmill fast';
times(5).range = [(6*60+57) (7*60+10)]; times(5).type = 'treadmill 15 deg slow';
times(6).range = [(7*60+20) (7*60+34)]; times(6).type = 'treadmill 15 deg fast';
times(7).range = [(9*60+4) (9*60+20)]; times(7).type = 'treadmill -5 deg slow';
times(8).range = [(9*60+30) (9*60+40)]; times(8).type = 'treadmill -5 deg fast';
save(filename,'times');

clear times;


filename = 'A3_20160408_times';
times(1).range = [16 36]; times(1).type = 'resting';
times(2).range = [40 45]; times(2).type = 'rearing';
times(3).range = [(1*60+40) (2*60+10)]; times(3).type = 'treadmill slow';
times(4).range = [(2*60+22) (2*60+45)]; times(4).type = 'treadmill fast';
times(5).range = [(5*60+4) (5*60+22)]; times(5).type = 'treadmill 10 deg slow';
times(6).range = [(5*60+30) (5*60+40)]; times(6).type = 'treadmill 10 deg fast';
times(7).range = [(7*60+10) (7*60+24)]; times(7).type = 'treadmill -5 deg slow';
times(8).range = [(7*60+40) (7*60+46)]; times(8).type = 'treadmill -5 deg med';
times(9).range = [(7*60+54) (8*60+10)]; times(9).type = 'treadmill -5 deg fast';
save(filename,'times');

clear times;

filename = 'A3_20160414_times';
times(1).range = []; times(1).type = '';
save(filename,'times');

clear times;
