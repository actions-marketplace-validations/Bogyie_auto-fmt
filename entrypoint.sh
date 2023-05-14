#!/bin/sh

# INPUT_TOKEN
# INPUT_REPOSITORY
# INPUT_REF
# INPUT_BASE_REF
# INPUT_HEAD_REF 
# INPUT_TRIGGERING_ACTOR
PULL_NUMBER=$(echo "$INPUT_REF" | grep -o '[0-9]*')

git clone "https://$INPUT_TRIGGERING_ACTOR:$INPUT_TOKEN@github.com/$INPUT_REPOSITORY.git" -b $INPUT_BASE_REF repo

if [ -d repo ]; then
    cd repo
    git checkout -t origin/$INPUT_HEAD_REF
    
    edited_files=$(git diff --name-only origin/$INPUT_BASE_REF origin/$INPUT_HEAD_REF | grep -i '.tf$')
    echo $edited_files

    reformated_files=""
    for edited_file in $edited_files; do
        reformat_needs=$(/terraform fmt -write=false -check "$edited_file")
        if [ -n "$reformat_needs" ]; then
            reformated_file=$(/terraform fmt -list=true "$edited_file")
            reformated_files="$reformated_files\n- [$reformated_file]($reformated_file)"
        fi
    done

    # If exist re-formatting .tf file
    if [ -n "$reformated_files" ]; then

        git config --global user.name $INPUT_TRIGGERING_ACTOR && \
            git config --global user.email $INPUT_TRIGGERING_ACTOR@github.com && \
            git add . && \
            git commit --amend --no-edit && \
            git push --force && \
            echo "Req URL: https://api.github.com/repos/$INPUT_REPOSITORY/issues/$PULL_NUMBER/comments" && \
            curl -L \
                -X POST \
                -H "Accept: application/vnd.github+json" \
                -H "Authorization: Bearer $INPUT_TOKEN"\
                -H "X-GitHub-Api-Version: 2022-11-28" \
                https://api.github.com/repos/$INPUT_REPOSITORY/issues/$PULL_NUMBER/comments \
                -d '{"body":":robot: Next files are reformatted\n'"$reformated_files"'"}'
    fi
fi
