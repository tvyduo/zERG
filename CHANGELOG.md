## v1.0
Initial release of zERG, including the .m and .fig files, and the accompanying user guide.

**Please note that amplitude calculations are incorrect in this version. v1.1 contains updated functions.**

Code Created on: 09/09/2020<br>
Manual Created on: 12/03/2020

## v1.1

zERG Change Log
* New features
  * Noise-remover now supports traces where R wave amplitude > P wave amplitude
  * Pop-up prompts within noise-remover to make feature more user-friendly
  * Extended noise-remover function to minima
  * 'Select data' now works for traces where the start time is not 0
  * Frequency of pop-ups can now be changed to cater to advanced users
  * Automatic saving of plots after clicking 'Analyze ECGs'
* Updates
  * Y-axis multiplier function to improve manual peak placement in 'Find Peaks'
  * Easier loading of `.m` file from current directory
  * Improvements to noise-remover for more accurate peak identification
  * Improvements to minima finder for more accurate and faster minima identification
  * Removed 'Save Plots' button
  * HR and RR calculations for minima now based off of minima
  * Depracate 'Add Arrhythmia' and 'Delete Arrhythmia' functions
  * Automatic zooming out to examine full trace after edits are done within noise-remover function
  * Changed plots generated once trace analysis is complete
  * Amplitudes calculated off of isoelectric line
  * Fix amplitude calculations to account for the unit conversion
* Bugs fixed
  * Typos in pop-up prompts
  * Removed leftover markers from testing that interfered with plotting
  * Fixed issues with plotting average trace using minima (no markers were being placed unless window drastically expanded)
* Code organization
  * Move deprecated code/functions currently not in use to a new section
  * Cleaned up code and comments

Manual Change Log
* Removed writer notes in section about average trace
* Fixed typos

Code Updated on: 12/03/2020<br>
Manual Updated on: 06/23/2021

## v1.2

zERG Change Log
* New features
  * Added checks to ensure that the autoplaced P and T wave markers are not out of bounds within the Average Trace plot
  * Added a save/load system to save trace analysis progress into a `.mat` file, which can then be loaded back into zERG
  * Compatibility with different sample rates
  * Added feature to convert `.txt` files into `.mat` format
* Updates
  * Previous markers added to the average trace were still in the background after 'Add Markers' was selected again; the previous markers are now removed
  * Improved the peak noise-remover to more efficiently select peaks automatically
* Bugs fixed
  * Typos in noise-remover pop-up prompts
* Code organization
  * Completely removed functions currently not active within version 1.2
  * Cleaned up code and comments to be more user-friendly

Manual Change Log
* Added sections explaining zooming window, noise remover (both peak and minima), minima alignment, troubleshooting guide, save and load functions, glossary
* Fixed typos
* Added hyperlinks within the document
* Change layout for more user-friendly view

Code Updated on: 06/29/2021<br>
Manual Updated on: 07/01/2021
