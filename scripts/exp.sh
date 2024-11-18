function create_exp_context {
    local exp_name=$1
    local exp_dir=$2
    local root_dir=$3

    mkdir -p ${exp_dir}/config    
    jq -r '.[] | select(.name == "'${exp_name}'")' ${root_dir}/experiments.json > ${exp_dir}/config/experiment.json.tmp

    runcfg=$(jq -r '.config.loadgen.runcfg' ${exp_dir}/config/experiment.json.tmp)
    filename=$(basename -- ${runcfg})
    cp ${root_dir}/${runcfg} ${exp_dir}/config/script.js

    jq -r '.config.loadgen.runcfg = "script.js"' ${exp_dir}/config/experiment.json.tmp > ${exp_dir}/config/experiment.json
    rm ${exp_dir}/config/experiment.json.tmp

	jq -r '.config.server | to_entries | .[] | "\(.key)=\(.value)"' ${exp_dir}/config/experiment.json > ${exp_dir}/config/server.env 
	jq -r '.config.loadgen' ${exp_dir}/config/experiment.json > ${exp_dir}/config/loadgen.json 
}

"$@"