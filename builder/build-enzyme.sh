#!/bin/bash

# Compilers are located under /opt/compiler-explorer/ 
declare -a compilers=("clang-9.0.1" "clang-10.0.1" "clang-11.0.1" "clang-12.0.1" "clang-13.0.1" "clang-14.0.0" "clang-15.0.0" "clang-16.0.0" "clang-17.0.1" "clang-assertions-trunk")
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

	setProperty "group.clang-enzyme-$branch.compilers" "clang9-enzyme-$branch:clang10-enzyme-$branch:clang11-enzyme-$branch:clang12-enzyme-$branch:clang13-enzyme-$branch:clang14-enzyme-$branch:clang15-enzyme-$branch:clang16-enzyme-$branch:clang17-enzyme-$branch:clang18-enzyme-$branch" "/tmp/ce/c++.enzyme.properties"
	setProperty "group.clang-enzyme-$branch.compilers" "cclang9-enzyme-$branch:cclang10-enzyme-$branch:cclang11-enzyme-$branch:cclang12-enzyme-$branch:cclang13-enzyme-$branch:cclang14-enzyme-$branch:cclang15-enzyme-$branch:cclang16-enzyme-$branch:cclang17-enzyme-$branch:cclang18-enzyme-$branch" "/tmp/ce/c.enzyme.properties"
    setProperty "group.clang-enzyme-$branch.compilers" "irclang9-enzyme-$branch:irclang10-enzyme-$branch:irclang11-enzyme-$branch:irclang12-enzyme-$branch:irclang13-enzyme-$branch:irclang14-enzyme-$branch:irclang15-enzyme-$branch:irclang16-enzyme-$branch:irclang17-enzyme-$branch:irclang18-enzyme-$branch" "/tmp/ce/llvm.enzyme.properties"
	setProperty "group.opt-enzyme-$branch.compilers" "opt9-enzyme-$branch:opt10-enzyme-$branch:opt11-enzyme-$branch:opt12-enzyme-$branch:opt13-enzyme-$branch:opt14-enzyme-$branch:opt15-enzyme-$branch:opt16-enzyme-$branch:opt17-enzyme-$branch" "/tmp/ce/llvm.enzyme.properties"

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
		if [ "$version" == "trunk" ]; then version="18"; fi
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
	
		if [ $version -ge 16 ] 
		then
		setProperty "compiler.clang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.enzyme.properties"
        setProperty "compiler.irclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.options" "-load-pass-plugin=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -passes=enzyme -opaque-pointers=0 --enzyme-attributor=0" "/tmp/ce/llvm.enzyme.properties"

		elif [ $version -ge 15 ] 
		then
		setProperty "compiler.clang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.enzyme.properties"
        setProperty "compiler.irclang$version-enzyme-$branch.options" "-fpass-plugin=/opt/compiler-explorer/$branch/ClangEnzyme-$version.so -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.options" "-load-pass-plugin=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -enzyme --enzyme-attributor=0" "/tmp/ce/llvm.enzyme.properties"

		elif [ $version -eq 13 ] 
		then
		setProperty "compiler.clang$version-enzyme-$branch.options" "-fno-experimental-new-pass-manager -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.options" "-fno-experimental-new-pass-manager -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.enzyme.properties"
        setProperty "compiler.irclang$version-enzyme-$branch.options" "-fno-experimental-new-pass-manager  -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.options" "--enable-new-pm=0 -load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -enzyme --enzyme-attributor=0" "/tmp/ce/llvm.enzyme.properties"
		
		elif [ $version -ge 14 ] 
		then
		setProperty "compiler.clang$version-enzyme-$branch.options" "-flegacy-pass-manager -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.options" "-flegacy-pass-manager -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.enzyme.properties"
        setProperty "compiler.irclang$version-enzyme-$branch.options" "-flegacy-pass-manager -Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.options" "--enable-new-pm=0 -load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -enzyme --enzyme-attributor=0" "/tmp/ce/llvm.enzyme.properties"
		
		else
		setProperty "compiler.clang$version-enzyme-$branch.options" "-Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.options" "-Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/c.enzyme.properties"
       	setProperty "compiler.irclang$version-enzyme-$branch.options" "-Xclang -load -Xclang /opt/compiler-explorer/$branch/ClangEnzyme-$version.so" "/tmp/ce/llvm.enzyme.properties"         
		setProperty "compiler.opt$version-enzyme-$branch.options" "-load=/opt/compiler-explorer/$branch/LLVMEnzyme-$version.so -enzyme" "/tmp/ce/llvm.enzyme.properties"
		
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
