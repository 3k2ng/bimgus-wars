ALL = title_screen_uncompressed.prg title_screen_umc.prg title_screen_zx02.prg

all: clean export_dir $(ALL)

export_dir:
	mkdir export

bin_data: ./data/make_bin.py ./data/title_image.png
	python ./data/make_bin.py ./data

uncompressed_data: bin_data ./data/make_uncompressed.py ./data/title_image.png
	python ./data/make_uncompressed.py ./data

umc_data: bin_data ./data/umc.py ./data/make_umc.py 
	python ./data/umc.py ./data/char_map.bin ./data/char_map.umc
	python ./data/umc.py ./data/color_map.bin ./data/color_map.umc
	python ./data/make_umc.py ./data

zx02_data: bin_data ./data/zx02 ./data/make_zx02.py
	./data/zx02 ./data/char_set.bin ./data/char_set.zx02
	./data/zx02 ./data/char_map.bin ./data/char_map.zx02
	./data/zx02 ./data/color_map.bin ./data/color_map.zx02
	python ./data/make_zx02.py ./data


ai_data: bin_data
	python ./data/ai_compressor.py ./data/char_map.bin ./data/char_set.bin ./data/color_map.bin ./data/
	python ./data/ai_data.py ./data/char_set_rle.bin ./data/char_map_rle.bin ./data/color_map_rle.bin ./data/

title_screen_uncompressed.prg: ./title_screen_uncompressed.s uncompressed_data
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

title_screen_umc.prg: ./title_screen_umc.s umc_data
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

title_screen_zx02.prg: ./title_screen_zx02.s zx02_data
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

title_screen_ai.prg: title_screen_ai.s  ai_data ./data/rle_data.s 
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

clean_data:
	rm -rf ./data/*.s ./data/*.bin ./data/*.zx02

clean: clean_data
	rm -rf ./export
