#!/bin/bash

# Compilers are located under /opt/compiler-explorer/ 
declare -a compilers=("clang-7.1.0" "clang-8.0.1" "clang-9.0.1" "clang-10.0.1" "clang-11.0.1" "clang-12.0.1" "clang-13.0.0")
declare -a branches=("main" "experimental")

# Utility to insert or update key value pairs in .properties files.
setProperty () {

thekey=$1
newvalue=$2
filename=$3

if ! grep -R "^[#]*\s*${thekey}=.*" $filename > /dev/null; then
  echo "APPENDING because '${thekey}' not found"
  echo "$thekey=$newvalue" >> $filename
else
  echo "SETTING because '${thekey}' found already"
  #sed -i -r "s/^[#]*\s*${thekey}=.*/$thekey=$newvalue/" $filename
  escapedvalue=$(echo "$newvalue" | sed 's/\//\\\//g')
  sed -i "/${thekey}=/ s/=.*/=${escapedvalue}/" $filename
fi

}
# Create config files in a temporary directory
cp -a /home/ubuntu/compiler-explorer/etc/config/. /tmp/ce/


for branch in ${branches[@]}; do

	setProperty "group.clang-enzyme-$branch.compilers" "clang7-enzyme-$branch:clang8-enzyme-$branch:clang9-enzyme-$branch:clang10-enzyme-$branch:clang11-enzyme-$branch:clang12-enzyme-$branch:clang13-enzyme-$branch" "/tmp/ce/c++.local.properties"
	setProperty "group.clang-enzyme-$branch.compilers" "cclang7-enzyme-$branch:cclang8-enzyme-$branch:cclang9-enzyme-$branch:cclang10-enzyme-$branch:cclang11-enzyme-$branch:cclang12-enzyme-$branch:cclang13-enzyme-$branch" "/tmp/ce/c.local.properties"
        setProperty "group.clang-enzyme-$branch.compilers" "irclang7-enzyme-$branch:irclang8-enzyme-$branch:irclang9-enzyme-$branch:irclang10-enzyme-$branch:irclang11-enzyme-$branch:irclang12-enzyme-$branch:irclang13-enzyme-$branch" "/tmp/ce/llvm.local.properties"
	setProperty "group.opt-enzyme-$branch.compilers" "opt7-enzyme-$branch:opt8-enzyme-$branch:opt9-enzyme-$branch:opt10-enzyme-$branch:opt11-enzyme-$branch:opt12-enzyme-$branch:opt13-enzyme-$branch" "/tmp/ce/llvm.local.properties"

	setProperty "group.clang-enzyme-$branch.intelAsm" "-mllvm --x86-asm-syntax=intel" "/tmp/ce/c++.local.properties"
	setProperty "group.clang-enzyme-$branch.intelAsm" "-mllvm --x86-asm-syntax=intel" "/tmp/ce/c.local.properties"
	setProperty "group.clang-enzyme-$branch.intelAsm" "-mllvm --x86-asm-syntax=intel" "/tmp/ce/llvm.local.properties"

	setProperty "group.clang-enzyme-$branch.compilerType" "clang" "/tmp/ce/c++.local.properties"
        setProperty "group.clang-enzyme-$branch.compilerType" "clang" "/tmp/ce/c.local.properties"
        setProperty "group.clang-enzyme-$branch.compilerType" "clang" "/tmp/ce/llvm.local.properties"
	setProperty "group.opt-enzyme-$branch.compilerType" "opt" "/tmp/ce/llvm.local.properties"

        setProperty "group.clang-enzyme-$branch.supportsExecute" "true" "/tmp/ce/c++.local.properties"
        setProperty "group.clang-enzyme-$branch.supportsExecute" "true" "/tmp/ce/c.local.properties"
	setProperty "group.clang-enzyme-$branch.supportsExecute" "true" "/tmp/ce/llvm.local.properties"	
	setProperty "group.opt-enzyme-$branch.supportsExecute" "false" "/tmp/ce/llvm.local.properties"

	setProperty "group.clang-enzyme-$branch.isSemVer" "true" "/tmp/ce/c++.local.properties"
        setProperty "group.clang-enzyme-$branch.isSemVer" "true" "/tmp/ce/c.local.properties"
        setProperty "group.clang-enzyme-$branch.isSemVer" "true" "/tmp/ce/llvm.local.properties"
	setProperty "group.opt-enzyme-$branch.isSemVer" "true" "/tmp/ce/llvm.local.properties"

	setProperty "group.clang-enzyme-$branch.groupName" "CLANG + ENZYME ($branch)" "/tmp/ce/c++.local.properties"
        setProperty "group.clang-enzyme-$branch.groupName" "CLANG + ENZYME ($branch)" "/tmp/ce/c.local.properties"
        setProperty "group.clang-enzyme-$branch.groupName" "CLANG + ENZYME ($branch)" "/tmp/ce/llvm.local.properties"
	setProperty "group.opt-enzyme-$branch.groupName" "OPT + ENZYME ($branch)" "/tmp/ce/llvm.local.properties"

	setProperty "group.clang-enzyme-$branch.options" "-fno-discard-value-names" "/tmp/ce/c++.local.properties"
        setProperty "group.clang-enzyme-$branch.options" "-fno-discard-value-names" "/tmp/ce/c.local.properties"
	setProperty "group.clang-enzyme-$branch.options" "-fno-discard-value-names" "/tmp/ce/llvm.local.properties"


	for compiler in ${compilers[@]}; do
		version=$(echo $compiler | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')
		semver=$(echo $compiler | sed -e "s/^clang-//" )

		mkdir -p /tmp/build/$branch/$compiler
 		
		# Checkout Enzyme
		git -C /home/ubuntu/Enzyme checkout $branch
		git -C /home/ubuntu/Enzyme fetch
		git -C /home/ubuntu/Enzyme reset --hard origin/$branch

		commit=$(git -C /home/ubuntu/Enzyme rev-parse --short=7 HEAD)

		# Build Enzyme
		cmake -G Ninja -B /tmp/build/$branch/$compiler -S /home/ubuntu/Enzyme/enzyme -DCMAKE_BUILD_TYPE=Debug -DLLVM_DIR=/opt/compiler-explorer/$compiler/lib/cmake/llvm
		cmake --build /tmp/build/$branch/$compiler
		
		# Create directories if they don't already exists and copy built plugins.
		mkdir -p /opt/compiler-explorer/$branch
		
		cp /tmp/build/$branch/$compiler/Enzyme/ClangEnzyme-$version.so /opt/compiler-explorer/$branch/ClangEnzyme-$version.so
		cp /tmp/build/$branch/$compiler/Enzyme/LLVMEnzyme-$version.so /opt/compiler-explorer/$branch/LLVMEnzyme-$version.so

		setProperty "compiler.clang$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/clang++" "/tmp/ce/c++.local.properties"
                setProperty "compiler.cclang$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/clang" "/tmp/ce/c.local.properties"
                setProperty "compiler.irclang$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/clang" "/tmp/ce/llvm.local.properties"
		setProperty "compiler.opt$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/opt" "/tmp/ce/llvm.local.properties"
	
		if [ $version -gt 12 ] 
		then
		setProperty "compiler.clang$version-enzyme-$branch.options" "-fno-experimental-new-pass-manager -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.local.properties"
               	setProperty "compiler.cclang$version-enzyme-$branch.options" "-fno-experimental-new-pass-manager -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.local.properties"
                setProperty "compiler.irclang$version-enzyme-$branch.options" "-fno-experimental-new-pass-manager  -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.local.properties"
		setProperty "compiler.opt$version-enzyme-$branch.options" "--enable-new-pm=0 -load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -enzyme --enzyme-attributor=0" "/tmp/ce/llvm.local.properties"
		
		else
	
		setProperty "compiler.clang$version-enzyme-$branch.options" "-Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.local.properties"
               	setProperty "compiler.cclang$version-enzyme-$branch.options" "-Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.local.properties"
       		setProperty "compiler.irclang$version-enzyme-$branch.options" "-Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.local.properties"         
		setProperty "compiler.opt$version-enzyme-$branch.options" "-load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -enzyme" "/tmp/ce/llvm.local.properties"
		
		fi

		setProperty "compiler.clang$version-enzyme-$branch.semver" "$semver" "/tmp/ce/c++.local.properties"
                setProperty "compiler.cclang$version-enzyme-$branch.semver" "$semver" "/tmp/ce/c.local.properties"
		setProperty "compiler.irclang$version-enzyme-$branch.semver" "$semver" "/tmp/ce/llvm.local.properties"
		setProperty "compiler.opt$version-enzyme-$branch.semver" "$semver" "/tmp/ce/llvm.local.properties"

		setProperty "compiler.clang$version-enzyme-$branch.name" "clang $version ($commit)" "/tmp/ce/c++.local.properties"
                setProperty "compiler.cclang$version-enzyme-$branch.name" "clang $version ($commit)" "/tmp/ce/c.local.properties"
		setProperty "compiler.irclang$version-enzyme-$branch.name" "clang $version ($commit)" "/tmp/ce/llvm.local.properties"
		setProperty "compiler.opt$version-enzyme-$branch.name" "opt $version ($commit)" "/tmp/ce/llvm.local.properties"

	done
done

# Move finished config files to the final location
cp -a /tmp/ce/. /home/ubuntu/compiler-explorer/etc/config/
