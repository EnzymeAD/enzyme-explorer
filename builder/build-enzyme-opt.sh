#!/bin/bash

# Compilers are located under /opt/compiler-explorer/ 
declare -a compilers=("mlir-16.0.0")
declare -a branches=("main")

# Utility to insert or update key value pairs in .properties files.
setProperty () {

thekey=$1
newvalue=$2
filename=$3

if ! grep "^[#]*\s*${thekey}=.*" $filename > /dev/null; then
  echo "APPENDING because '${thekey}' not found"
  echo "$thekey=$newvalue" >> $filename
else
  echo "SETTING because '${thekey}' found already"
  escapedvalue=$(echo "$newvalue" | sed 's/\//\\\//g')
  sed -i "/${thekey}=/ s/=.*/=${escapedvalue}/" $filename
fi

}
# Create config files in a temporary directory
cp -a /app/compiler-explorer/etc/config/mlir.enzyme.properties /tmp/ce/


for branch in ${branches[@]}; do

	setProperty "group.enzyme-opt-$branch.compilers" "enzyme-opt16-$branch" "/tmp/ce/mlir.enzyme.properties"
	setProperty "group.enzyme-opt-$branch.isSemVer" "true" "/tmp/ce/mlir.enzyme.properties"
	setProperty "group.enzyme-opt-$branch.groupName" "enzyme-opt ($branch)" "/tmp/ce/mlir.enzyme.properties"

	for compiler in ${compilers[@]}; do
		version=$(echo $compiler | grep -o -E '[0-9]+|trunk' | head -1 | sed -e 's/^0\+//')
		semver=$(echo $compiler | sed -e "s/^mlir-//" )

		mkdir -p /tmp/build/$branch/$compiler
 		
		# Checkout Enzyme
		git -C /app/Enzyme checkout $branch
		git -C /app/Enzyme fetch
		git -C /app/Enzyme reset --hard origin/$branch

		commit=$(git -C /app/Enzyme rev-parse --short=7 HEAD)

		# Build enzyme-opt
		cmake -G Ninja -B /tmp/build/$branch/$compiler -S /app/Enzyme/enzyme -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_BUILD_TYPE=Debug -DLLVM_DIR=/opt/compiler-explorer/$compiler/lib/cmake/llvm -DENZYME_MLIR=ON
		
		cmake --build /tmp/build/$branch/$compiler --target enzymemlir-opt
		
		# Create directories if they don't already exists and copy built plugins.
		mkdir -p /opt/compiler-explorer/$branch
		
		cp /tmp/build/$branch/$compiler/Enzyme/MLIR/enzymemlir-opt /opt/compiler-explorer/$branch/enzyme-opt$version

		setProperty "compiler.enzyme-opt$version-$branch.exe" "/opt/compiler-explorer/$branch/enzyme-opt$version" "/tmp/ce/mlir.enzyme.properties"
		setProperty "compiler.enzyme-opt$version-$branch.semver" "$semver" "/tmp/ce/mlir.enzyme.properties"
		setProperty "compiler.enzyme-opt$version-$branch.name" "enzyme-opt $version ($commit)" "/tmp/ce/mlir.enzyme.properties"
	done
done

# Move finished config files to the final location
cp -a /tmp/ce//mlir.enzyme.properties /app/compiler-explorer/etc/config/
