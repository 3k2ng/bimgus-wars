ALL = ./export/_bimgus_game.prg

all: clean $(ALL)

./data/sprite_data.s: ./data/make_sprite.py
	python ./data/make_sprite.py ./data

bin_data: ./data/make_bin.py
	python ./data/make_bin.py

./data/zx02/zx02: ./data/zx02/src/zx02.c ./data/zx02/src/memory.c ./data/zx02/src/compress.c ./data/zx02/src/optimize.c
	$(CC) -o$@ ./data/zx02/src/zx02.c ./data/zx02/src/memory.c ./data/zx02/src/compress.c ./data/zx02/src/optimize.c

zx02_data: bin_data ./data/zx02/xz02 ./data/make_zx02.py
	python ./data/make_zx02.py
	rm -rf ./data/*.bin
	rm -rf ./data/*.zx02

./export/_bimgus_game.prg: ./bimgus_game.s ./main_game_loop.s ./data/sprite_data.s zx02_data

./data/level_data.s: ./data/make_level.py ./data/levels.txt
	python ./data/make_level.py ./data

./export/_bimgus_game.prg: ./bimgus_game.s ./main_game_loop.s ./data/sprite_data.s ./data/level_data.s
	rm -rf export
	mkdir export
	dasm $< -o$@ -lexport/$(<:.s=.lst)

clean:
	rm -rf ./data/zx02/zx02
	rm -rf ./data/*.s
	rm -rf ./data/*.bin
	rm -rf ./data/*.zx02
	rm -rf export
