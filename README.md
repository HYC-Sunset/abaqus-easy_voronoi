Interactive Voronoi Seed Generator is a MATLAB GUI tool for creating 2D Voronoi seed points and thickened grain-boundary regions. It supports custom domains, multiple ROI shapes, minimum-distance seed generation, remaining-area filling, undo, visualization, and export for RVE or finite element preprocessing.
<img width="1196" height="570" alt="image" src="https://github.com/user-attachments/assets/1585f738-856d-465b-89f5-d04084230e39" />
<img width="1375" height="780" alt="image" src="https://github.com/user-attachments/assets/708c74a1-665d-4abf-a231-a26a9a469361" />



# Interactive Voronoi Seed Generator

This is an interactive Voronoi seed generation tool developed in MATLAB. It is mainly used for the rapid construction and visualization of two-dimensional polycrystalline structures, grain structures, representative volume elements (RVEs), and similar Voronoi-based geometric models.

The program provides a graphical user interface (GUI), allowing users to manually define the workspace size and create local regions of interest (ROIs) using rectangles, circles, ellipses, and annular regions. Random seed points with a minimum distance constraint can then be generated within different ROIs. The program also supports automatic filling of the remaining area, undoing the previous operation, and automatic generation of the Voronoi diagram after seed generation is completed.

In addition, the program provides a grain-boundary thickening visualization function. Based on the user-defined grain-boundary thickness, Voronoi edges are buffered to obtain grain-boundary regions with finite width. This function can be used for grain-boundary identification, grain-boundary phase modeling, grain-boundary-affected zone analysis, or finite element preprocessing.

## Main Features

- Customizable two-dimensional workspace size;
- Support for rectangular, circular, elliptical, and annular ROIs;
- Two ROI creation modes: manual drawing and parameter input;
- Random seed generation with a minimum distance constraint;
- Automatic filling of unassigned remaining regions;
- Undo support for the previous seed-generation operation;
- Automatic Voronoi diagram generation;
- Grain-boundary thickening visualization;
- Export of Voronoi line segment coordinates;
- Export of grain-boundary thickened polyshape boundary coordinates.

## Applications

This tool is suitable for:

- Two-dimensional Voronoi polycrystal modeling;
- Grain-structure schematic generation;
- RVE geometry preprocessing;
- Grain-boundary thickening modeling;
- Microstructure modeling of composites, metals, or multiphase materials;
- Geometry data generation for Abaqus, MATLAB, or other finite element preprocessing workflows.

## About pycode matlab2abaqus
In the accompanying Python script, y_shrink_ratio is used to control the compression ratio in the y direction. Specifically, all y-coordinates of the Voronoi data are scaled down by this ratio, producing a grain morphology that is compressed along the y direction and relatively elongated along the x direction. When y_shrink_ratio = 1.0, no compression is applied; the larger the value, the flatter the grains become in the y direction.
<img width="319" height="302" alt="image" src="https://github.com/user-attachments/assets/df39c4c8-274c-4f9f-b281-6b4406b310df" />

## Attention!!
If you use this tool in your research, please cite the following publication. Thank you for your support.
https://doi.org/10.1016/j.jmrt.2026.01.083




