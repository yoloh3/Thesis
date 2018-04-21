% Huy-Hung Ho

% Set parameters
fraction = 10;
num_of_test = 100;

% Write weights to file
file_i = fopen('../tb/input.bin','w');
file_b = fopen('../tb/bias.bin', 'w');
file_w = fopen('../tb/weight.bin','w');

for i = 1:numel(nn.layers{1, 1}.x(:,1))
    value = nn.layers{1, 1}.x(i, 1);
    fprintf(file_i, '%f\n', value);
end
fclose(file_i);

for i = 1:numel(nn.layers{1, 1}.b)
    value = nn.layers{1, 1}.b(i);
    fprintf(file_b, '%f\n', value);
end
for i = 1:numel(nn.layers{1, 3}.b)
    value = nn.layers{1, 3}.b(i);
    fprintf(file_b, '%f\n', value);
end
fclose(file_b);

ram_w_tmp1 = nn.layers{1, 1}.W';
for i = 1:numel(nn.layers{1, 1}.W)
    value = ram_w_tmp1(i);
    fprintf(file_w, '%f\n', value);
end
ram_w_tmp2 = nn.layers{1, 3}.W';
for i = 1:numel(nn.layers{1, 3}.W)
    value = ram_w_tmp2(i);
    fprintf(file_w, '%f\n', value);
end
fclose(file_w);


% Forward ANN
inputVector = nn.layers{1, 1}.x(:,1);
hiddenWeights = nn.layers{1, 1}.W;
hiddenBias = nn.layers{1, 1}.b;
outputWeights = nn.layers{1, 3}.W;
outputBias = nn.layers{1, 3}.b;

hiddenWeightedIn = hiddenWeights*inputVector + hiddenBias;
hiddenActivFunct =1./(1.0 + exp(-(hiddenWeightedIn)));

outputWeightedIn = outputWeights*hiddenActivFunct + outputBias;
outputActivFunct = 1./(1.0 + exp(-(outputWeightedIn)));            


% Sclale to stdlv
ram_b = round(nn.layers{1, 1}.b*2^fraction);
ram_w = round(nn.layers{1, 1}.W*2^fraction);
ram_i = round(nn.layers{1, 1}.x(:,1)*2^fraction);
            
hiddenActivFunct(:,2) = round(hiddenActivFunct(:,1)*2^fraction);
outputActivFunct(:,2) = round(outputActivFunct(:,1)*2^fraction);

% Test 10000 input image (test_images & test_layers)
file_test = fopen('../tb/test_input.bin','w');
ram_input_test = test_images';
for i = 1:784*num_of_test
    value = ram_input_test(i);
    fprintf(file_test, '%f\n', value);
end

file_labers = fopen('../tb/test_labers.bin','w');
ram_labers_test = test_labels;
for i = 1:num_of_test
    value = ram_labers_test(i);
    fprintf(file_labers, '%d\n', value);
end