function create_exp_context {
    local exp_name=$1
    local exp_dir=$2
    local root_dir=$3

    mkdir -p ${exp_dir}/config   
    exp_config="${exp_dir}/config"
    server_config="${exp_config}/server"
    loadgen_config="${exp_config}/loadgen"

    mkdir -p ${server_config}
    mkdir -p ${loadgen_config}

    jq -r '.[] | select(.name == "'${exp_name}'")' ${root_dir}/experiments.json > ${exp_config}/experiment.json.tmp

    runcfg=$(jq -r '.config.loadgen.runcfg' ${exp_config}/experiment.json.tmp)
    filename=$(basename -- ${runcfg})
    cp ${root_dir}/${runcfg} ${loadgen_config}/script.js

    jq -r '.config.loadgen.runcfg = "script.js"' ${exp_config}/experiment.json.tmp > ${exp_config}/experiment.json
    rm ${exp_config}/experiment.json.tmp

	jq -r '.config.server | to_entries | .[] | "\(.key)=\(.value)"' ${exp_config}/experiment.json > ${server_config}/server.env 
	jq -r '.config.loadgen' ${exp_config}/experiment.json > ${loadgen_config}/loadgen.json 
}

"$@"