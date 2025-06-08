#!/bin/bash

# Compilers are located under /opt/compiler-explorer/ 
declare -a compilers=("clang-15.0.0" "clang-16.0.0" "clang-17.0.1" "clang-18.1.0" "clang-19.1.0" "clang-20.1.0" "clang-assertions-trunk")
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
mkdir -p /tmp/ce
cp /app/compiler-explorer/etc/config/c++.enzyme.properties /tmp/ce/
cp /app/compiler-explorer/etc/config/c.enzyme.properties /tmp/ce/
cp /app/compiler-explorer/etc/config/llvm.enzyme.properties /tmp/ce/


for branch in ${branches[@]}; do

	setProperty "group.clang-enzyme-$branch.compilers" "clang15-enzyme-$branch:clang16-enzyme-$branch:clang17-enzyme-$branch:clang18-enzyme-$branch:clang19-enzyme-$branch:clang20-enzyme-$branch:clang21-enzyme-$branch" "/tmp/ce/c++.enzyme.properties"
	setProperty "group.clang-enzyme-$branch.compilers" "cclang15-enzyme-$branch:cclang16-enzyme-$branch:cclang17-enzyme-$branch:cclang18-enzyme-$branch:cclang19-enzyme-$branch:cclang20-enzyme-$branch:cclang21-enzyme-$branch" "/tmp/ce/c.enzyme.properties"
    setProperty "group.clang-enzyme-$branch.compilers" "irclang15-enzyme-$branch:irclang16-enzyme-$branch:irclang17-enzyme-$branch:irclang18-enzyme-$branch:irclang19-enzyme-$branch:irclang20-enzyme-$branch:irclang21-enzyme-$branch" "/tmp/ce/llvm.enzyme.properties"
	setProperty "group.opt-enzyme-$branch.compilers" "opt15-enzyme-$branch:opt16-enzyme-$branch:opt17-enzyme-$branch:opt18-enzyme-$branch:opt19-enzyme-$branch:opt20-enzyme-$branch:opt21-enzyme-$branch" "/tmp/ce/llvm.enzyme.properties"

	setProperty "group.clang-enzyme-$branch.intelAsm" "-mllvm --x86-asm-syntax=intel" "/tmp/ce/c++.enzyme.properties"
	setProperty "group.clang-enzyme-$branch.intelAsm" "-mllvm --x86-asm-syntax=intel" "/tmp/ce/c.enzyme.properties"
	setProperty "group.clang-enzyme-$branch.intelAsm" "-mllvm --x86-asm-syntax=intel" "/tmp/ce/llvm.enzyme.properties"

	setProperty "group.clang-enzyme-$branch.compilerType" "clang" "/tmp/ce/c++.enzyme.properties"
    setProperty "group.clang-enzyme-$branch.compilerType" "clang" "/tmp/ce/c.enzyme.properties"
   	setProperty "group.clang-enzyme-$branch.compilerType" "clang" "/tmp/ce/llvm.enzyme.properties"
	setProperty "group.opt-enzyme-$branch.compilerType" "opt" "/tmp/ce/llvm.enzyme.properties"

   	setProperty "group.clang-enzyme-$branch.supportsExecute" "true" "/tmp/ce/c++.enzyme.properties"
  	setProperty "group.clang-enzyme-$branch.supportsExecute" "true" "/tmp/ce/c.enzyme.properties"
	setProperty "group.clang-enzyme-$branch.supportsExecute" "true" "/tmp/ce/llvm.enzyme.properties"	
	setProperty "group.opt-enzyme-$branch.supportsExecute" "false" "/tmp/ce/llvm.enzyme.properties"

	setProperty "group.clang-enzyme-$branch.isSemVer" "true" "/tmp/ce/c++.enzyme.properties"
  	setProperty "group.clang-enzyme-$branch.isSemVer" "true" "/tmp/ce/c.enzyme.properties"
  	setProperty "group.clang-enzyme-$branch.isSemVer" "true" "/tmp/ce/llvm.enzyme.properties"
	setProperty "group.opt-enzyme-$branch.isSemVer" "true" "/tmp/ce/llvm.enzyme.properties"

	setProperty "group.clang-enzyme-$branch.groupName" "CLANG + ENZYME ($branch)" "/tmp/ce/c++.enzyme.properties"
   	setProperty "group.clang-enzyme-$branch.groupName" "CLANG + ENZYME ($branch)" "/tmp/ce/c.enzyme.properties"
    setProperty "group.clang-enzyme-$branch.groupName" "CLANG + ENZYME ($branch)" "/tmp/ce/llvm.enzyme.properties"
	setProperty "group.opt-enzyme-$branch.groupName" "OPT + ENZYME ($branch)" "/tmp/ce/llvm.enzyme.properties"

	setProperty "group.clang-enzyme-$branch.options" "-fno-discard-value-names" "/tmp/ce/c++.enzyme.properties"
    setProperty "group.clang-enzyme-$branch.options" "-fno-discard-value-names" "/tmp/ce/c.enzyme.properties"
	setProperty "group.clang-enzyme-$branch.options" "-fno-discard-value-names" "/tmp/ce/llvm.enzyme.properties"


	for compiler in ${compilers[@]}; do
		version=$(echo $compiler | grep -o -E '[0-9]+|trunk' | head -1 | sed -e 's/^0\+//')
		if [ "$version" == "trunk" ]; then version="20"; fi
		semver=$(echo $compiler | sed -e "s/^clang-//" )

		mkdir -p /tmp/build/$branch/$compiler
 		
		# Checkout Enzyme
		git -C /app/Enzyme checkout $branch
		git -C /app/Enzyme fetch
		git -C /app/Enzyme reset --hard origin/$branch

		commit=$(git -C /app/Enzyme rev-parse --short=7 HEAD)

		# Build Enzyme
		cmake -G Ninja -B /tmp/build/$branch/$compiler -S /app/Enzyme/enzyme -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_BUILD_TYPE=Debug -DLLVM_DIR=/opt/compiler-explorer/$compiler/lib/cmake/llvm
		cmake --build /tmp/build/$branch/$compiler
		
		# Create directories if they don't already exists and copy built plugins.
		mkdir -p /opt/compiler-explorer/$branch
		
		cp /tmp/build/$branch/$compiler/Enzyme/ClangEnzyme-$version.so /opt/compiler-explorer/$branch/ClangEnzyme-$version.so
		cp /tmp/build/$branch/$compiler/Enzyme/LLVMEnzyme-$version.so /opt/compiler-explorer/$branch/LLVMEnzyme-$version.so

		setProperty "compiler.clang$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/clang++" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/clang" "/tmp/ce/c.enzyme.properties"
        setProperty "compiler.irclang$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/clang" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/opt" "/tmp/ce/llvm.enzyme.properties"

		if [ $version -ge 17 ] 
		then
		setProperty "compiler.clang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.enzyme.properties"
        setProperty "compiler.irclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.options" "-load-pass-plugin=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -passes=enzyme --enzyme-attributor=0" "/tmp/ce/llvm.enzyme.properties"
 
		elif [ $version -ge 16 ] 
		then
		setProperty "compiler.clang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.enzyme.properties"
        setProperty "compiler.irclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.options" "-load-pass-plugin=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -passes=enzyme -opaque-pointers=0 --enzyme-attributor=0" "/tmp/ce/llvm.enzyme.properties"

		else
		setProperty "compiler.clang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.enzyme.properties"
        setProperty "compiler.irclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.options" "-load-pass-plugin=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -enzyme --enzyme-attributor=0" "/tmp/ce/llvm.enzyme.properties"
		fi

		setProperty "compiler.clang$version-enzyme-$branch.semver" "$semver" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.semver" "$semver" "/tmp/ce/c.enzyme.properties"
		setProperty "compiler.irclang$version-enzyme-$branch.semver" "$semver" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.semver" "$semver" "/tmp/ce/llvm.enzyme.properties"

		setProperty "compiler.clang$version-enzyme-$branch.name" "clang $version ($commit)" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.name" "clang $version ($commit)" "/tmp/ce/c.enzyme.properties"
		setProperty "compiler.irclang$version-enzyme-$branch.name" "clang $version ($commit)" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.name" "opt $version ($commit)" "/tmp/ce/llvm.enzyme.properties"
	done
done

# Move finished config files to the final location
cp /tmp/ce/c++.enzyme.properties /app/compiler-explorer/etc/config/
cp /tmp/ce/c.enzyme.properties /app/compiler-explorer/etc/config/
cp /tmp/ce/llvm.enzyme.properties /app/compiler-explorer/etc/config/
