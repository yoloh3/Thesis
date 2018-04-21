if (~exist('train_images'))
    train_images = loadMNISTImages('train-images-idx3-ubyte')';
end

if (~exist('train_labels'))
    train_labels = loadMNISTLabels('train-labels-idx1-ubyte');
end

if (~exist('test_images'))
    test_images = loadMNISTImages('t10k-images-idx3-ubyte')';
end

if (~exist('test_labels'))
    test_labels = loadMNISTLabels('t10k-labels-idx1-ubyte');
end
