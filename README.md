# zERG
Repository for zERG, a Matlab based zebrafish ECG analysis program

# Description
zERG (Zebrafish ECG Reading GUI) is a Matlab-based Graphic-User Interface (GUI) that allows for the analysis of electrocardiogram (ECG) traces collected from zebrafish. Standard ECG analysis software is limited in terms of analyzing traces where the P wave exceeds the R wave due to incorrect wave assignment. zERG circumvents this and is easily able to identify the ECG waves in such cases to produce the correct average ECG trace, from which standard ECG measurements such as heart rate, intervals, and wave amplitudes can be calculated. All results are then exported in a .txt file for downstream analyses.

Currently, input files are limited to .mat files exported from Labchart (ADInstruments) or a .txt file containing voltage measurements and the corresponding times. Future versions will expand on additional file formats that can be read and used for ECG analysis.

# Releases
Please read the changelog under the releases detailing changes made between each zERG version.

v1.0 Initial release <br>
v1.1 Updates to peak identification functions, improved noise-remover, corrected amplitude calculation <br>

# How to Run
To run zERG, users need to download both zERG.m and zERG.fig and place both files within the same folder. Traces do not need to be in the same file as the .m and .fig files; zERG will automatically ask for the location of the traces to be analyzed.

zERG was developed and has been tested to run on Matlab version 9.7 and GUIDE version 2.5. The following add-ons are required for use: Signal Processing Toolbox version 8.3 and Image Processing Toolbox version 11.0. For help downloading Matlab as well as the add-ons, please visit: https://www.mathworks.com/products/matlab.html

# Example Files
Three .mat files within the Examples directory has been provided. Text files will be provided in a later update.

# Citation
The manuscript associated with this work is currently in review. A proper citation will be provided at a later time. Please cite if you use zERG!

Duong T et al. Development and Optimization of an In Vivo Electrocardiogram Recording Method and Analysis Program for Adult Zebrafish. Manuscript submitted for publication.

# Zebrafish ECG Traces Database
Data and code supporting the manuscript can be found at a seperate repository: https://github.com/tvyduo/zECG_base

# Contact
Please contact ThuyVy Duong at tvyduo@gmail.com for questions and/or assistance. Feedback and suggestions for additional features are welcomed!
