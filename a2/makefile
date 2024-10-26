ALL = title_screen_uncompressed.prg title_screen_hcc.prg zx02_data

all: clean export_dir $(ALL)

export_dir:
	mkdir export

bin_data: ./data/gen_title.py ./data/make_bin.py ./data/title_image.png
	python ./data/make_bin.py ./data

uncompressed_data: ./data/gen_title.py ./data/make_uncompressed.py ./data/title_image.png
	python ./data/make_uncompressed.py ./data

hcc_data: ./data/gen_title.py ./data/make_hcc.py ./data/hcc.py ./data/title_image.png
	python ./data/make_hcc.py ./data

zx02_data: bin_data ./data/zx02 ./data/make_zx02.py
	./data/zx02 ./data/char_set.bin ./data/char_set.zx02
	./data/zx02 ./data/char_map.bin ./data/char_map.zx02
	./data/zx02 ./data/color_map.bin ./data/color_map.zx02
	python ./data/make_zx02.py ./data

title_screen_uncompressed.prg: ./title_screen_uncompressed.s uncompressed_data
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

title_screen_hcc.prg: ./title_screen_hcc.s hcc_data
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

title_screen_zx02.prg: ./title_screen_zx02.s ./data/zx02-optim.asm
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

clean_data:
	rm -rf ./data/*.s ./data/*.bin ./data/*.zx02

clean: clean_data
	rm -rf ./export
