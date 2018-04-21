
addpath('./NN');
addpath('./mnistHelper');
addpath('./data');

load_data;

epochs = 1;
batchsize = 250;
learning_rate = 1e-3;
iters_per_epoch = 1000;

nn = Network(batchsize);

smooth_loss = log(10);

% ~ 98 % correct
% nn.layers{1} = Linear(28 * 28, 40, batchsize);
% nn.layers{2} = ReLU(40, 40, batchsize);
% nn.layers{3} = Linear(40, 10, batchsize);
% nn.layers{4} = Softmax(10, 10, batchsize);
%Sigmoid NN
 nn.layers{1} = Linear(28 * 28, 40, batchsize);
 nn.layers{2} = Sigmoid(40, 40, batchsize);
 nn.layers{3} = Linear(40, 40, batchsize);
 nn.layers{4} = Sigmoid(40,40,batchsize);
 nn.layers{5} = Linear(40,10,batchsize);
 nn.layers{6} = Softmax(10, 10, batchsize);
for e=1:1:epochs

    fprintf('Epoch %d...\n', e);
    
    for ii=1:1:iters_per_epoch

    	nn.train(train_images, train_labels, learning_rate);
    	smooth_loss = [smooth_loss smooth_loss(end) * 0.99 + 0.01 * nn.loss/batchsize];
    
    end

    nn.test(test_images, test_labels);

    figure(1);
    plot(smooth_loss);
    drawnow

end





    