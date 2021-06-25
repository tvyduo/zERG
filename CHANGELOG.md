## v1.0
Initial release of zERG, including the .m and .fig files, and the accompanying user guide.

**Please note that amplitude calculations are incorrect in this version. v1.1 contains updated functions.**

Code Created on: 09/09/2020
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
  * Easier loading of .m file from current directory
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

Code Updated on: 12/03/2020
Manual Updated on: 06/23/2021
