%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
% 

classdef Linear < Layer

	properties

		% x -> y weights
		W;
		% biases
		b;

		% x -> y grads
		dW;
		% b grads
		db;
	
	end

	methods

		function obj = Linear(inputs, outputs, batchsize)

			obj@Layer(inputs, outputs, batchsize);

			obj.W = randn(outputs, inputs) * 0.1;
			obj.b = zeros(outputs, 1);

			obj = reset_grads(obj);

		end

		function obj = forward(obj)

			obj.y = obj.W * obj.x;
			obj.y = bsxfun(@plus, obj.y, obj.b);

		end

		function obj = backward(obj)

			obj.dW = obj.dy * obj.x';
			obj.db = sum(obj.dy, 2);
			obj.dx = obj.W' * obj.dy;

		end

		function obj = reset_grads(obj)

			obj.dW = zeros(size(obj.W));
			obj.db = zeros(size(obj.b));
		
		end

		function obj = apply_grads(obj, alpha)

			obj.b = obj.b + alpha * obj.db;
			obj.W = obj.W + alpha * obj.dW;

		end

	end

end