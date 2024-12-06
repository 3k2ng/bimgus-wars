ALL = ./_bimgus_game.prg

all: clean $(ALL)

./data/sprite_data.bin: ./data/make_sprite.py
	python ./data/make_sprite.py ./data
	./data/zx02 ./data/sprite_data.bin ./data/sprite_data.zx02
	rm -rf ./data/*.bin

./data/level_data.bin: ./data/make_level.py ./data/levels.txt
	python ./data/make_level.py ./data
	./data/zx02 ./data/level_1_data.bin ./data/level_1_data.zx02
	./data/zx02 ./data/level_2_data.bin ./data/level_2_data.zx02
	rm -rf ./data/*.bin

./_bimgus_game.prg: ./bimgus_game.s ./main_game.s ./data/sprite_data.bin ./data/level_data.bin
	dasm $< -o$@ -l$(<:.s=.lst)

clean:
	rm -rf ./data/*.s ./data/*.bin ./data/*.zx02 ./_bimgus_game.prg ./bimgus_game.lst
