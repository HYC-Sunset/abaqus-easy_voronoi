**EasyVoronoi: an interactive tool for generating heterogeneous 2D
Voronoi microstructure models**

Yichen Hu<sup>a,</sup>\* , Jiashuo Qi<sup>b</sup>

<sup>a</sup> School of Airspace Science and Engineering, Shandong
University, Weihai 264209, China

<sup>b</sup> Alliance Sorbonne Université, Université de Technologie de
Compiègne, Laboratoire Roberval, Centre de Recherche Royallieu, CS
60319,60203 Compiègne Cedex, France.

## Summary

A Voronoi diagram is a classical mathematical model that partitions
space based on geometric distance\[<sup>1</sup>\]. Its core idea is to
place a number of random points, referred to as seed points or generator
points, in a given plane, and then divide the entire space into several
non-overlapping regions according to the nearest-distance criterion.
Each region corresponds to one seed point. The resulting tessellated
structure exhibits uniform space filling and naturally connected
neighboring regions, and has therefore been widely used for the
geometric simulation of grains, particles, and microstructural units. In
materials science, Voronoi diagrams are commonly used to represent grain
morphologies in polycrystalline metals, because their generation rule
can reasonably capture the competitive growth mechanism of natural
grains.

To accurately simulate homogeneous microstructures\[<sup>2</sup>\],
bimodal grain configurations\[<sup>3</sup>\], and heterogeneous
microstructures\[<sup>4</sup>\] in alloys, the conventional Voronoi
model was extended in this study. In general, a Voronoi model generated
solely from uniformly distributed random points is insufficient to
represent multiscale grain-size differences, and it cannot construct
heterogeneous microstructures with clearly defined distributions of
coarse and fine grains. Therefore, a more flexible point-set generation
strategy is required, including:

1.Controllable region generation: seed points can be placed within
user-defined regions to generate local coarse grains, fine grains, or
specific distribution patterns;

2.Adjustable point density and minimum spacing: quantitative control of
grain size can be achieved by regulating the number of seed points and
the minimum distance between neighboring points;

3.Boundary repulsion and point-position optimization: abnormal elongated
grains caused by seed points located too close to boundaries can be
avoided, thereby improving the rationality of the generated
microstructure.

Accordingly, in this study, an interactive Voronoi point-set
construction tool was developed based on MATLAB and Python. This tool
can not only generate the geometric structure of Voronoi
microstructures, but also automatically extract the endpoint coordinates
of grain-boundary line segments and export them in a readable format.
Subsequently, the exported geometric information was further processed
using a self-developed Python script, including line-segment
reconstruction, region partitioning, and node-topology establishment.
Finally, a complete representative volume element（RVE）model was
constructed and imported into Abaqus.

Through this automated workflow, the efficient conversion from
grain-structure generation to finite element model construction can be
achieved, providing a reliable modeling basis for subsequent
simulations.

<img src="media/media/image1.png"
style="width:6.29861in;height:4.51944in" />

Fig. 1. Workflow of the Voronoi structure generation tool and its
application in multi-morphology structure modeling

The developed tool supports multiple types of seeding regions, including
rectangles, circles, ellipses, and annuli. By flexibly selecting
different region types and adjusting the seeding density, Voronoi
microstructure configurations with distinct grain distribution
characteristics can be generated. This enables the controllable design
of grain size and spatial distribution. The overall code workflow and
representative generated configurations are shown in Fig. 1.

In Voronoi-based microstructure generation, the distribution density of
seed points directly determines the uniformity of grain size and the
stability of the model. If the point spacing is not properly defined, it
may lead to an imbalanced grain-size distribution, excessive local
refinement, and even a deterioration in the quality of the Voronoi
tessellation. Therefore, in this study, an automated point-spacing
estimation method was proposed based on the principle of hexagonal close
packing, aiming to achieve controllable microstructure generation. The
schematic illustration of the algorithm is shown in Fig. 2.

Ideally, a hexagon is the most efficient unit for filling a
two-dimensional space. If each seed point corresponds to one hexagonal
cell, its approximate occupied area can be expressed as:

$$
A_{\mathrm{hex}}=\frac{\sqrt{3}}{2}d^2
\tag{1}
$$

where *d* denotes the spacing between seed points. Furthermore, for a
region with a total area *A* and an expected number of seed points *N*,
the recommended point spacing for maintaining an approximately uniform
hexagonal packing density can be derived as:

$$
d=\sqrt{\frac{2A}{\sqrt{3}N}}
\tag{2}
$$

This formula provides a reasonable initial estimate of the point spacing
from a geometrical perspective, allowing the seed points to exhibit an
approximately regular hexagonal distribution at the global scale.
However, during the actual point-generation process, factors such as
complex region geometry and the randomness of point locations may cause
the theoretical spacing to result in locally over-dense or sparse
distributions. To improve the stability of the generated point set, a
safety factor of 0.7–0.9 was introduced based on the theoretical
spacing. Thus, the final spacing was defined as:
$$
d_{\min}=\eta d,\quad \eta=0.7\text{--}0.9 
\tag{3}
$$
<img src="media/media/image5.png"
style="width:3.08011in;height:2.13324in" />

Fig.2. Demonstration of automatic control of seed spacing: distance
estimation based on hexagonal density

By automatically calculating the recommended spacing, users can rapidly
obtain a reasonable point spacing under different RVE sizes and target
grain numbers without manually tuning the parameters. This method
significantly improves the uniformity of the point distribution and the
success rate of model generation, making the generated Voronoi
microstructures more robust and reliable in terms of grain-size control.

In this study, an automated boundary-buffering algorithm was proposed
based on point-to-boundary distance analysis. The algorithm first
calculates the minimum distance ![](media/media/image6.wmf) from each
seed point to the RVE boundary, and then defines a boundary safety
distance based on the theory of hexagonal close packing:

$$
d_{\mathrm{safe}}=\frac{d_{\min}}{2}
\tag{4}
$$

If a seed point is too close to the boundary, namely
$`d_{i} < d_{\min}`$, the point is automatically shifted toward the
interior of the region to avoid extremely elongated grains caused by
boundary truncation. The displacement of the point is given by:

$$
\delta_i=\min(d_{\min}-d_i,\delta_{\max})
\tag{5}
$$

where $\delta_{\max}=0.1\min(L_x,L_y)$ is used to limit the maximum displacement in a single adjustment, ensuring that the boundary morphology is improved without causing excessive disturbance to the overall grain distribution.

Through this boundary-adjustment strategy based on geometric
constraints, a transition zone can be formed near the boundary, making
the grains adjacent to the boundary more regular while maintaining
better consistency with the internal grains. In addition, the
point-by-point displacement strategy adopted in the algorithm exhibits
good stability. It does not rely on a complex optimization procedure and
can be applied to different geometric regions, such as rectangular and
circular domains.

<img src="media/media/image9.png"
style="width:4.6408in;height:1.70117in" />

Fig. 3. Demonstration of the automatic boundary buffering algorithm for
improving boundary grain distortion

The microstructure generation results, as shown in Fig. 3, indicate that
the proposed boundary-buffering algorithm can effectively eliminate the
elongation of boundary grains. As a result, the generated Voronoi
structure visually resembles the grain morphology of real metallic
materials more closely, while also significantly improving the mesh
quality during import into finite element software. Therefore, this
algorithm provides a more reliable and high-fidelity microstructural
geometric basis for finite element analysis.

## References

\(1\) Quey, R.; Dawson, P. R.; Barbe, F. Large-Scale 3D Random
Polycrystals for the Finite Element Method: Generation, Meshing and
Remeshing. *Comput. Methods Appl. Mech. Eng.* **2011**, *200* (17–20),
1729–1745. https://doi.org/10.1016/j.cma.2011.01.002.

\(2\) Hu, Y.; Shi, M.; Lian, S.; Ma, Y.; Wang, J.; Li, S.; Yuan, F.; Li,
N.; Yue, Z. Deformation Mechanisms Study of Heterostructured Ti-80 Alloy
Based on Crystal Plasticity Theory. *J. Mater. Res. Technol.* **2026**,
*41*, 1654–1670. https://doi.org/10.1016/j.jmrt.2026.01.083.

\(3\) Wang, S.; Shi, M.; Guo, Z.; Liu, X.; Yue, Z.; Tan, Z.; Li, Z.;
Yuan, F. Enhanced Strength-Ductility Synergy in Controllable Bimodal
Grain Structured Composites via Deep Learning Inspired by Strain
Gradient Theory. *Compos. Commun.* **2026**, *63*, 102768.
https://doi.org/10.1016/j.coco.2026.102768.

\(4\) Yuan, R.-F.; Zhang, Y.; Zhang, Y.; Dong, B.; Wang, Y.-J.; Zhang,
Z.; Gu, T.; Jia, Y.-F.; Xuan, F.-Z. Revealing Fracture-Resistant Design
Principles in Harmonic-Structured High-Entropy Alloys Using Quasi in
Situ Experiments and Integrated Modeling. *Int. J. Plast.* **2026**,
*197*, 104600. https://doi.org/10.1016/j.ijplas.2025.104600.
