%
% @Author: kmrocki
% @Date:   2016-12-09 12:01:23
% @Last Modified by:   kmrocki
% @Last Modified time: 2016-12-09 12:01:23
%

classdef Network < handle
 
    properties
     
        layers;
        batchsize;
        loss;
     
    end
 
    methods
     
        function obj = Network(batchsize)
     
        obj.batchsize = batchsize;
        obj.layers = [];
     
        end
     
        function obj = forward(obj, input_data)
     
        obj.layers{1}.x = input_data';
     
        % go forward
        for i = 1:1:length(obj.layers)
         
            obj.layers{i}.forward();
         
            if (i < length(obj.layers))
             
                obj.layers{i + 1}.x = obj.layers{i}.y;
             
            end
         
        end
     
        end
     
        function obj = backward(obj, targets)
     
        I = eye(10);
     
        obj.layers{end}.dy = I(:, targets + 1);
     
        % go back
        for i = length(obj.layers): - 1:1
         
            obj.layers{i}.reset_grads();
            obj.layers{i}.backward();
         
            if (i > 1)
                obj.layers{i - 1}.dy = obj.layers{i}.dx;
            end
         
        end
        end
     
        function obj = update(obj, alpha)
     
        for i = 1:1:length(obj.layers)
         
            obj.layers{i}.apply_grads(alpha);
         
        end
     
        end
     
        function obj = train(obj, xs, ys, learning_rate)
     
        [batch targets] = make_batch(xs, ys, obj.batchsize);
     
        % forward activations
        obj.forward(batch);
     
        I = eye(10);
     
        targets_onehot = I(:, targets + 1);
     
        obj.loss = cross_entropy(obj.layers{end}.y, targets_onehot);
        %fprintf('[ \t %d / %d\t ] Loss = %f\n', ii, iterations, loss);
     
        % % backprogagation
        obj.backward(targets);
     
        % % apply changes
        obj.update(learning_rate);
     
        end
     
        function obj = test(obj, xs, ys)
     
        loss = 0;
        num_correct = 0;
     
        [batch targets] = make_batch(xs, ys, obj.batchsize);
     
        % forward activations
        obj.forward(batch);
     
        [output idx] = max(obj.layers{end}.y, [], 1);
     
        num_correct = num_correct + sum(targets + 1 == idx');
     
        fprintf('%% correct = %.2f\n', 100.0 * num_correct / obj.batchsize);
     
        end
     
    end
 
    end