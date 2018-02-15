H=`find . -name "*.h" -o -name "*.hpp"|grep -o "[^/]*\.h.*"`
echo $H >&2
echo "===============================================================">&2

R=`for h in $H; do
    grep -R --include "*.cpp" --include "*.hpp" "$h>"
done|sort -u`
echo "$R"
echo "$R" | wc -l
