How to get started:
- Download the indexGIXS folder to your computer
- Open the indexGIXS folder in the Scilab File Browser 
- Open indexGIXS-3B.sce in the Scilab editor and execute via F5
- Choose the medoptics detector in the detector pulldown menu
- Load the image file; parameters are already preset; try the calc and the index buttons
  
Happy indexing!

In case you're interested: the example image "Nanocube Superlattice.tif" shows a rhombohedral structure found for a superlattice formed by PbSe nanocubes. (See J.J. Choi et al., Nano Lett. 12, 4791–4798 (2012). https://doi.org/10.1021/nl3026289) 


A detailed description of the program can be found at

"indexGIXS – software for visualizing and interactive indexing of grazing-incidence scattering data", J. Appl. Cryst. 2026, 59, 960-967;
https://doi.org/10.1107/S1600576726002608

If you use indexGIXS for your research, please cite this paper.  


Application examples of indexGIXS can be found in open access journals:

"Probing Functional Thin Films with Grazing Incidence X-Ray Scattering: The Power of Indexing"
Crystals 2025, 15, 63;   https://doi.org/10.3390/cryst15010063

"Indexing 2D Powders and Lagrange–Gauss Reduction"
Crystals 2026, 16, 43;   https://doi.org/10.3390/cryst16010043



=============================================================================

Version History

Version 3B fixes some minor issues in version 3A. In addition the code was cleaned up some more. I recommend recompiling the libraries using the scripts "generate_GIXSlib-3B.sce" and "generate_dlib-3A", in particular when switching to a different Scilab version.

Version 3A is the first version of indexGIXS that was published on GitHub and contains extensions and code clean-up from the previous versions that were distributed via dropbox. 
