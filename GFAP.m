function GFAP (d, g, prediction)
% Is a function to make de diagnosis and grading of tumours in the glial cells
% stained with GFAP technique.

% INPUT:
% @prediction: table with the data that needs to be diagnosticated and
% graded and the information about the individual ID. The individual ID must 
% be a number. The headers are: 
% individual	tissue	Hpdens	Gndens	Gpdens	GN.GP	GN.HP	GP.HP 
% @d: struct with the trained GFAPdiagnosis function to predict the
% presence or absence or tumour.
% @g: struct with the trained GFAPgrading function to predict the tumour
% degree.


% OUTPUT:
% @diagnosis: table with the diagnosis and grading for each subimage. 
% Individual ID is tracked. The headers are: individual diagnosis grading
% @results: table with the counts for healthy, intermediate degree tumour
% and high degree tumour.

%%
% % Train the program:
% d = GFAPdiagnosis(Dtraining);
% g = GFAPgrading(Gtraining);
% 
% d.RequiredVariables
% 
% g.RequiredVariables

%% Input the data from each patient/individual:
[lines, cols] = size (prediction);

%% Separing each individual
last = prediction(lines,1); %Number of individuals is the same as the last ID
IDnum = table2array(last);

%% Preparing the data for output
C = [];
R = [];

%% Operations
healthyCount = 0;
interCount = 0;
highCount = 0;
ID = 1;
%% Counts
for i = 1:lines 
    individual = prediction{i,1};
    if individual == ID        % TRUE means the same individual
        diagnosis = (d.predictFcn(prediction (i,3:6)));
        if strcmp (diagnosis , 'tumour')
            grading = (g.predictFcn(prediction(i,3:6)));

            if strcmp (grading, 'HIGH')
                highCount = highCount + 1;
            else
                interCount = interCount + 1;
            end
        else
            grading = 'healthy';
            healthyCount = healthyCount + 1;
        end
    C{i, 1} = individual;
    C{i, 2} = diagnosis;
    C{i, 3} = grading;
    else %This means a change of individual
        
        %Copy the data from the individual before
        R{ID, 1} = ID;
        R{ID, 2} = healthyCount;
        R{ID, 3} = interCount;
        R{ID, 4} = highCount;
        
        %Prepare for counting the new individual
        healthyCount = 0;
        interCount = 0;
        highCount = 0;
        ID = ID+1;
        
        %Counting the line i
        diagnosis = (d.predictFcn(prediction (i,3:6)));
        if strcmp (diagnosis , 'tumour')
            grading = (g.predictFcn(prediction(i,3:6)));

            if strcmp (grading, 'HIGH')
                highCount = highCount + 1;
            else
                interCount = interCount + 1;
            end
        else
            grading = 'healthy';
            healthyCount = healthyCount + 1;
        end
    end
    
    %Copy the counts
    C{i, 1} = individual;
    C{i, 2} = diagnosis;
    C{i, 3} = grading;  

    %Copy the last individual
    R{ID, 1} = ID;
    R{ID, 2} = healthyCount;
    R{ID, 3} = interCount;
    R{ID, 4} = highCount;
        
end
T = cell2table(C);
T.Properties.VariableNames = {'individual', 'diagnosis', 'grading'};
writetable (T, 'diagnosis.csv'); 

%% Results
    
D = cell2table(R);
D.Properties.VariableNames = {'ID', 'Health', 'Intermediate', 'High'};
writetable(D, 'results.csv');

