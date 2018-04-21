%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
% 

classdef Softmax < Layer

	methods

		function obj = Softmax(inputs, outputs, batchsize)

			obj@Layer(inputs, outputs, batchsize);

		end

		function obj = forward(obj)

			obj.y = fsoftmax(obj.x);
		
		end

		function obj = backward(obj)

			obj.dx = obj.dy - obj.y;

		end

		function obj = reset_grads(obj)
		end

		function obj = apply_grads(obj, alpha)
		end

	end

end