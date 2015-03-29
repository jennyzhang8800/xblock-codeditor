#!/bin/bash
id=$1
email=$2
base="/edx/var/edxapp"
out_base=$base/staticfiles/codeditor
#out_base="/home/zyn/xblock-codeditor/codeditor"
codemirror_base=$base/codemirror_codeditor
code_base=$base/staticfiles/ucore
output_dir=$out_base/$id
data_dir=$out_base/"data"
key_file=/var/www/.ssh/id_rsa_$id
username=$(echo $email | sed "s/\(\)@.*/\1/")
COMPILATION_COMMANDS=$code_base/$id/compile_commands.json
##clone code from gitlab
cd $code_base/$id/ucore_plus
cp $codemirror_base/scripts/fake_compiler.sh ../
sed -i "s/\$COMPILATION_COMMANDS/\/edx\/var\/edxapp\/staticfiles\/ucore\/$id\/compile_commands.json/g" ../fake_compiler.sh
ssh-add $key_file
git remote add origin$id git@$id:$username/ucore.git
git pull origin$id master
if [ -d $output_dir ]
then
rm -r $output_dir
fi
##echo "$output_dir"
##echo "$dir_commands"
##generate compile_commands.json
sed -i "s/\$(CROSS_COMPILE)gcc/\/edx\/var\/edxapp\/staticfiles\/ucore\/${id}\/fake_compiler.sh/g" $code_base/$id/ucore_plus/ucore/Makefile
export FORWARD_COMPILER=gcc
echo ¡°¡± > $COMPILATION_COMMANDS
echo "[" > $COMPILATION_COMMANDS
$base/staticfiles/xblock-script/make.sh $id
echo " { \"directory\": \".\", \"command\": \"true\", \"file\": \"/dev/null\" } ]" >> $COMPILATION_COMMANDS
sed -i "s/\/edx\/var\/edxapp\/staticfiles\/ucore\/${id}\/fake_compiler.sh/\$(CROSS_COMPILE)gcc/g" $code_base/$id/ucore_plus/ucore/Makefile
$codemirror_base/generator/codeditor_generator -b $code_base/$id -a -o $output_dir/ucore -p ucore_plus:$code_base/$id/ucore_plus/ucore
$codemirror_base/indexgenerator/codeditor_indexgenerator $output_dir/ucore
if [ ! -d $data_dir ]
then
ln -s $codemirror_base/data $out_base/$id
fi
