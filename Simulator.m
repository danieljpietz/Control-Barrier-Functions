classdef Simulator
    
    properties
        Vehicles
        Lanes
        lanes
    end
    
    methods
        function obj = Simulator(vehicles)
            obj.Vehicles = vehicles;
            %obj.Lane = cell(length(obj.Vehicles), 3);
            for i = 1:length(obj.Vehicles)
                %vehicle = obj.Vehicles{i};
                obj.Vehicles{i}.id = i;
                %obj.Lane(i,:) = {vehicle, vehicle.p, i};
            end
        end
        
        function vehicle = getLeadVehicle(obj, v, dir)
            p = v.p;
            lane = v.Lane;
            newlane = lane + dir;
            
            if dir > 0
                dirFunc = @max;
            elseif dir < 0
                dirFunc = @min;
            else
                dirFunc = @ (x) 0;
            end
            if lane == dirFunc(obj.lanes)
                vehicle = nan;
                return;
            end
            
            newLane = obj.Lanes(find(obj.lanes == newlane));
            if length(newLane) == 0
                vehicle = nan;
                return;
            end
            newLane = newLane{1};
            
            if newLane{1,2} < p
                vehicle = nan;
                return;
            end
            
            for i = 2:size(newLane,1)
                if newLane{i,2} < p
                    vehicle = newLane{i - 1,1};
                    return
                end
            end
            vehicle = newLane{end, 1};
        end
        
        function obj = tick(obj, h)
            obj.lanes = zeros(1, length(obj.Vehicles));
            
            for i = 1:length(obj.Vehicles)
                obj.lanes(i) = obj.Vehicles{i}.Lane;
            end
            obj.lanes = sort(unique(obj.lanes));
            obj.Lanes = cell(1, length(obj.lanes));
            for i = 1:length(obj.lanes)
                lane = obj.lanes(i);
                Lane = cell(0, 3);
                
                for j = 1:length(obj.Vehicles)
                    if obj.Vehicles{j}.Lane == lane
                        Lane(end+1,:) = {obj.Vehicles{j}, obj.Vehicles{j}.p, j};
                    end
                end
                obj.Lanes(i) = {sortrows(Lane, 2, 'descend')};
            end
            
            for j = 1:length(obj.lanes)
                Lane = obj.Lanes{j};
                Lane{1,1}.LeadCar = nan;
                Lane{1,1}.LeadCarRight = obj.getLeadVehicle(Lane{1,1}, 1);
                Lane{1,1}.LeadCarLeft = obj.getLeadVehicle(Lane{1,1}, -1);
                for i = 2:size(Lane, 1)
                    Lane{i,1}.LeadCar = Lane{i-1,1};
                    Lane{i,1}.LeadCarRight = obj.getLeadVehicle(Lane{i,1}, 1);
                    Lane{i,1}.LeadCarLeft = obj.getLeadVehicle(Lane{i,1}, -1);
                end
                for i = 1:size(Lane, 1)
                    obj.Vehicles{Lane{i,1}.id} = Lane{i,1}.tick(h);
                end
            end
            
        end
        
        function V = get_vehicle(obj, i)
            for j = 1:length(obj.Vehicles)
                if obj.Vehicles{j}.id == i
                    V = obj.Vehicles{j};
                    break;
                end
            end
        end
    end
end

