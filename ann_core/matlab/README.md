# MLP
A simple implementation of a Multilayer Perceptron in MATLAB (~98% accuracy on MNIST)

Download 4 MNIST files from http://yann.lecun.com/exdb/mnist/

unpack them, put in the same folder (or in 'data') and run:

```
nntest
```

network is defined as:

```
nn.layers{1} = Linear(28 * 28, 256, batchsize);
nn.layers{2} = ReLU(256, 256, batchsize);
nn.layers{3} = Linear(256, 10, batchsize);
nn.layers{4} = Softmax(10, 10, batchsize);
```
