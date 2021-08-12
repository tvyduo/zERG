# zERG

# Description
zERG (**Z**ebrafish **E**CG **R**eading **G**UI) is a Matlab-based Graphic-User Interface (GUI) that allows for the analysis of electrocardiogram (ECG) traces collected from zebrafish. Standard ECG analysis software is limited in terms of analyzing traces where the P wave exceeds the R wave due to incorrect wave assignment. zERG circumvents this and is easily able to identify the ECG waves in such cases to produce the correct average ECG trace, from which standard ECG measurements such as heart rate, intervals, and wave amplitudes can be calculated. All results are then exported in a `.txt` file for downstream analyses.

Currently, input files are limited to `.mat` files exported from Labchart (ADInstruments) or a `.txt` file containing voltage measurements and the corresponding times. Future versions will expand on additional file formats that can be read and used for ECG analysis.

# Releases
Please read the changelog under the releases detailing changes made between each zERG version.

v1.0 Initial release <br>
v1.1 Updates to peak identification functions, improved noise-remover, corrected amplitude calculation <br>
v1.2 Improved noise-remover, added save/load save state feature, add compatibility with different sampling rates, fixed average trace window issues <br>

# How to Run
To run zERG, users need to download both `zERG.m` and `zERG.fig` and place both files within the same folder. Traces do not need to be in the same file as the `.m` and `.fig` files; zERG will automatically ask for the location of the traces to be analyzed.

zERG was developed and has been tested to run on Matlab version 9.7 and GUIDE version 2.5. The following add-ons are required for use: Signal Processing Toolbox version 8.3 and Image Processing Toolbox version 11.0. For help downloading Matlab as well as the add-ons, please visit: https://www.mathworks.com/products/matlab.html

# Example Files
Three `.mat` files within the *Examples* directory has been provided. `.txt` files will be provided in a later update.

# User Guide
A user guide is provided to assist users on how to use zERG. The guide is included as part of the releases but can also be found with the *Manuals* directory.

# Citation
>Duong T, Rose R, Blazeski A, Fine N, Woods CE, Thole JF, Sotoodehnia N, Soliman EZ, Tung L, McCallion AS, Arking DE. Development and optimization of an in vivo electrocardiogram recording method and analysis program for adult zebrafish. *Dis Model Mech*. 2021 Aug 1;14(8):dmm048827. https://doi.org/10.1242/dmm.048827. Epub 2021 Aug 11. PMID: 34378773.

# Zebrafish ECG Traces Database
ECG data supporting the manuscript can be found at a separate repository: https://github.com/tvyduo/zECG_base

# Contact
Please contact ThuyVy Duong at tvyduo@gmail.com for questions and/or assistance. Feedback and suggestions for additional features are welcomed!
