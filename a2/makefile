ALL = ./title_screen_uncompressed.prg

all: clean export_dir $(ALL)

export_dir:
	mkdir export

title_data: ./data/gen_title.py ./data/title_image.png
	python ./data/gen_title.py ./data/title_image.png ./data/title

./title_screen_uncompressed.prg: ./title_screen_uncompressed.s title_data
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

clean_data:
	rm -rf ./data/*.s

clean: clean_data
	rm -rf ./export
