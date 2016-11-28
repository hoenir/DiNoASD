clear all
close all
warning off
% addpath C:\Users\u0052447\Documents\MATLAB\psignifit
subjects = {'SVdC'};
figure(1)
exp_name = 'dn_or_temp';
%**************************************************************************
for subject_index =  1 : length(subjects)
    cd ..
    cd data
    load([exp_name '_' subjects{subject_index} '.mat']);%check file name
    data_matrix = data_matrix(1:trial_number-1,:);
    cd ..

or_vector = unique(data_matrix(:,4)); % bij ons niet contrast, maar oriëntatie

for cond_i = 1 : 2 %dit zijn de condities waarvoor je aparte psychometrische curves meet (bij ons “current_side_nonvert” 8e kolom ook bij ons denk ik?)
    if cond_i == 1
        data_matrix(:,9) = (data_matrix(:,5) ~= data_matrix(:,6)); %data_matrix(:,5)duidt aan welke kant compound werd getoond, kolom 6 is de respons
        % kolom 9 bijmaken die zegt wanneer reference gekozen als current_side_nonvert == 1 (cond_i == 1)
    else
        data_matrix(:,9) = (data_matrix(:,5) == data_matrix(:,6));
        % kolom 9 bijmaken die zegt wanneer compound gekozen als current_side_nonvert == 2 (cond_i == 2)
    end
    
    for or_i = 1 : length(or_vector)
        
        perf_matrix(or_i, cond_i) = mean(data_matrix(data_matrix(:,8) == cond_i & data_matrix(:,4) == or_vector(or_i),9)); %gemiddeld compound/refence gekozen
        trial_number_matrix(or_i, cond_i) = length(find(data_matrix(:,8) == cond_i & data_matrix(:,4) == or_vector(or_i)));
    end
    DAT(:, 1) = or_vector; % bij ons niet contrast, maar oriëntatie (log en *1000 is dan niet nodig normaal)
    DAT(:, 2) = perf_matrix(:,cond_i);
    DAT(:, 3) = trial_number_matrix(:,cond_i);
    
    [results_struct, sim_results_struct] = pfit(DAT, 'plot', 'shape','cumulative gaussian', 'sens',0, 'runs', 10000, 'verbose', 0, 'n_intervals',1);
    hold on;
    pfit_results_struct(cond_i) = results_struct;
    pfit_sim_results_struct(cond_i) = sim_results_struct;
    data_struct(cond_i).data = DAT;
    sim_lambda_matrix(cond_i,:) = sim_results_struct.params.sim(:, 4);%de parameter van de curve die je specifiek wil testen, bij ons waarschijnlijk de threshold alpha (2e kolom)
    sim_alpha_matrix(cond_i,:) = sim_results_struct.params.sim(:, 1);%de parameter van de curve die je specifiek wil testen, bij ons waarschijnlijk de threshold alpha (2e kolom)

    if (results_struct.stats.deviance.cpe > 0.95)
        disp(sprintf('subject %d: fit REJECTED (p=%6.4f)', subject_index, 1-results_struct.stats.deviance.cpe));
    else
        disp(sprintf('subject %d: fit accepted (p=%6.4f)', subject_index, 1-results_struct.stats.deviance.cpe));
    end
    
end %condities doorlopen
end
cd data
% save(strcat('pfit_dn_or_',subjects{subject_index},'.mat'), 'data_struct', 'pfit_results_struct', 'pfit_sim_results_struct');
cd ..
 
%vergelijking van condities (1 en 2 hier): p values op basis van parametric bootstrap op releavnte parameters (alpha ipv lambda in ons geval denk ik?)
p_lambda = length(find(sim_lambda_matrix(2,:)-sim_lambda_matrix(1,:)<0))/sim_results_struct.R;
p_alpha = length(find(sim_alpha_matrix(2,:)-sim_alpha_matrix(1,:)<0))/sim_results_struct.R;

 
