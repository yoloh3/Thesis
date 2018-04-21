%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
% 

classdef ReLU < Layer

	methods

		function obj = ReLU(inputs, outputs, batchsize)

			obj@Layer(inputs, outputs, batchsize);

		end

		function obj = forward(obj)

			obj.y = rectify(obj.x);
		
		end

		function obj = backward(obj)

			obj.dx = drectify(obj.y) .* obj.dy;

		end

		function obj = reset_grads(obj)
		end

		function obj = apply_grads(obj, alpha)
		end

	end

end