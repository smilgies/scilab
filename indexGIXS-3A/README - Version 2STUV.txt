Versions 2S and 2T

Version 2S introduces a menu for indexing in reciprocal space. This option is set with  the index_rule pushbutton; the menu let's you choose whether to stay in real space ("real) transform to reciprocal space ("rec"). The latter can only be done for the surface unit cell which is equivalent to (HKL)=(001). The advantage of this option is that it splits the problem of finding 6 lattice parameters at once into 3+3 parameters of the parallel and vertical compoments. For more explanation refer to my recent papers:

"Probing Functional Thin Films with Grazing Incidence X-Ray Scattering: The Power of Indexing"
Crystals 2025, 15, 63.   https://doi.org/10.3390/cryst15010063

"indexGIXS – software for visualizing and interactive indexing of grazing-incidence scattering data", ChemRxiv 6/2025, Version 4.   DOI: 10.26434/chemrxiv-2021-j1bww

If you use indexGIXS for your research, please cite these papers.  

Version 2Sy also introduces access to the Xenocs EDF format. This format has an ASCII formatted header which can be read with any text editor. Scilab will read all experiment related parameters from this header in addition to reading the data. Thanks to this header, both Eiger 1M and Eiger 4M detectors can be read the same way (and possibly other detectors on Xenocs instruments). With the the evolution of more data preprocessing and the original TVX format for dectris detectors slowly disappearing, I would love to see more adoption of the EDF format!

Brookhaven-based CMS data are now marked as such. SMI/OPLS data files can be read using the ALS GB format.

Version 2T takes care of a name change (for the graphics function defining the color map) that was introduced in Scilab 2025 and is now obligatory for Scilab 2026. In addition the 2S code was cleaned up.

For the next versions (2U and up) some modernization of the code is planned.


Some detailed strategies to find an indexation for the surface unit cell of 2D powders are discussed in
"Indexing 2D Lattices and Lagrange-Gauss Reduction", Crystals 2026, 16, 43    https://doi.org/10.3390/cryst16010043


Version 2U is transitional and will remain unpublished. It modernizes access to the pull-down menus (detector, index rule). This will make it much easier to add detectors or specific spacegroups, and will make the code more readable.

Version 2V adds vectorization to the spot calculation and space group checking. 2V is available in the dropbox distribution for beta testing. This version will be the base for Version IndexGIXS 3.0, which is planned to be the first version to be published on GitHub.


