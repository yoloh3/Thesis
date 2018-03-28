%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
% 

classdef Layer < handle

	properties

		x; % inputs
		y; % outputs

		dx; % input grads
		dy; % incoming grads
	
	end

	methods

		function obj = Layer(inputs, outputs, batchsize)

			obj.x = zeros(inputs, batchsize);
			obj.y = zeros(outputs, batchsize);

			obj.dx = zeros(size(obj.x));
			obj.dy = zeros(size(obj.y));

		end

	end

	%subclasses should define these
	
	methods (Abstract)

		obj = forward();
		obj = backward();
		obj = reset_grads();
		obj = apply_grads(alpha);
	
	end

end