close all
clear
format long

% simulation parameters
D0 = 1e-18;
D = (D0:2.5*D0:198.5*D0);%%range of diffusivity values.
TOTAL_NUMBER_0F_D = numel(D);
initial_gamma = 1;
final_gamma = 16;
step_size = 0.2;
%number of sweeps per concentration.
number_of_sweeps_per_concentration=((final_gamma - initial_gamma)/step_size)+1;
TOTAL_NUMBER_0F_GAMMAS=number_of_sweeps_per_concentration;

% Experimental data
Experimental_Data=zeros(4,8);
Experimental_Data(1,:) = [0 4.9 8.0 12.0 14.7 18.1 20.4 22.0]*1/100;%0.01% data
Experimental_Data(2,:) = [0 7.6 13.7 17.8 20.8 26.1 28.6 30.6]*1/100;%0.025% data
Experimental_Data(3,:) = [0.5 6.1 10.2 15.3 18.7 24.3 28.4 32.1]*1/100;%0.05% data
Experimental_Data(4,:) = [0.7 10.7 17.8 26 32.6 38.2 44.1 48.4]*1/100;%0.1%data
t = [0 1 2 5 7 14 20 28];%experimental release times observed
number_of_observed_times_experiment = numel(t);
% residual_THIS_Gamma_THIS_Concentration_SUM = 0;
%type of diffusivity profile.
function_type = 'exp3';

% Extract simulation results.
dir_location = '/home/phemykadri/Desktop/COMSOL5_1/param_D_exp3';% directory containing simulation results
file_format = '*.txt';%result format.
dim = strcat(dir_location,'/',file_format);%extract result files only.
all_concentration = dir(dim);%listing of simulation results for all concentrations

%loop over comsol solution for each concentration
start = 1;
for this_concentration = start:size(all_concentration,1)
    
    %read each concentration data into an array.
    this_concentration_data(:,:,this_concentration) = ...
        load(strcat(dir_location,'/',all_concentration(this_concentration).name));
    
end%this_concentration_data = 1:size(each_concentration_data,1)
% this_concentration_data(:,:,1:2)=[];%remove all zeros.
all_dim = size(this_concentration_data);

%swap time and concentration data in array to make concentration last column.
last = 4;%last column originally representing concentration.
temp1=this_concentration_data(:,last,:);temp2=this_concentration_data(:,last-1,:);

this_concentration_data(:,last,:) = temp2;this_concentration_data(:,last-1,:) = temp1;

number_of_values_all_D_all_gamma_per_concentration=size(this_concentration_data,1);

number_of_values_each_D_each_gamma_per_concentration=...
    size(this_concentration_data,1)/TOTAL_NUMBER_0F_D;

number_of_time_steps_experiment = numel(t);

% scenario = input('Enter number: ');

scenario = 4;%with scenario equal to 4,residual is calculated with all concentrations.

% concentration data.with scenario equal 2,residual is calculated without 0.025%.
% any other value for scenario calculates using all four concentration data.
 switch scenario
     
    case 1%compute residual without 0.05% concentration
        
        Experimental_Data(3,:)=[];%remove exp data for 0.05% concentration
        this_concentration_data(:,:,3)=[];%remove comsol result for 0.05% concentration
        
    case 2%computes residual without 0.025% concentration
        
        Experimental_Data(2,:)=[];%remove exp data for 0.025% concentration
        this_concentration_data(:,:,2)=[];%remove comsol result for 0.025% concentration
        
    case 3%computes without 0.025% and 0.01% concentrations 
        
        Experimental_Data(2:3,:)=[];%remove exp data for 0.025% and 0.05% concentration
        this_concentration_data(:,:,2:3)=[];%remove comsol result for 0.025% and 0.05% concentration
        
 end%switch.

 fileID = fopen(['results' num2str(scenario) function_type '.txt'],'w');
 
%loop over comsol solution for each concentration,gamma and diffusivity.
for THIS_D_Number = 1:TOTAL_NUMBER_0F_D
     
    for THIS_GAMMA_Number = 1:TOTAL_NUMBER_0F_GAMMAS
 
        residual_SUM_THIS_D_THIS_Gamma_ALL_Concentration = 0;
        
        for this_concentration = 1:size(this_concentration_data,3)
          
            residual_THIS_D_THIS_Gamma_THIS_Concentration_SUM = 0;
            
            THIS_D_ALL_gamma_data_THIS_Concentration(:,:,THIS_D_Number,this_concentration) = ...
             this_concentration_data(1+round((THIS_D_Number-1)*...
                number_of_values_each_D_each_gamma_per_concentration)...
                :round(THIS_D_Number*number_of_values_each_D_each_gamma_per_concentration),:,...
                this_concentration);   
                        
            THIS_D_THIS_concentration_THIS_gamma_data(:,:,THIS_D_Number,this_concentration) = ...
                THIS_D_ALL_gamma_data_THIS_Concentration(1+round((THIS_GAMMA_Number-1)*...
                 number_of_values_each_D_each_gamma_per_concentration/ ...
                TOTAL_NUMBER_0F_GAMMAS):round(THIS_GAMMA_Number/TOTAL_NUMBER_0F_GAMMAS*...
                number_of_values_each_D_each_gamma_per_concentration),:,THIS_D_Number,this_concentration);

            THIS_D_THIS_Gamma_Dataset = THIS_D_THIS_concentration_THIS_gamma_data(:,:,THIS_D_Number,this_concentration);
% %             THIS_D_THIS_Gamma_Dataset(1,:)=[];
            %loop over each experiment time
% %             for THIS_time_step_number = 2:number_of_time_steps_experiment
            for THIS_time_step_number = 2:number_of_time_steps_experiment
                %obtain residuals 
                residual_THIS_D_THIS_Gamma_THIS_Concentration = (( THIS_D_THIS_Gamma_Dataset((THIS_time_step_number),3 ) - ...
                    Experimental_Data(this_concentration,THIS_time_step_number) ) ^ 2); 
                
%                 residual_THIS_D_THIS_Gamma_THIS_Concentration=...
%                     residual_THIS_D_THIS_Gamma_THIS_Concentration/...
%                     Experimental_Data(this_concentration,THIS_time_step_number);
                    
                residual_THIS_D_THIS_Gamma_THIS_Concentration_SUM = ...
                    residual_THIS_D_THIS_Gamma_THIS_Concentration_SUM + residual_THIS_D_THIS_Gamma_THIS_Concentration;

            end %THIS_time_step_number = 2:numel(t)  
            
            residual_SUM_THIS_D_THIS_gamma_THIS_concentration_ARRAY(THIS_GAMMA_Number,...
                this_concentration,THIS_D_Number) =residual_THIS_D_THIS_Gamma_THIS_Concentration_SUM;  
            
            residual_SUM_THIS_D_THIS_gamma_THIS_concentration_ARRAY_ALT(THIS_GAMMA_Number,...
                THIS_D_Number,this_concentration) =residual_THIS_D_THIS_Gamma_THIS_Concentration_SUM; 

            residual_SUM_THIS_D_THIS_Gamma_ALL_Concentration = ...
                residual_SUM_THIS_D_THIS_Gamma_ALL_Concentration + residual_THIS_D_THIS_Gamma_THIS_Concentration_SUM;

        end%this_concentration = 1:size(this_concentration_data,3)
        
        residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY(THIS_GAMMA_Number,THIS_D_Number) = ...
            residual_SUM_THIS_D_THIS_Gamma_ALL_Concentration;

        ALL_GAMMA_VALUES(THIS_GAMMA_Number) = initial_gamma + (THIS_GAMMA_Number - 1)*step_size;
       
    end %THIS_GAMMA_Number = 1:TOTAL_NUMBER_0F_GAMMAS
       
end%THIS_D_Number = 1:TOTAL_NUMBER_0F_D

% obtain overall best D and gamma values
min_res = min(residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY(:));

[minloc1,minloc2] = ind2sub(size(residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY),...
    find(residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY==min_res));

Best_gamma_location_overall = minloc1;

Best_D_location_overall = minloc2;

Best_gamma_overall = ALL_GAMMA_VALUES(Best_gamma_location_overall);

fprintf(fileID,'%s\n','best gamma overall');
fprintf(fileID,'%6.2f\n',Best_gamma_overall);

Best_D_overall = D(Best_D_location_overall);

fprintf(fileID,'%s\n','best D overall');
fprintf(fileID,'%1e\n',Best_D_overall);
% fprintf(fileID,'%s %s\n','best_gamma_overall','best D overall');
% fprintf(fileID,'%1.2f %1e\n',Best_gamma_overall,Best_D_overall);

residual_TOTAL_SUM_BEST_Gamma = ...
    residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY(Best_gamma_location_overall,Best_D_location_overall);

% obtain best D and gamma value for each experimental concentration
%obtain minimum for each concentration and value of D.
minval_each_D_each_concentration = ...
    min(residual_SUM_THIS_D_THIS_gamma_THIS_concentration_ARRAY,[],1);

minval_all_D_each_concentration = min(minval_each_D_each_concentration,[],3);

indices = [];

%this loop finds the gamma and diffusivity indices giving the lowest sum of
% residual for each experimental concentration.
for this_D_minimum = 1:numel(minval_all_D_each_concentration)
    
    [gamma_index,concentration_index,diffusivity_index] = ...
        ind2sub(size(residual_SUM_THIS_D_THIS_gamma_THIS_concentration_ARRAY),...
    find( residual_SUM_THIS_D_THIS_gamma_THIS_concentration_ARRAY== ...
                        minval_all_D_each_concentration(this_D_minimum)));
                    
    indices = [indices;gamma_index,concentration_index,diffusivity_index];
    
end%this_D_minimum = 1:numel(minval_all_D_each_concentration)

% obtain best actual gamma values for each experimental concentration.
for this_concentration_index = 1:size(this_concentration_data,3)
    
    best_gamma_each_concentration_index...
        = indices(this_concentration_index,1);
    
    best_gamma_each_concentration_ARRAY(this_concentration_index) = ...
        ALL_GAMMA_VALUES(best_gamma_each_concentration_index);
    
    best_diffusivity_each_concentration_index...
        = indices(this_concentration_index,3);
    
    best_diffusivity_each_concentration_ARRAY(this_concentration_index) = ...
        D(best_diffusivity_each_concentration_index);
    
    figure,...
        surf(D,ALL_GAMMA_VALUES,...
        residual_SUM_THIS_D_THIS_gamma_THIS_concentration_ARRAY_ALT(:,:,this_concentration_index))
    
    colorbar
    
    pause(0.5)
    
end%this_concentration_index = 1:size(this_concentration_data,3)

fprintf(fileID,'%s\n','best gamma each concentration');
fprintf(fileID,'%6.2f\n',best_gamma_each_concentration_ARRAY);
fprintf(fileID,'%s\n','best D each concentration');
fprintf(fileID,'%1e\n',best_diffusivity_each_concentration_ARRAY);
fprintf(fileID,'%s\n','sum of residuals best D and gamma each concentration');
fprintf(fileID,'%1e\n',minval_all_D_each_concentration);
fprintf(fileID,'%s\n','sum of residuals best D and gamma all concentrations');
fprintf(fileID,'%1e\n',residual_TOTAL_SUM_BEST_Gamma);
fclose(fileID);

% caxis([min(residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY(:)) 0.151])
% figure,surf(D,ALL_GAMMA_VALUES,residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY)
figure
colormap hsv
surf(D,ALL_GAMMA_VALUES,residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY,'FaceColor','interp',...
   'EdgeColor','none',...
   'FaceLighting','gouraud')
% daspect([5 5 1])
axis tight
% view(-50,30)
% camlight left
% a = sort(residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY(:));a1 = a(a<=1);
% figure,contour(D,ALL_GAMMA_VALUES,residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY,a1)
zlim([-2 max(residual_SUM_THIS_D_THIS_GAMMA_ALL_concentration_ARRAY(:))])
% set(gca,'ZScale','log')
colorbar

% imshow(X,[])
%     imhist(X,256)
% %     [~,kmeans_mask]=kmeans_ima(X,3);
% %     kmeans_thresh = multithresh(kmeans_mask,2);
% %     seg_mas = imquantize(kmeans_mask,kmeans_thresh);
% %     level_of_interest = 3;
% %     seg_mas(seg_mas~=level_of_interest)=false;
% %     seg_mas(seg_mas==level_of_interest)=true;
% %     BW=logical(seg_mas);
% %     BW2 = bwareafilt(BW,1);
%     CC(ii) = bwconncomp(BW);
