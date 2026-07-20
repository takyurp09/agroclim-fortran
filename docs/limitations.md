# Limitations

- Daily temperature is represented by a sinusoid defined only by Tmin and Tmax.
- CSV is used for transparent demonstration, not maximum I/O performance.
- The MVP computes one GDD base/cap and one EDD/HDD threshold per run.
- Spatial preprocessing and crop-calendar construction occur outside Fortran.
- Missing days are counted but not imputed.
- The included Slurm file is a deployment template. Cluster experience should
  only be claimed after a real cluster run is documented.
