
#hsweep_1_bgs0.1sweep0.vcf
n_types = 4 #number of unique types of sims
reps_per = 5 #reps per type of sim
reps = list(range(reps_per))
rep = reps * n_types
sweep_lgl = 2*[0]*reps_per + 2*[1]*reps_per #neutral, bgs, gbs+sweep
prop_bgs = 0.2
gbs_val = 2*[0]*reps_per + 2*[prop_bgs]*reps_per #prop of del mutations

raisd = ["raisd_bgs0sweep0.txt", f"raisd_bgs{prop_bgs}sweep0.txt", f"raisd_bgs{prop_bgs}sweep1.txt", "raisd_bgs0sweep1.txt"]
pis = ["pi_bgs0sweep0.txt", f"pi_bgs{prop_bgs}sweep0.txt", f"pi_bgs{prop_bgs}sweep1.txt", "pi_bgs0sweep1.txt"]
#raisd = ["raisd_bgs0sweep0.txt"]

slims = [f"hsweep_{rep[r]}_bgs{gbs_val[r]}sweep{sweep_lgl[r]}.vcf" for r in range(reps_per*n_types)]
print(slims)

rule all:
    input:
        slims,
        pis,
        raisd
    
rule slim:
    input:
        "hsweep.slm"
    output:
        vcf = "hsweep_{iter}_bgs{bgs}sweep{sweep}.vcf",
    params:
        i = "{iter}",
        sweep = "{sweep}",
        bgs = "{bgs}"
    shell:
        "slim -d iter={params.i} -d sweep={params.sweep} -d prop_bg={params.bgs} hsweep.slm"
    

rule raisd:
    input:
        "hsweep_{iter}_bgs{bgs}sweep{sweep}.vcf"
    output:
        "RAiSD_Report.hsweep{iter}bgs{bgs}sweep{sweep}"
    params:
        i = "{iter}",
        sweep = "{sweep}",
        bgs = "{bgs}"
    shell:
        """
        ~/Downloads/raisd-master/RAiSD -t -R \
          -n hsweep{params.i}bgs{params.bgs}sweep{params.sweep} \
          -I hsweep_{params.i}_bgs{params.bgs}sweep{params.sweep}.vcf
        awk -v iter={params.i} '{{print $0 "\t" iter}}' RAiSD_Report.hsweep{params.i}bgs{params.bgs}sweep{params.sweep} > RAiSD_Report.hsweep{params.i}bgs{params.bgs}sweep{params.sweep}T
        mv RAiSD_Report.hsweep{params.i}bgs{params.bgs}sweep{params.sweep}T RAiSD_Report.hsweep{params.i}bgs{params.bgs}sweep{params.sweep}
        """
rule pi:
    input:
        "hsweep_{iter}_bgs{bgs}sweep{sweep}.vcf"
    output:
        "hsweep_{iter}_bgs{bgs}sweep{sweep}.pi"
    params:
        i = "{iter}",
        sweep = "{sweep}",
        bgs = "{bgs}"
    shell:
        """
        vcftools --vcf {input} --site-pi --stdout | awk -v iter={params.i} '{{if(NR==1){{print $0 "\t" "iter"}}else{{print $0 "\t" iter}}}}' > {output}
        """

rule combine:
    input:
        raisd= expand("RAiSD_Report.hsweep{i}bgs{{bgs}}sweep{{sweep}}", i = reps),
        pi=expand("hsweep_{i}_bgs{{bgs}}sweep{{sweep}}.pi", i = reps)
    output:
        raisd = "raisd_bgs{bgs}sweep{sweep}.txt",
        pi = "pi_bgs{bgs}sweep{sweep}.txt"
    shell:
        """
        cat {input.raisd} > {output.raisd}
        cat {input.pi} > {output.pi}
        """
