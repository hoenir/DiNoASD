clear all
close all
warning off

%indicate experiment
exp_name = 'dn_or_temp'; %experiment name

%-----------------------------PARAMETERS-----------------------------------
block_size = 50;
nr_trials_per_data_point = 50%per contrast level

%presentation time
time_blank = 500;
time_stim = 200;
time_isi = 800;

%calculate the number of frames (1 frame 1/130 * 1000 = 7.7 ms)
Current_FrameRate = 118;
param.nr_frames_blank = round(time_blank/1000*Current_FrameRate);
param.nr_frames_stim = round(time_stim/1000*Current_FrameRate);
param.nr_frames_isi = round(time_isi/1000*Current_FrameRate);
param.nr_frames_interleave = 1;

%stimulus properties
param.pixel_size = 0.3300; %crspixelsToMM(1);
param.viewing_distance = 600;
param.pixel_size_degrees = atan(param.pixel_size/param.viewing_distance)*180/pi;

%parameters Gabors
param.imsize = 7*1.5/param.pixel_size_degrees;
param.w_x = 7*0.25/param.pixel_size_degrees;
param.w_y = 7*0.25/param.pixel_size_degrees;
param.freq = 1.5*param.pixel_size_degrees; 
param.phase = 0;
param.back_lum = 0.5;
param.contrast = 1;
param.ecc = 0/param.pixel_size_degrees;%8
param.or = 0; 

%conditions
%within blocks
contrast_vector = 1;%not of interest
or_vector = linspace(-3,3,6);%manipulation of orientation in second component of compound stimulus
side_vector = [1 2];%whether compound stimulus is shown left(1) or right(0)

%between blocks
cond_vector = [1 2];%whether compound varies in orientation or reference

%--------------------------------------------------------------------------

clc
disp('Welcome to the logbook file creator!');
disp(sprintf('Current experiment: %s', exp_name));
initials = input('Enter your initials:\n','s');
file_name = strcat(exp_name, '_', initials);

%--------------------------------------------------------------------------
nr_trials_per_cond = length(or_vector)*length(side_vector)*length(contrast_vector)*nr_trials_per_data_point;
nr_blocks_per_cond = nr_trials_per_cond/block_size;
total_number_trials = nr_trials_per_cond * length(cond_vector)

block_vector = repmat(cond_vector, 1, nr_blocks_per_cond);
% block_vector = shuffle(block_vector); %enable this to shuffle block sequence
block_matrix = repmat(block_vector, block_size, 1);

data_matrix = zeros(total_number_trials, 15);

for cond_i = 1 : length(cond_vector)

    contrast_trials = repmat(contrast_vector, 1, length(or_vector) * length(side_vector) * nr_trials_per_data_point);
    contrast_trials = contrast_trials';
    or_trials = repmat(or_vector, length(contrast_vector) * length(side_vector), 1);
    or_trials = or_trials(:);
    or_trials = repmat(or_trials,nr_trials_per_data_point,1);
    side_trials = repmat(side_vector, length(contrast_vector), 1);
    side_trials = side_trials(:);
    side_trials = repmat(side_trials, 1, length(or_vector));
    side_trials = side_trials(:);
    side_trials = repmat(side_trials,nr_trials_per_data_point,1);
    
    which_blocks = (block_matrix==cond_vector(cond_i));
    contrast_trial_matrix(which_blocks(:)) = contrast_trials;
    or_trial_matrix(which_blocks(:)) = or_trials;
    side_trial_matrix(which_blocks(:)) = side_trials;
    
end


data_matrix(:,2) = shuffle(repmat([1, 2], 1, total_number_trials/2));
data_matrix(:,3) = contrast_trial_matrix(:);
data_matrix(:,4) = or_trial_matrix(:);
data_matrix(:,5) = side_trial_matrix(:);
data_matrix(:,8) = block_matrix(:);

data_matrix = shuffle(data_matrix,1); %enable this to shuffle all trials (not blocked)
data_matrix(:,1) = 1 : total_number_trials;
%--------------------------------------------------------------------------

trial_number = 1;

cd('..\data')
save(file_name, 'data_matrix', 'trial_number', 'block_size', 'nr_trials_per_data_point','param');
cd('..\code')

disp('Logbook file created.');
