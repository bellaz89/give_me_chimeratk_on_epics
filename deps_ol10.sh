dnf config-manager --set-enabled ol10_codeready_builder
dnf install oracle-epel-release-el10 -y
dnf upgrade -y
dnf groupinstall "Development Tools" -y
dnf install cmake readline-devel -y
dnf install hdf5-devel -y
dnf install autoconf automake libtool -y
dnf install boost-devel -y
dnf install python3-devel python3-numpy python3-pip -y
dnf install python3-pybind11 pybind11-devel python3-mypy -y
dnf install libxml2-devel libxml++-devel -y
dnf install perl-FindBin perl-ExtUtils-MakeMaker -y
dnf install qt5-qtbase-devel qt5-qttools-devel qt5-qtcharts-devel -y
