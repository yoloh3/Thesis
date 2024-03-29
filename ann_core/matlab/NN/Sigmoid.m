%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
% 

classdef Sigmoid < Layer

	methods

		function obj = Sigmoid(inputs, outputs, batchsize)

			obj@Layer(inputs, outputs, batchsize);

		end

		function obj = forward(obj)

			obj.y = apply_sigmoid(obj.x);
		
		end

		function obj = backward(obj)

			obj.dx = dsigmoid(obj.y) .* obj.dy;

		end

		function obj = reset_grads(obj)
		end

		function obj = apply_grads(obj, alpha)
		end

	end

end