%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
% 


function y = fsoftmax(x)

	%probs(class) = exp(x, class)/sum(exp(x, class))

	e = exp(x);

	sums = sum(e, 1);

	y = bsxfun(@rdivide, e,  sums);
