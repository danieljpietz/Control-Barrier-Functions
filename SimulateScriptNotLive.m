clear all
close all
clc


car1 = Vehicle([50, 2.5], -1);
car2 = Vehicle([50, 2.5], 0);
car3 = Vehicle([50, 2.5], 1);
car4 = Vehicle([0, 0], 0);

car1.vd = 4;
car2.vd = 5;
car3.vd = 6;
Vehicles = {car1, car2, car3, car4};

s = Simulator(Vehicles);

h = 0.1;

t = 0:h:25;


x1 = zeros(length(Vehicles),length(t));
x2 = x1;
x3 = x1;
x4 = x1;
x5 = x1;
for i = 1:length(t)
    
%     if t(i) == 5
%         v = s.get_vehicle(2);
%         v.Lane = 0;
%         v.vd = 0;
%         s.Vehicles(2) = {v};
%     end
%     
%     if t(i) == 15
%         v = s.get_vehicle(2);
%         v.Lane = 1;
%         v.vd = 0;
%         s.Vehicles(2) = {v};
%     end
    
    s = s.tick(h);    
    for j = 1:length(Vehicles)
        v = s.get_vehicle(j);
        x1(j, i) = v.p;
        x2(j,i) = v.v;
        x3(j,i) = v.z;
        x4(j,i) = v.F;
        x5(j,i) = v.Lane;
    end
    
end

cmap = jet(length(Vehicles));

figure, 
plot(t, x1, 'LineWidth', 3)
title('Vehicle Position')
figure, 
plot(t, x2, 'LineWidth', 3)
title('Vehicle Velocity')
figure,
plot(t, x3./x2, 'LineWidth', 3)
title('Vehicle Time to Collision')
figure,
plot(t, x4, 'LineWidth', 3)
title('Vehicle Control input')


input('Press enter to animate')
figure,

rangeY = [min(x1, [], 'all'), max(x1, [], 'all')];
rangeX = [min(x5, [], 'all'), max(x5, [], 'all')];

for i = 1:2:length(t)
    scatter(x5(:,i), x1(:,i), 150, cmap, 'Filled')
    set(gca,'Color',[0.25, 0.25, 0.25])
    ylim(rangeY)
    xlim([-2, 2])
    pause(h)
end

