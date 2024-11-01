ALL = bimgus_game.prg

all: clean export_dir $(ALL)

export_dir:
	mkdir export

tank_data: ./data/make_tank.py
	python ./data/make_tank.py ./data

bimgus_game.prg: ./bimgus_game.s tank_data
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

clean:
	rm -rf export
