#!/bin/bash

mkdir -p $2/Code/$1
pushd $2/Code/$1

GTF=/beegfs/projects/epigenomicslab/Annotation/Mus_musculus.GRCm38.96.gtf
GNM=/beegfs/projects/epigenomicslab/Annotation/mm10.for.RNABS.fa

mkdir -p $2/CallResult/$1/

echo -e "#!/bin/bash
#SBATCH -p normal_q
#SBATCH -A davidxie_lab
#SBATCH --nodes=1 --cpus-per-task=40
#SBATCH --exclusive
#SBATCH --time=10:00:00
#SBATCH --mail-user zaustinj@vt.edu
#SBATCH --mail-type=END

mkdir -p \$TMPDIR/ZJ_tmp


meRanCall -p 40 -o \$TMPDIR/ZJ_tmp/$1_Genome10xCall_3_Cutoff_0ML.txt -bam $2/result/$1/$1_3_Ccutoff_PE.bam -f $GNM -mBQ 30 -gref -rl 150 -sc 10 -cr 1 -mr 0 -mcov 10 -regions $2/All_m5C.bed
mv \$TMPDIR/ZJ_tmp/$1_Genome10xCall_3_Cutoff_0ML.txt $2/CallResult/$1/$1_Genome10xCall_3_Cutoff_0ML.txt


" > $1_meRanCallCutoff_0ML.sbatch

sbatch $1_meRanCallCutoff_0ML.sbatch

