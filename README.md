Interactive Voronoi Seed Generator is a MATLAB GUI tool for creating 2D Voronoi seed points and thickened grain-boundary regions. It supports custom domains, multiple ROI shapes, minimum-distance seed generation, remaining-area filling, undo, visualization, and export for RVE or finite element preprocessing.
<img width="1196" height="570" alt="image" src="https://github.com/user-attachments/assets/1585f738-856d-465b-89f5-d04084230e39" />
<img width="1186" height="536" alt="image" src="https://github.com/user-attachments/assets/fe5a4645-fefa-413e-be10-6c6452c6aee7" />


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

## Requirements

MATLAB R2019b or later is recommended. The program uses functions such as `polyshape`, `drawrectangle`, `drawcircle`, `drawellipse`, and `polybuffer`, so a relatively recent MATLAB version is required to support the relevant interactive graphics and geometric processing features.

## Attention!!
If you use this tool in your research, please cite the following publication. Thank you for your support.
https://doi.org/10.1016/j.jmrt.2026.01.083
During use, an activation code is required. Please send me an email at 202437682@mail.sdu.edu.cn, and I will provide you with a license.




