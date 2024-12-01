ALL = ./_bimgus_game.prg

all: clean $(ALL)

./data/sprite_data.s: ./data/make_sprite.py
	python ./data/make_sprite.py ./data

./data/level_data.bin: ./data/make_level.py ./data/levels.txt
	python ./data/make_level.py ./data

./_bimgus_game.prg: ./bimgus_game.s ./main_game.s ./data/sprite_data.s ./data/level_data.bin
	dasm $< -o$@ -l$(<:.s=.lst)

clean:
	rm -rf ./data/*.s ./data/*.bin ./_bimgus_game.prg ./bimgus_game.lst
