# ADP-GLMB

Our test scenarios and the files for reading the scenario information have been open-sourced in the DataSet folder and the Code folder, respectively.The core code of ADP-GLMB and the scenario generation program will be open-sourced after the paper is accepted.

Each scene folder in the DataSet contains:1. config_temp.txt: a configuration parameter file that specifies the motion of each target in the scene, the motion of each cluster, and the camera position.2.0.mp4: this file is the generated motion video.3..0_detection.txt: This file contains the video of each frame in which the detected This file contains information about the target measurements detected in each frame of the video.4.0_label.txt: Information about which target the measurement belongs to in each frame of the measurement.5.0_gt.txt: This file contains the real position of the different targets in the scene in each frame.


The Code folder contains the MOT evaluation code and the code to read the above files.
