% Huy-Hung Ho

fraction = 10;

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
hiddenActivFunct = 1./(1.0 + exp(-(hiddenWeightedIn)));

outputWeightedIn = outputWeights*hiddenActivFunct + outputBias;
outputActivFunct = 1./(1.0 + exp(-(outputWeightedIn)));            


% Sclale to stdlv
ram_b = round(nn.layers{1, 1}.b*2^fraction);
ram_w = round(nn.layers{1, 1}.W*2^fraction);
ram_i = round(nn.layers{1, 1}.x(:,1)*2^fraction);
            
hiddenActivFunct(:,2) = round(hiddenActivFunct(:,1)*2^fraction);
outputActivFunct(:,2) = round(outputActivFunct(:,1)*2^fraction);
