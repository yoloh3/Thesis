function y = dsigmoid(x)
% dLogisticSigmoid Derivative of the logistic sigmoid.
% 
% INPUT:
% x     : Input vector.
%
% OUTPUT:
% y     : Output vector where the derivative of the logistic sigmoid was
% applied element by element.
%
    y = apply_sigmoid(x).*(1 - apply_sigmoid(x));
end