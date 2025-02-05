
set -e
set -x


# Pull the version of winsparkle from github specified in the variable. Then
# unzip it and place it in a location that setup.py is expecting it to be.
function download_latest_winsparkle()
{
    winsparkle_version="0.7.0"

	mkdir -p ./WORK
	cd WORK

    wget https://github.com/vslavik/winsparkle/releases/download/v$winsparkle_version/WinSparkle-$winsparkle_version.zip
    unzip WinSparkle-$winsparkle_version.zip
    cd WinSparkle-$winsparkle_version

    libs_folder="../../../pywinsparkle/libs"

    # move the x86 version
    cp Release/WinSparkle.dll $libs_folder/x86
    diff Release/WinSparkle.dll $libs_folder/x86/WinSparkle.dll


    # move the x64 version
    cp x64/Release/WinSparkle.dll $libs_folder/x64/
    diff x64/Release/WinSparkle.dll $libs_folder/x64/WinSparkle.dll

    cd ../../
    rm -r WORK
}

# This function creates a virtual environment for the version
# of python specified in the arguments.
# Args:
#     $1 major version
#     $2 minor version
#     $3 revision version
#     $4 platform
function build_python_wheel()
{
	rm -rf venv
	bash install_python.sh --major $1 --minor $2 --revision $3
	source venv/bin/activate
	python -m pip install wheel

	python -m pip install pypandoc

	cd ../
	python setup.py bdist_wheel --plat-name=$4
	deactivate
	cd BuildScripts
}

function generate_documentation()
{
	rm -rf venv
	bash install_python.sh --major 3 --minor 6 --revision 1
	source venv/bin/activate
	python -m pip install wheel
	python -m pip install sphinx
	cd BuildScripts/sphinx
	make html
}


function main()
{
	# script to install python
	wget https://raw.githubusercontent.com/dyer234/build_python/master/install_python.sh

	download_latest_winsparkle

	sudo apt-get install pandoc

	# create the wheel for python 3.10
	build_python_wheel 3 10 4 win32
	build_python-wheel 3 10 4 win_amd64

	# create the wheel for python 3.9
	build_python_wheel 3 9 6 win32
	build_python_wheel 3 9 6 win_amd64

	# create the wheel for python 3.8
	build_python_wheel 3 8 12 win32
	build_python_wheel 3 8 12 win_amd64

	# create the wheel for python 3.7
	build_python_wheel 3 7 12 win32
	build_python_wheel 3 7 12 win_amd64

	# create the wheel for python 3.6
	build_python_wheel 3 6 15 win32
	build_python_wheel 3 6 15 win_amd64

	# create the wheel for python 3.5
	#build_python_wheel 3 5 9 win32
	#build_python_wheel 3 5 9 win_amd64

	# create the wheel for python 3.4
	#build_python_wheel 3 4 10 win32
	#build_python_wheel 3 4 10 win_amd64

	# create the wheel for python 3.3
	#build_python_wheel 3 3 7 win32
	#build_python_wheel 3 3 7 win_amd64

	# create the wheel for python 3.2
	#build_python_wheel 3 2 6 win32
	#build_python_wheel 3 2 6 win_amd64

	# create the wheel for python 2.7
	build_python_wheel 2 7 18 win32
	build_python_wheel 2 7 18 win_amd64

	sudo rm -rf WORK_TEMP
	sudo rm -rf install_python.sh

	cd ../

	generate_documentation
}

main
