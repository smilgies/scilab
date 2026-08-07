The folder classifyGIXS contains a number of scripts for structure determination and refinement for indexing of GIWAXS data. The approach is based on a two-step approach for finding the unit cell and indexation: in the first step results from Lagrange-Gauss reduction are used to determine the in-plane reciprocal surface unit cell. As the second step the out-of-plane lattice constants are found.

"Indexing 2D Powders and Lagrange-Gauss Reduction", Crystals 2026, 16, 43; https://doi.org/10.3390/cryst16010043.

This appoach is further refined in a two-part paper for triclinic and monoclinic structures, the first part has been submitted as a preprint on ChemRxiv: 

"Classification of 2D-GIWAXS Images of Highly Textured Molecular Thin Films towards Indexation: Triclinic Lattices"; https://chemrxiv.org/doi/abs/10.26434/chemrxiv.15007187/v1

Here the methodology introduced in the first paper is further developed and special cases are included. In a second part it is shown how standard crystallographic procedures can be used to bring the unit cell into its normalized form and possibly apply further reduction to obtain a unique descriptor of the found polymorph. As an application this approach is demonstrated on a sample data set in detail. 

Recommendation: Use scripts in order, as implied by the filename, i.e. start with 1-classify-tri to find the inplane lattice, then refine the lattice with 2-refine-qpar etc. A sample data set is provided and processed, if scripts are run in the original form. Then you can replace the input data with your own.

It is very useful to combine the scripts with software for viewing of data and calculated spot positions which is also found in this repository:

"indexGIXS – software for visualizing and interactive indexing of grazing-incidence scattering data", J. Appl. Cryst. (2026). 59, 960–967; https://doi.org/10.1107/S1600576726002608

For an overview of grazing-incidence x-ray scattering and the importance of indexing please see

"Probing Functional Thin Films with Grazing Incidence X-Ray Scattering: The Power of Indexing", Crystals 2025, 15, 63; https://doi.org/10.3390/cryst15010063

If you use some of the scripts in the classifyGIXS folder or indexGIXS for your research, please cite the corresponding papers.
