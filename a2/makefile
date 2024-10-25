ALL = title_screen_uncompressed.prg title_screen_hcc.prg

all: clean export_dir $(ALL)

export_dir:
	mkdir export

uncompressed_data: ./data/gen_title.py ./data/make_uncompressed.py ./data/title_image.png
	python ./data/make_uncompressed.py ./data

hcc_data: ./data/gen_title.py ./data/make_hcc.py ./data/hcc.py ./data/title_image.png
	python ./data/make_hcc.py ./data

title_screen_uncompressed.prg: ./title_screen_uncompressed.s uncompressed_data
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

title_screen_hcc.prg: ./title_screen_hcc.s hcc_data
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

clean_data:
	rm -rf ./data/*.s

clean: clean_data
	rm -rf ./export
