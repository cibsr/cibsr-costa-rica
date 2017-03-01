Contents of `./data-unshared/` Directory
=========
Since files in this directory are not staged/committed, it's tough to communicate with collaborators what the files should look like on their computers.  Try to keep this list updated.


* folders of the form `crNirs_gng_056_63_m_f1` where
  - `crNirs` -
  - `gng` - experiment mnemonics
  - `056` - person identifier
  - `63` - ??
  - `m` - gender indicator (m - male, f - female)
  - `f1` - ??
* each folder contains a collection of files produced by the capturing device. 
* the files with extensions `.wl1` and `.wl2` contain the signal data

* One `.nirs` file = one person
* Naming structure matches folders from `./data-unshared/raw/nirs/`

Contains processed NIRS files as they emerge from Homer2 pipeline. 
* One `.mat` file = one person
* Name of the form : `profX_fNIRS_crNirs_gng_056_63_m_f1`


Contains signal files after treatment by the general linear model.

