%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
%

function y = apply_sigmoid(x)

	y = 1./(1 + exp(-x));
end