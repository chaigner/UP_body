# UP_body

This repository contains a MATLAB implementation to load 31 in vivo B1+ datasets and to compute and evaluate tailored and universal pulses based on a library of 22 B1+ datasets as described in [1]. The 31 B1+ maps are available at: TBD and were computed as described in [2].

##### Authors:
- Christoph S. Aigner    (<christoph.aigner@ptb.de>)
- Sebastian Dietrich    (<sebastian.dietrich@ptb.de>)
- Tobias Schäffter  (<tobias.schaeffter@ptb.de>)
- Sebastian Schmitter          (<sebastian.schmitter@ptb.de>)

Contents
--------

##### Test scripts (run these):
    main.m          test script to compute and evaluate tailored and universal pulses

##### Routines called by the test scripts:
    TBD
    
##### Data files used by the test scripts:
    B1R.zip         The 31 B1+ datasets are available at: TBD
    
Dependencies
------------
These routines were tested under MATLAB R2019a under Windows, but should also run under older versions.

The 31 B1+ maps are available at: TBD and were computed as described in [2].

The optimization of the kT-points is performed using code by Will Grissom and Zhipeng Cao (https://bitbucket.org/wgrissom/acptx/) who have given permission for inclusion within this package. Please cite their papers [3,4] appropriately.

License
-------

This software is published under GNU GPLv3. 
In particular, all source code is provided "as is" without warranty of any kind, either expressed or implied. 
For details, see the attached LICENSE.

Reference
---------

[1] Aigner, CS, Dietrich, S, Schaeffter, T, and Schmitter, S, Calibration-free pTx of the human heart at 7T via 3D universal pulses, submitted to Magn. Reson. Med. 2021

[2] Dietrich, S, Aigner, CS, Kolbitsch, C, et al. 3D Free-breathing multichannel absolute B1+ Mapping in the human body at 7T. Magn Reson Med. 2021; 85: 2552– 2567. https://doi.org/10.1002/mrm.28602

[3] Grissom, W.A., Khalighi, M.-M., Sacolick, L.I., Rutt, B.K. and Vogel, M.W. (2012), Small-tip-angle spokes pulse design using interleaved greedy and local optimization methods. Magn Reson Med, 68: 1553-1562. https://doi.org/10.1002/mrm.24165

[4] Cao, Z., Yan, X. and Grissom, W.A. (2016), Array-compressed parallel transmit pulse design. Magn. Reson. Med., 76: 1158-1169. https://doi.org/10.1002/mrm.26020

Created by Christoph S. Aigner, PTB, June 2021.
Email: christoph.aigner@ptb.de
