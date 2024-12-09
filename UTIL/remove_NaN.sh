
for file in `cat listFile.txt`; do
	echo $file
	cp $file temp.temp
	sed 's/NaN/0.00/g' temp.temp > $file
done
