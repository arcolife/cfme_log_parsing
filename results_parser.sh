#!/bin/bash

set -e

user_interrupt(){
    echo -e "\n\nKeyboard Interrupt detected."
    # echo -e "Cleaning Up and terminating..."
    pkill ruby-mri
    rm ${OUTPUT_DIR%/}/*
    exit
}

trap user_interrupt SIGINT
trap user_interrupt SIGTSTP

while getopts "h?i:o:" opt; do
    case "$opt" in
        h|\?)
            echo "Usage: $0 [-i dir containing evm.log files (eg: /var/www/miq/vmdb/log/ )] [-o output dir for dumping results]..."
	    echo "Example: ./results_parser.sh -i ../OSP/logs/extracted/ -o out/"
            exit 0
            ;;
        i)  INPUT_DIR=$OPTARG
            ;;
        o)  OUTPUT_DIR=$OPTARG
            ;;
    esac
done

if [[ -z $INPUT_DIR ]]; then
    INPUT_DIR='/var/www/miq/vmdb/log/'
fi

if [[ -z $OUTPUT_DIR ]]; then
    OUTPUT_DIR='/var/www/miq/vmdb/log/'
fi

if [[ ! -d $OUTPUT_DIR ]]; then
    mkdir -p $OUTPUT_DIR
fi

       
OIFS="$IFS"
IFS=$'\n'

# for all uncompressed logs first
for file in $(find $INPUT_DIR -type f -regex '.*/evm.log[-0-9]*'); do
    log_name=$(basename $file)
    # appliance_name=$(basename $(dirname $file))
    appliance_path=$(dirname $file)
    appliance_path="${appliance_path##$INPUT_DIR}"
    appliance_path="${appliance_path//\//__}"
    for rb_s in `ls *.rb`; do
	# ruby $rb_s -h && echo $rb_s;
	metric_type=$(basename ${rb_s%.rb})
	ruby $rb_s -i $file -o ${OUTPUT_DIR%/}/"$appliance_path"__"$log_name"__"$metric_type".out &
    done
done

# next in line, compressed files
for file in $(find $INPUT_DIR -type f -regex '.*/evm.log.*.gz'); do
    gunzip $file
    log_name=$(basename ${file%.gz})
    # appliance_name=$(basename $(dirname $file))
    appliance_path=$(dirname $file)
    appliance_path="${appliance_path##$INPUT_DIR}"
    appliance_path="${appliance_path//\//__}"
    for rb_s in `ls *.rb`; do
	# ruby $rb_s -h && echo $rb_s;
	metric_type=$(basename ${rb_s%.rb})
	ruby $rb_s -i $file -o ${OUTPUT_DIR%/}/"$appliance_path"__"$log_name"__"$metric_type".out &
    done
done

# find . -type f -name 'evm.log*' -exec sh -c '
#   for file do
#     ls -lh "$file"
#   done
# ' sh {} +
