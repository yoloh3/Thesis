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

for i = 1:numel(nn.layers{1, 1}.W)
    value = nn.layers{1, 1}.W(i);
    fprintf(file_w, '%f\n', value);
end
for i = 1:numel(nn.layers{1, 3}.W)
    value = nn.layers{1, 3}.W(i);
    fprintf(file_w, '%f\n', value);
end
fclose(file_w);


% for i = 1:numel(nn.layers{1, 1}.W)
%     value = dec2bin(typecast(int8(nn.layers{1, 1}.W(i) * 2.0^fractionn),'uint8'));
%     fprintf(file_w, '%s\n', round(value));
% end
