#!/usr/bin/env python

import numpy as np
from matplotlib import pyplot as plt
import logging
import sys
def get_image(filename, img_width=28, img_height=28):
    img_size = img_width*img_height
    a = open(filename, 'r').read().split()
    if len(a) % img_size != 0:
        logging.error("Input size does not divided by 28x28")
        # raise
    num_imgs = int(len(a)/img_size)
    for i in range(0, num_imgs):
        b = a[img_size*i:img_size*(i+1)]
        ## FIXME: tested case: height=width; other cases not tested yet
        c = np.reshape(b, (img_height, img_width))
        c = np.array(c, dtype=float)*255
        print("%d" % (i+0))
        plt.imshow(np.transpose(c), cmap='gray')
        plt.savefig('test_%05d.png' % (i+1), format='png')
if __name__ == '__main__':
    get_image(sys.argv[1])
