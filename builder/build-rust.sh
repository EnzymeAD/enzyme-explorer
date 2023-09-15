#!/bin/bash

# Compilers are located under /opt/compiler-explorer/ 
declare -a compilers=("rust-1.74.0-nightly")
declare -a branches=("master")

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
cp /app/compiler-explorer/etc/config/rust.enzyme.properties /tmp/ce/


for branch in ${branches[@]}; do

	setProperty "group.rust-enzyme-$branch.compilers" "rust.1.74.0-enzyme-$branch" "/tmp/ce/rust.enzyme.properties"

	setProperty "group.rust-enzyme-$branch.intelAsm" "-mllvm --x86-asm-syntax=intel" "/tmp/ce/rust.enzyme.properties"

	setProperty "group.rust-enzyme-$branch.compilerType" "rust" "/tmp/ce/rust.enzyme.properties"

        setProperty "group.rust-enzyme-$branch.supportsExecute" "true" "/tmp/ce/rust.enzyme.properties"

	setProperty "group.rust-enzyme-$branch.isSemVer" "true" "/tmp/ce/rust.enzyme.properties"

	setProperty "group.rust-enzyme-$branch.groupName" "RUST + ENZYME ($branch)" "/tmp/ce/rust.enzyme.properties"

	setProperty "group.rust-enzyme-$branch.options" "-fno-discard-value-names" "/tmp/ce/rust.enzyme.properties"


	for compiler in ${compilers[@]}; do
		version=$(echo $compiler | grep -o -E '[0-9]+|trunk' | head -1 | sed -e 's/^0\+//')
		semver=$(echo $compiler | sed -e "s/^rust-//" )

		mkdir -p /tmp/build/$branch/$compiler
 		
		# Checkout Enzyme
		git -C /app/Rust checkout $branch
		git -C /app/Rust fetch
		git -C /app/Rust reset --hard origin/$branch

		commit=$(git -C /app/Enzyme rev-parse --short=7 HEAD)

		# Build Enzyme
		mkdir /app/Rust/build
                cd /app/Rust/build
                ../configure --enable-llvm-link-shared --enable-llvm-plugins --enable-llvm-enzyme --release-channel=nightly --enable-llvm-assertions --enable-option-checking --enable-ninja --disable-docs
                ../x.py build --stage 1 library/std library/proc_macro library/test tools/rustdoc
                cd /

		# Create directories if they don't already exists and copy built plugins.
		mkdir -p /opt/compiler-explorer/$branch
	
                # From here on not really applicable? We need the full rust build, not just a .so
		cp /tmp/build/$branch/$compiler/Enzyme/ClangEnzyme-$version.so /opt/compiler-explorer/$branch/ClangEnzyme-$version.so
		cp /tmp/build/$branch/$compiler/Enzyme/LLVMEnzyme-$version.so /opt/compiler-explorer/$branch/LLVMEnzyme-$version.so

		setProperty "compiler.clang$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/clang++" "/tmp/ce/c++.enzyme.properties"
        setProperty "compiler.cclang$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/clang" "/tmp/ce/c.enzyme.properties"
        setProperty "compiler.irclang$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/clang" "/tmp/ce/llvm.enzyme.properties"
		setProperty "compiler.opt$version-enzyme-$branch.exe" "/opt/compiler-explorer/$compiler/bin/opt" "/tmp/ce/llvm.enzyme.properties"
	

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
cp /tmp/ce/rust.enzyme.properties /app/compiler-explorer/etc/config/
