%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
% 

function ret = cross_entropy(predictions, targets)

	ret = sum (-log(sum(targets .* predictions, 1)));

end