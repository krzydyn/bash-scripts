if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    exit 1
fi

function showargs {
	aa="";
	while [ $# -gt 0 ]; do
		a="$1"; shift
		if [[ "$a" =~ ^.*\ .*$ ]]; then
			aa+=`printf " %s" "\"$a\""`
		else
			aa+=`printf " %s" "$a"`
		fi
	done
	printf "$aa\n"
}

