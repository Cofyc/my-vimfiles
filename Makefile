ROOT_PATH := $(shell sh -c 'pwd')
all:
	ln -fs ${ROOT_PATH}/vimrc ~/.vimrc
	ln -fs ${ROOT_PATH}/vim ~/.vim