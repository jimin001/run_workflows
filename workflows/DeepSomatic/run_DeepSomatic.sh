# adapted from: https://github.com/miramastoras/phoenix_batch_submissions/blob/main/workflows/DeepPolisher/run_DeepPolisher.sh

###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = DeepSomatic

## on personal computer...

# Remove top up data from data table

mkdir -p /Users/jpark621/GITHUB/run_workflows/workflows/DeepSomatic/input_jsons
cd /Users/jpark621/GITHUB/run_workflows/workflows/DeepSomatic/input_jsons

python3 /Users/jpark621/Documents/CGL/scripts/launch_from_table.py \
     --data_table ../DeepSomatic.csv \
     --field_mapping ../DeepSomatic_input_mapping.csv \
     --workflow_name DeepSomatic


###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C /private/groups/patenlab/jimin/GITHUB/run_workflows pull

# move to working dir
mkdir -p /private/groups/patenlab/jimin/GITHUB/run_workflows/workflows/DeepSomatic
cd /private/groups/patenlab/jimin/GITHUB/run_workflows/workflows/DeepSomatic

## get files
cp -r /private/groups/patenlab/jimin/GITHUB/run_workflows/workflows/DeepSomatic/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=DeepSomatic \
     --array=[1]%1 \
     --partition=medium \
     --time=10:00:00 \
     --cpus-per-task=64 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=jpark621@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/patenlab/jimin/GITHUB/WDLs/variant_calling/tasks/DeepSomatic.wdl \
     --sample_csv DeepSomatic.csv \
     --input_json_path '../input_jsons/${SAMPLE_ID}_DeepSomatic.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

# on hpc after entire batch has finished
cd /private/groups/patenlab/jimin/GITHUB/run_workflows/workflows/DeepSomatic

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./DeepSomatic.csv \
      --output_data_table ./DeepSomatic.results.csv \
      --json_location '{sample_id}_DeepSomatic_outputs.json'




