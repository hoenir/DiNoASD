clear all
close all
warning off

exp_name = 'dn_or_temp'; %experiment name

%----------------------------------PARAMETERS------------------------------

%Sound signals
sound_button_press = audioplayer(sin(0:.3:1000), 8162);
sound_interval_one = audioplayer(sin(0:.5:1000), 8162);
sound_interval_two = audioplayer(sin(0:.6:1000), 8162);
sound_correct = audioplayer(sin(0:.7:1000), 8162);
sound_wrong = audioplayer(sin(0:.4:1000), 8162);
sound_template = audioplayer(sin(0:.9:1000), 8162);

%Cedrus response box digital input values
cedrus.right = 976;
cedrus.left = 964;
cedrus.up = 961;
cedrus.down = 992;
cedrus.noresponse = 960;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

clc
disp('Welcome to the experiment!');
disp(sprintf('Current experiment: %s', exp_name));
initials = input('Enter your initials:\n','s');
file_name = strcat(exp_name, '_', initials);
cd ../data
load(file_name)
cd ../code
%--------------------------------------------------------------------------
%------------------------VISAGE INITIALIZATION-----------------------------

%Initialise the VSG
disp('Initializing VSG...');
global CRS;
vsgInit;
crsPaletteSet(CRS.greyscale); %Set grayscale palette
%Set pens to draw black strings on a gray background
crsSetPen1(1);
crsSetPen2(128);
BoxType = CRS.respCEDRUS; % The CB6 is the standard 6-button box

disp('VSG initialized.');

Current_FrameRate = crsGetFrameRate;

%Display welcome text
crsSetDrawPage(10);
crsClearPage(10,128);
crsDrawString([0,-100],'***Welkom in het experiment***');
crsDrawString([0,-75],'Je zal telkens TWEE rasters zien, het ene na het andere.');
crsDrawString([0,-50],'Geef aan welk raster het meest TEGEN DE KLOK IN gedraaid is.');
crsDrawString([0,-25],'Druk op de BOVENSTE knop om het EERSTE raster te kiezen.');
crsDrawString([0,0],'Druk op de ONDERSTE knop om het TWEEDE raster te kiezen.');
crsDrawString([0,50],'Druk op een toets om te starten...');
crsSetDisplayPage(10);

%Wait for response box keypress
response = crsIOReadDigitalIn;
while response == cedrus.noresponse
    response = crsIOReadDigitalIn;
end
play(sound_button_press,[1 8162*.05]);
crsClearPage(10,128);

%--------------------------------------------------------------------------

%Define two flags used to signal the end of the experiment
cont = 1; % flag used to signal if subject wants to continue after end of trial block
end_experiment = 0; % flag used to stop experiment when all trials are presented

while cont == 1 & end_experiment == 0 %This is the main experimental block loop

    if length(data_matrix) - trial_number + 1 < block_size
        current_block_size = length(data_matrix) - trial_number + 1;
    else
        current_block_size = block_size;
    end

    %------BEGINNING OF TRIAL BLOCK: PREPARE DRAW PAGES AND PAGE CYCLING-------

    %     current_condition = data_matrix(trial_number, 3); %1 = global, 2 = local

    disp('Preparing draw pages...');

    %fixation cross
    fix = ones(24,24)*.5*256;
    fix(1:24,11:13) = 1;
    fix(11:13,1:24) = 1;

    %---DRAW PAGE 1 : BLANK---
    crsSetDrawPage(1);
    crsClearPage(1,128);
    crsDrawMatrixPalettised(fix);

    %---DRAW PAGE 2 : ISI---
    crsSetDrawPage(2);
    crsClearPage(2,128);

% 
%     %---DRAW PAGE 7 : RESPONSE CUE---
%     crsSetDrawPage(7);
%     crsClearPage(7,128);
%     crsDrawMatrixPalettised(fix);
%     %     square = ones(256,256)*128;
%     %     square(1:256,1:2) = 1;
%     %     square(1:256,255:256) = 1;
%     %     square(1:2,1:256) = 1;
%     %     square(255:256,1:256) = 1;
%     %     crsDrawMatrixPalettised(square);


    crsSetDisplayPage(1);
    pause(.5)

    %-------------------------BEGINNING OF TRIAL BLOCK-------------------------

    for trial = 1 : current_block_size

        current_contrast = data_matrix(trial_number, 3);
        current_ref_or = data_matrix(trial_number, 4);
        current_side = data_matrix(trial_number, 5); %whether compound stimulus is shown left(1) or right(0)
        current_side_nonvert = data_matrix(trial_number, 8); %which stimulus varies

        %create stimuli
        [IM_comp1] = Gabor_Gen_3(param.imsize, param.w_x, param.w_y, param.freq*2.5, param.phase, param.back_lum, 45, param.contrast);
        if current_side_nonvert == 1
            [IM_comp2] = Gabor_Gen_3(param.imsize, param.w_x, param.w_y, param.freq, param.phase, param.back_lum, 0, param.contrast);
            [IM_ref] = Gabor_Gen_3(param.imsize, param.w_x, param.w_y, param.freq, param.phase, param.back_lum, current_ref_or, param.contrast);
        else
            [IM_comp2] = Gabor_Gen_3(param.imsize, param.w_x, param.w_y, param.freq, param.phase, param.back_lum, current_ref_or, param.contrast);
            [IM_ref] = Gabor_Gen_3(param.imsize, param.w_x, param.w_y, param.freq, param.phase, param.back_lum, 0, param.contrast);
        end
        IM_comp1 = min(IM_comp1, 1);
        IM_comp1 = max(IM_comp1, 0);
        IM_comp2 = min(IM_comp2, 1);
        IM_comp2 = max(IM_comp2, 0);
        IM_ref = min(IM_ref, 1);
        IM_ref = max(IM_ref, 0);

        %*******************COPY CURRENT STIMULUS TO DRAW PAGES******************
        if current_side == 1 %COMPOUND FIRST, REFERENCE SECOND (ecc = 0)
            crsSetDrawPage(12);
            crsClearPage(12,128);
            crsDrawMatrixPalettised(fix);
            crsDrawMatrixPalettised([-param.ecc,0],IM_comp1*255+1);
            crsSetDrawPage(14);
            crsClearPage(14,128);
            crsDrawMatrixPalettised(fix);
            crsDrawMatrixPalettised([param.ecc,0],IM_ref*255+1);
            crsSetDrawPage(13);
            crsClearPage(13,128);
            crsDrawMatrixPalettised(fix);
            crsDrawMatrixPalettised([-param.ecc,0], IM_comp2*255+1);
            crsSetDrawPage(15);
            crsClearPage(15,128);
            crsDrawMatrixPalettised(fix);
            crsDrawMatrixPalettised([param.ecc,0],IM_ref*255+1);
        else %COMPOUND SECOND, REFERENCE FIRST (ecc = 0)
            crsSetDrawPage(12);
            crsClearPage(12,128);
            crsDrawMatrixPalettised(fix);
            crsDrawMatrixPalettised([-param.ecc,0],IM_ref*255+1);
            crsSetDrawPage(14);
            crsClearPage(14,128);
            crsDrawMatrixPalettised(fix);
            crsDrawMatrixPalettised([param.ecc,0],IM_comp1*255+1);
            crsSetDrawPage(13);
            crsClearPage(13,128);
            crsDrawMatrixPalettised(fix);
            crsDrawMatrixPalettised([-param.ecc,0], IM_ref*255+1);
            crsSetDrawPage(15);
            crsClearPage(15,128);
            crsDrawMatrixPalettised(fix);
            crsDrawMatrixPalettised([param.ecc,0], IM_comp2*255+1);
        end

        %***********************SET UP PAGE CYCLING****************************

        page_number_vector = [];
        page_time_vector = [];

        %+++Add a blank+++
        page_number_vector = [page_number_vector, 1];
        page_time_vector = [page_time_vector, param.nr_frames_blank];

        %temporal interval 1
        %cycle (to interleave the two components of compound stimulus, for reference it does not matter)
        for cycle_i = 1 : param.nr_frames_stim/2

            %+++Add first component+++
            page_number_vector = [page_number_vector, 12];
            page_time_vector = [page_time_vector, param.nr_frames_interleave];

            %+++Add second component+++
            page_number_vector = [page_number_vector, 13];
            page_time_vector = [page_time_vector, param.nr_frames_interleave];

        end

        %+++Add isi+++
        page_number_vector = [page_number_vector, 2];
        page_time_vector = [page_time_vector, param.nr_frames_isi];

        %temporal interval 2
        %start cycle (to interleave the two components of compound stimulus, for reference it does not matter)
        for cycle_i = 1 : param.nr_frames_stim/2

            %+++Add first component+++
            page_number_vector = [page_number_vector, 14];
            page_time_vector = [page_time_vector, param.nr_frames_interleave];

            %+++Add second component+++
            page_number_vector = [page_number_vector, 15];
            page_time_vector = [page_time_vector, param.nr_frames_interleave];

        end

        %+++Add a blank+++
        page_number_vector = [page_number_vector, 2];
        page_time_vector = [page_time_vector, param.nr_frames_blank];
        
        %+++ Add final blank +++
        page_number_vector = [page_number_vector, 2, 2];
        page_time_vector = [page_time_vector, 2, 2];

        %Page locations
        page_x_locations = zeros(size(page_number_vector));
        page_y_locations = zeros(size(page_number_vector));

        %Halting flags to stop at the end of the cycle
        halting_flags = zeros(size(page_number_vector));
        halting_flags(end) = 1; % halt on the last frame

        %**********************************************************************

        %*************************START PAGE CYCLING***************************

        crsSetCommand(CRS.CYCLEPAGEDISABLE); % Make sure previous page cycling has ended
        crsPageCyclingSetup( page_number_vector, page_x_locations, page_y_locations, page_time_vector, halting_flags );
        crsSetCommand(CRS.CYCLEPAGEENABLE); % start cycling

        pause(0.1)
        while crsGetPageCyclingState ~= -1
        end

        crsSetDisplayPage(1);

        %**********************************************************************

        %********************REGISTER SUBJECTS RESPONSE************************

        %Wait for response box keypress
        response = crsIOReadDigitalIn;
        while (response ~= cedrus.top & response ~= cedrus.bottom)
            response = crsIOReadDigitalIn;
        end

        crsSetDisplayPage(1);

        if response == cedrus.top
            answer = 1;
        elseif response == cedrus.bottom
            answer = 2;
        end

        %**********************************************************************


        %*****************DETERMINE CORRECTNESS OF RESPONSE********************
        if current_side_nonvert == 1 %reference stimulus is the one changing
            if current_side == 1 &  current_ref_or > 0%COMPOUND FIRST, REFERENCE SECOND
                correct = (answer == 1);%correct if first is chosen
            elseif current_side == 1 & current_ref_or < 0%COMPOUND FIRST, REFERENCE SECOND
                correct = (answer == 2);
            elseif current_side == 2 & current_ref_or > 0%COMPOUND SECOND, REFERENCE FIRST
                correct = (answer == 2);
            elseif current_side == 2 & current_ref_or < 0%COMPOUND SECOND, REFERENCE FIRST
                correct = (answer == 1);
            end
        else %compound stimulus is the one changing
            if current_side == 1 &  current_ref_or > 0%COMPOUND FIRST, REFERENCE SECOND
                correct = (answer == 2);%correct if second is chosen
            elseif current_side== 1 & current_ref_or < 0%COMPOUND FIRST, REFERENCE SECOND
                correct = (answer == 1);
            elseif current_side == 2 & current_ref_or > 0%COMPOUND SECOND, REFERENCE FIRST
                correct = (answer == 1);
            elseif current_side == 2 & current_ref_or < 0%COMPOUND SECOND, REFERENCE FIRST
                correct = (answer == 2);
            end
        end
        data_matrix(trial_number, 6) = answer;
        data_matrix(trial_number, 7) = correct;

        if correct == 1
            %play(sound_correct,[1 8162*.2]);
            disp('Subject responded correct.');
        else
            %play(sound_wrong,[1 8162*.2]);
            disp('Subject responded incorrect.');
        end


        %***********************ADVANCE TRIAL NUMBER***************************
        trial_number = trial_number + 1;

        if trial_number > length(data_matrix)
            end_experiment = 1;
        end
        %**********************************************************************

    end

    %-----------------------END OF CURRENT TRIAL BLOCK------------------------

    pause(2)

    disp('End of current trial block.');

    %save current data
    cd('..\data')
    save(file_name, 'data_matrix', 'trial_number', 'block_size', 'nr_trials_per_data_point','param');
    save(['backup_',file_name], 'data_matrix', 'trial_number', 'block_size', 'nr_trials_per_data_point','param');
    cd('..\code')

    disp('Logbook file updated!');

    if end_experiment == 0

        ok_points = trial_number-block_size:trial_number-1;

        prop_stim_second = mean((data_matrix(ok_points,2) == 2));
        prop_chosen_second = mean(data_matrix(ok_points,6) == 2);

        prop_correct = mean(data_matrix(ok_points, 7));
        bias = prop_chosen_second;

        disp(sprintf('PC = %1.2f current block, %1.2f total', prop_correct, mean(data_matrix(1:trial_number-1, 7))));
        disp(sprintf('Bias = %1.2f', mean((data_matrix(ok_points,2) == 2))-bias));

        if bias < .5
            bias_string = 'Druk vaker RECHTS!';
        else
            bias_string = 'Druk vaker LINKS!';
        end

        total_number_of_trials = length(data_matrix);
        percentage_complete = (trial_number-1) / total_number_of_trials *100;

        crsSetCommand(CRS.CYCLEPAGEDISABLE); %Make sure previous page cycling has ended
        crsSetDrawPage(10);
        crsClearPage(10,128);
        crsDrawString([0,-200],'***Einde van het huidige trialblok***');
        crsDrawString([0,-50],sprintf('Je hebt reeds %2.1f%% van het experiment voltooid.',percentage_complete));
        crsDrawString([0, 0],sprintf('In dit blok bedroeg je percentage correct %3.0f%%.',prop_correct*100));
        %crsDrawString([0, 50],sprintf('In dit blok bedroeg je bias %3.0f%%.',abs(mean((data_matrix(ok_points,2) == 2))-bias)*100));
        %crsDrawString([0,100],sprintf('%s',bias_string));
        crsDrawString([0,200],'Druk BOVEN als je wil stoppen') ;
        crsDrawString([0,250],'Druk ONDER als je een nieuw trialblok wil starten');
        crsSetDisplayPage(10);
        pause(2);
        tic

        %Wait for response box keypress
        response = crsIOReadDigitalIn;
        while  response == cedrus.noresponse
            response = crsIOReadDigitalIn;
            if toc > 120
                crsSetDisplayPage(1);
            end
        end


        play(sound_button_press,[1 8162*.05]);

        if response == cedrus.bottom;
            cont = 1;
            disp('Starting new trialblock...');
        else
            cont = 0;
            disp('Shutting down the experiment...');
            crsSetDrawPage(10);
            crsClearPage(10,128);
            crsDrawString([0,0],'Bedankt voor je deelname!');
            crsSetDisplayPage(10);
            pause(3)
        end

    else
        cont = 0;
        crsSetDrawPage(10);
        crsClearPage(10,127);
        crsDrawString([0,-50],'Je hebt het experiment voltooid!');
        crsDrawString([0,0],'Bedankt voor je deelname!');
        crsSetDisplayPage(10);
        pause(3)
        disp('Shutting down the experiment...');
    end

end

vsginit;


