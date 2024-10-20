ALL = ./bimgus_game.prg

all: clean export_dir $(ALL)

export_dir:
	mkdir export

./bimgus_game.prg: ./bimgus_game.s ./chars/tank.s
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

clean:
	rm -rf export
