# Pedro Silva
# Inspiration from Stack Overflow
# http://stackoverflow.com/questions/4638874/how-to-loop-through-a-directory-recursively-to-find-files-with-certain-extension
#!/bin/bash

# loop & print a folder recusively,
print_folder_recurse() {
    for i in "$1"/*;do
        if [ -d "$i" ];then
            echo "dir: $i"
            print_folder_recurse "$i"
        elif [ -f "$i" ]; then
            echo "file: $i"
        fi
    done
}

delete_folder_recurse() {
    echo "deleting $1/$pattern..."
    rm -f $1/$pattern
    for i in "$1"/*;do
        if [ -d "$i" ];then
            delete_folder_recurse "$i"
        fi
    done
}


# try get path from param
path=""
if [ -d "$1" ]; then
    path=$1;
    pattern=$2
    delete_folder_recurse $path $pattern
else
    path="."
    pattern="(none)"
    print_folder_recurse $path
fi

