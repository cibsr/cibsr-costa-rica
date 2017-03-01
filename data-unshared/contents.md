Contents of `./data-unshared/` Directory
=========
Since files in this directory are not staged/committed, it's tough to communicate with collaborators what the files should look like on their computers.  Try to keep this list updated.


### `./data-unshared/raw/nirs/`
Contais NIRS signal source files as they emerge from the capturing device.
* folders of the form `crNirs_gng_056_63_m_f1` where
  - `crNirs` -
  - `gng` - experiment mnemonics
  - `056` - person identifier
  - `63` - ??
  - `m` - gender indicator (m - male, f - female)
  - `f1` - ??
* each folder contains a collection of files produced by the capturing device. 
* the files with extensions `.wl1` and `.wl2` contain the signal data

### `./data-unshared/derived/nirs/`
Contain NIRS signal files from the basic signal processing routine. Ready to be fed to Homer2.
* One `.nirs` file = one person
* Naming structure matches folders from `./data-unshared/raw/nirs/`

### `./data-unshared/derived/homer/`
Contains processed NIRS files as they emerge from Homer2 pipeline. 
* One `.mat` file = one person
* Name of the form : `profX_fNIRS_crNirs_gng_056_63_m_f1`


### `./data-unshared/derived/models/glm/`
Contains signal files after treatment by the general linear model.

