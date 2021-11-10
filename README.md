# filename_cleanup
fix filenames and directories that have special characters, or are too long

## purpose
sometimes you have a file directory with a lot of long filenames, or that contain special characters, or both, and you need to quickly clean up the filenames and folder names.

this is the script for you then! 

this script can be adapted as needed, but currently will search up to 5 folder levels deep for folders with "illegall characters" or filename lengths that are too long. both of those options can be configured.

the script will also take an inventory of current files/folders just in case something happens, at least there's a record.

## how to use

```
./change_filenames.sh /some/path/of/files
```

this would scan the path, first fixing filenames with the illegal charracters, then fixing folders.

```
./change_filenames.sh 'my funny*named &file.ext'
```

would change 'my funny*named &file.ext' to 'my_funny_named_file.ext'

## how to customize

there are a few variables at the top that can be configured as needed.

the search_pattern is used in the text blocks, as well as the if statements. the replace_pattern is used in the variable expansion to rename. they have different rules as far as escaping, so if you need to change/add to this list, you'll need to add it in both places and it may require different escaping. 
```
search_pattern='~|\!|\@|\#|\$|%|^|\&|\*|\(|\)|\;|:|\ '
replace_pattern=' \~()\!\@\#\$\%\^\&\*\;\:'
```

the name of the inventory file
```
inventory_file='inventory_of_files.txt'
```

the lengths, I decided the filename could be a little longer than the folder name, but can be configured as needed
```
filename_length=75
folder_length=50
```

I didn't want to worry about any further searches than the first 5 levels deep. you could potentially just run the script at a lower level, or if you want to edit the script, you'd do so like this:

currently in the script, lines 228-258:
```
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
```

you would need to copy those 30 or so lines, paste as many times as you need, then update the `find` command, i.e. `find "${search_dir}" -type d -d 5` to `find "${search_dir}" -type d -d 6`, `find "${search_dir}" -type d -d 7`, etc. this section is in groups of 3, all 3 must match.