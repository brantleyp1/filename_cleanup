#! /bin/bash
## change these according to the special characters in your case
search_pattern='~|\!|\@|\#|\$|%|^|\&|\*|\(|\)|\;|:|\ '
replace_pattern=' \~()\!\@\#\$\%\^\&\*\;\:'
inventory_file='inventory_of_files.txt'
filename_length=75
folder_length=50



if [ -z "$1" ]; then
	echo "You need to tell me which directory/filename to inspect"
	exit
fi

if [ ! -e "$1" ]; then
	echo "
Usage: $0 /some/path
	- A path to search and rename files and folders. 
	  Can be run against a folder structure, local directory (i.e. '.'), or individual file.
	"
	exit 255
fi

search_dir="$1"
base_dir=$(dirname "$1")

if [[ "${search_dir: -1}" == "/" ]]; then
	search_dir="${search_dir%?}"
fi

# inventory of files before conversion
if [ -d "${search_dir}" ]; then
	find "${search_dir}" > "${search_dir}/${inventory_file}"
else
	find "${search_dir}" > "${base_dir}/${inventory_file}"
fi

if [ -d "${search_dir}" ]; then
	echo "Looking for filenames with illegal characters: \'${search_pattern}\' to replace with an underscore"
	find "${search_dir}" -type f | while read i; do
		file_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		file_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${file_name}" =~ [${search_pattern}] ]]; then
			mv "${file_path}/${file_name}" "${file_path}/${file_name//[${replace_pattern}]/_}"
		fi
	done

	echo "Finished looking for filenames with illegal characters, replacing multiple underscores with a single underscore now"
	find "${base_dir}" -type f | while read i; do
		file_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		file_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${file_name}" =~ "__" ]]; then
			mv "$file_path/$file_name" "$file_path/${file_name//__/_}"
		fi
	done

	echo "Finished with filename characters, looking for filenames over ${filename_length} characters in length and shortening now"
	find "${search_dir}" -type f | while read i; do
		if [ $( echo "${i}" | awk -F'/' '{ print length($NF) }') -gt ${filename_length} ]; then
			file_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
			file_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
			mv "${file_path}/${file_name}" "${file_path}/${file_name:0:50}"."${file_name##*.}"
		fi
	done
else
	echo "Looking at the filename for illegal characters: '~!@#$%^&*():; ' to replace with an underscore"

	inumber=$(stat "${search_dir}" | awk '{ print $2 }')
	find "${base_dir}" -type f  -inum $inumber| while read i; do
		file_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		file_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${file_name}" =~ [${search_pattern}] ]]; then
			mv "${file_path}/${file_name}" "${file_path}/${file_name//[${replace_pattern}]/_}"
		fi
	done

	echo "Finished looking for illegal characters, replacing multiple underscores with a single underscore now"
	find "${base_dir}" -type f -inum $inumber | while read i; do
		file_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		file_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${file_name}" =~ "__" ]]; then
			mv "$file_path/$file_name" "$file_path/${file_name//__/_}"
		fi
	done
	
	find "${base_dir}" -type f -inum $inumber | while read i; do
		if [ $( echo "${i}" | awk -F'/' '{ print length($NF) }') -gt ${filename_length} ]; then
			file_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
			file_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
			mv "${file_path}/${file_name}" "${file_path}/${file_name:0:50}"."${file_name##*.}"
		fi
	done

fi

# fixing directory lenght and special characters
if [ -d "${search_dir}" ]; then
echo "Files have been fixed, looking at directories now."
	# directory special characters
	echo "Looking one folder deep for special characters and for lenght over ${folder_length} characters"
	find "${search_dir}" -type d -d 1 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ [${search_pattern}] ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//[${replace_pattern}]/_}"
		fi
	done

	# directory double underscore
	find "${search_dir}" -type d -d 1 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ "__" ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//__/_}"
		fi
	done

	# directory length
	find "${search_dir}" -type d -d 1 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [ ${#folder_name} -gt ${folder_length} ]; then
			dir_len="${#folder_name}"
			new_dir_len="$(expr $dir_len / 3 - 5)"
			last_dir_len="$(expr $dir_len - $new_dir_len)"
			new_folder_name="${folder_name:0:$new_dir_len}${folder_name:$last_dir_len}"
			mv "$folder_path/$folder_name" "$folder_path/${new_folder_name}"
		fi
	done

	echo "Looking two folders deep for special characters and for lenght over ${folder_length} characters"
	# directory special characters
	find "${search_dir}" -type d -d 2 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ [${search_pattern}] ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//[${replace_pattern}]/_}"
		fi
	done

	# directory double underscore
	find "${search_dir}" -type d -d 2 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ "__" ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//__/_}"
		fi
	done

	# directory length
	find "${search_dir}" -type d -d 2 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [ ${#folder_name} -gt ${folder_length} ]; then
			dir_len="${#folder_name}"
			new_dir_len="$(expr $dir_len / 3 - 5)"
			last_dir_len="$(expr $dir_len - $new_dir_len)"
			new_folder_name="${folder_name:0:$new_dir_len}${folder_name:$last_dir_len}"
			mv "$folder_path/$folder_name" "$folder_path/${new_folder_name}"
		fi
	done

	echo "Looking three folders deep for special characters and for lenght over ${folder_length} characters"
	# directory special characters
	find "${search_dir}" -type d -d 3 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ [${search_pattern}] ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//[${replace_pattern}]/_}"
		fi
	done

	# directory double underscore
	find "${search_dir}" -type d -d 3 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ "__" ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//__/_}"
		fi
	done

	# directory length
	find "${search_dir}" -type d -d 3 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [ ${#folder_name} -gt ${folder_length} ]; then
			dir_len="${#folder_name}"
			new_dir_len="$(expr $dir_len / 3 - 5)"
			last_dir_len="$(expr $dir_len - $new_dir_len)"
			new_folder_name="${folder_name:0:$new_dir_len}${folder_name:$last_dir_len}"
			mv "$folder_path/$folder_name" "$folder_path/${new_folder_name}"
		fi
	done

	echo "Looking four folders deep for special characters and for lenght over ${folder_length} characters"
	# directory special characters
	find "${search_dir}" -type d -d 4 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ [${search_pattern}] ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//[${replace_pattern}]/_}"
		fi
	done

	# directory double underscore
	find "${search_dir}" -type d -d 4 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ "__" ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//__/_}"
		fi
	done

	# directory length
	find "${search_dir}" -type d -d 4 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [ ${#folder_name} -gt ${folder_length} ]; then
			dir_len="${#folder_name}"
			new_dir_len="$(expr $dir_len / 3 - 5)"
			last_dir_len="$(expr $dir_len - $new_dir_len)"
			new_folder_name="${folder_name:0:$new_dir_len}${folder_name:$last_dir_len}"
			mv "$folder_path/$folder_name" "$folder_path/${new_folder_name}"
		fi
	done

	echo "Looking five folders deep for special characters and for lenght over ${folder_length} characters"
	# directory special characters
	find "${search_dir}" -type d -d 5 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ [${search_pattern}] ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//[${replace_pattern}]/_}"
		fi
	done

	# directory double underscore
	find "${search_dir}" -type d -d 5 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [[ "${folder_name}" =~ "__" ]]; then
			mv "${folder_path}/${folder_name}" "${folder_path}/${folder_name//__/_}"
		fi
	done

	# directory length
	find "${search_dir}" -type d -d 5 | while read i; do
		folder_path=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{NF--; print}')
		folder_name=$(echo "${i}" | awk 'BEGIN{FS=OFS="/"}{ print $NF }')
		if [ ${#folder_name} -gt ${folder_length} ]; then
			dir_len="${#folder_name}"
			new_dir_len="$(expr $dir_len / 3 - 5)"
			last_dir_len="$(expr $dir_len - $new_dir_len)"
			new_folder_name="${folder_name:0:$new_dir_len}${folder_name:$last_dir_len}"
			mv "$folder_path/$folder_name" "$folder_path/${new_folder_name}"
		fi
	done
	echo "Finished looking at the folder structure. If there are more than 5 layers, this script will not affect the folders, though the files were still corrected.

A list of all files/folder potentially affected is at ${search_dir}/${inventory_file}

All Finished!"

else

	echo "Finished looking at the file.

I generated an inventory of the filename at ${base_dir}/${inventory_file} just incase the orignal name is needed.

All Finished!"

fi

exit