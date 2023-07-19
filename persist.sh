PERSIST_PATH="$1"
shift

FILES_TO_PERSIST="$@"

for file in "$@"
do
  target="$PERSIST_PATH/$file"
  echo -e "Persisting"
  echo -e "\e[31m$file\e[0m at"
  echo -e "\e[32m$PERSIST_PATH/$file\e[0m"
  echo
  mkdir -p "`dirname $target`"
  rsync -arhP "$file" "$target"
done
