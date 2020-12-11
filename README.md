# CORA-examples
Examples of DAE systems reachability analysis using CORA framework.
How to use it:
1. Install Matlab
2. Download CORA - https://github.com/TUMcps/CORA
3. On mac: make sure that XCode is installed
4. Install MPT, Symbolic math toolbox, Optimization toolbox and YALMIP libs (possible from matlab command window)- https://www.mpt3.org/Main/Installation
5. Set path to the CORA in Matlab
6. Write examples and add .m file either to CORA/TUM/models/Cora and CORA/TUM/examples or to abstraction/examples directories
7. Run file from Matlab IDE

NB. Before using abstraction's module it's better to get rid of logging in CORA in createHessianTensorFile.m, taylor.m and
derivatives.m files to speed up computations. For more information follow abstraction/examples.
