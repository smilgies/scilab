The folder classifyGIXS contains a number of scripts for structure determination and refinement for indexing of GIWAXS data. The approach is based on a two-step approach for finding the unit cell and indexation: in the first step results from Lagrange-Gauss reduction are used to determine the in-plane reciprocal surface unit cell. As the second step the out-of-plane lattice constants are found.

"Indexing 2D Powders and Lagrange-Gauss Reduction", Crystals 2026, 16, 43; https://doi.org/10.3390/cryst16010043.

This approach is further refined in a two-part paper for triclinic and monoclinic structures. The first part has been published in MDPI journal Crystals:

"Classification of 2D-GIWAXS Images of Highly Textured Molecular Thin Films towards Indexation: Triclinic Lattices", Crystals 2026, 16, 584;   https://doi.org/10.3390/cryst16090584

Here the methodology introduced in the first paper is further developed and special cases are included. In a new part it is shown how standard crystallographic procedures can be used to bring the unit cell into its normalized form and possibly apply further reduction to obtain a unique descriptor of the observed polymorph. As an application this approach is demonstrated on a sample data set in detail. Script 5 shows a variety of implementations of the LLL algorithm as provided by Gemini and Claude. Script 5b adds the full Niggli reduction according to Krivy and Gruber (Acta Cryst A 1976, 32, 297).

Recommendation: Use scripts in order, as implied by the filename, i.e. start with 1-classify-tri to find the inplane lattice, then refine the lattice with 2-refine-qpar etc. A sample data set is provided and processed, if scripts are run in the original form. For your samples, you should replace the input data at the head of the script with your own. In addition the original GISAXS image used in this study is provided. The matrix format (extension mtx) is specific to the indexGIXS program. This format is used for the merged original data files, in order to fill in the blind strip between active panels in the Pilatus 200k detector. 

In general it is very useful to combine the scripts with software for viewing of data and calculated spot positions. My indexGIXS program is also found in this repository (scilab/indexGIXS-3B). A detailed description can be found in the open access paper:

"indexGIXS – software for visualizing and interactive indexing of grazing-incidence scattering data", J. Appl. Cryst. (2026). 59, 960–967; https://doi.org/10.1107/S1600576726002608

For an overview of grazing-incidence x-ray scattering and the importance of indexing please see

"Probing Functional Thin Films with Grazing Incidence X-Ray Scattering: The Power of Indexing", Crystals 2025, 15, 63; https://doi.org/10.3390/cryst15010063

If you use some of the scripts in the classifyGIXS folder or indexGIXS for your research, please cite the corresponding papers.
In case of questions or comments, you can contact me at dsmilgie@binghamton.edu.
