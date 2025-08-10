echo "installing make from source 4.4"
wget https://ftp.gnu.org/gnu/make/make-4.4.tar.gz
tar -xvzf make-4.4.tar.gz
cd make-4.4
./configure
./build.sh
./make install

