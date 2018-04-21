%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
% 

function [batch targets] = make_batch(xs, ys, batchsize)

	num_examples = size(xs, 1);

	random_numbers = randi([1 num_examples], 1, batchsize);

	batch = xs(random_numbers, :);
	targets = ys(random_numbers, :);

end