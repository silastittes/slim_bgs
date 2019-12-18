Simulations to try out recent ideas about detecting sweeps in the presence of background selection. So far, just testing `RAiSD`, because of relevance to a larger project. 

Requires a Unix environment, `vcftools`, `snakemake`, `SLiM`, and `RAiSD`

Modify `Snakefile` as desired (NOTE: add more details). Run with:

```
snakemake -j X
```

Where X is available number of CPUS.

R script included for plotting, etc. Still clunky. Needs to read in file names more intelligently. 
