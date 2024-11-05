ALL = ./export/_bimgus_game.prg

all: clean $(ALL)

./data/sprite_data.s: ./data/make_sprite.py
	python ./data/make_sprite.py ./data

./data/title_alto.bin: ./data/make_bin.py
	python ./data/make_bin.py

./export/_bimgus_game.prg: ./bimgus_game.s ./main_game_loop.s ./data/sprite_data.s ./data/title_alto.bin
	rm -rf export
	mkdir export
	dasm $< -o$@ -lexport/$(<:.s=.lst)

clean:
	rm -rf ./data/*.s
	rm -rf ./data/*.bin
	rm -rf export
