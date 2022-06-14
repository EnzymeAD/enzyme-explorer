#!/bin/bash

old_clang=$(eadlink -f /opt/compiler-explorer/clang-assertions-trunk)

/home/ubuntu/infra/bin/ce_install check_installed compilers/c++/nightly/clang assertions-trunk --enable nightly
uptodate=$?

   if [ "$uptodate" != 0 ]
   then
      /home/ubuntu/infra/bin/ce_install install compilers/c++/nightly/clang assertions-trunk --enable nightly
      rm -rf $old_clang
      exit 0
   else
      echo -e ${FINISHED}Compilers are up to date.${NOCOLOR}
   fi
