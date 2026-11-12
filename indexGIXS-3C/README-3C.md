# indexGIXS-3C
Version 3C with scilab-2027.0.0 finally overcomes the issue with running the software under MS Windows 11 Enterprise!

### How to get started:
- Download the indexGIXS folder to your computer
- Open the indexGIXS folder in the Scilab File Browser
- Open indexGIXS-3C.sce in the Scilab editor and execute via F5
- Choose the "medoptics" detector in the detector pulldown menu
- Load the image file "Nanocube Superlattice.tif"; parameters are already preset; try the calc and the index buttons

You should get an output as shown in "view-indexGIXS-menu.png". Try the zoom-in and pan feature of the graphics using the mouse wheel and dragging, respectively.
In case of an error, please recompile the libraries: Open generate_dlib-3A and generate_GIXSlib-3C in the Scilab file browser and execute them with F5. If this doesn't resolve the problem, please contact me at dsmilgie@binghamton.edu

If you use indexGIXS for your work please cite:
"indexGIXS: software for visualizing and interactive indexing of grazing-incidence scattering data" D.-M. Smilgies and R. Li, J. Appl. Cryst. (2026). 59, 960–967. https://doi.org/10.1107/S1600576726002608

### Indexing strategies are discussed in:
"Probing Functional Thin Films with Grazing Incidence X-Ray Scattering: The Power of Indexing" Crystals 2025, 15, 63. https://doi.org/10.3390/cryst15010063

### For low-symmetry structures such as molecular thin films, explore the reciprocal space mode:
"Indexing 2D Powders and Lagrange–Gauss Reduction" Crystals 2026, 16, 43. https://doi.org/10.3390/cryst16010043

### Happy indexing!
In case you're interested: the example image "Nanocube Superlattice.tif" shows a rhombohedral structure found for a superlattice with a (111) parallel plane, as formed by PbSe nanocubes. (See J.J. Choi et al., Nano Lett. 12, 4791–4798 (2012). https://doi.org/10.1021/nl3026289)

### Notes
Version 3C with scilab-2027.0.0 finally overcomes the issue with running the software under MS Windows 11 Enterprise!

If there are errors with regard to the libraries, please recompile the libraries using the scripts "generate_GIXSlib-3C.sce" and "generate_dlib-3A.sce": Open the scripts in the Scilab editor and run them using F5. 

The problem with the program crashing under scilab-2026.1.0 and Win 11 Enterprise remains, though, and these versions won't be supported any more in the future. scilab-2023.1.0 still runs version 3C but will be eventually deprecated in the future, so that inconsistencies between the 2023 and 2027 versions no longer clutter up the code.

Some tweaks and fixes to the GUI building were helpful to get the program to load more efficiently. The simulation mode for generating GIXS patterns without prior loading of an image is now explicitly supported as a new detector option "simulate". Parameters are preset to reproduce the images in Figure 4 of the "Power of Indexing" paper. 
