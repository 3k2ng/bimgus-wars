ALL = ./title_screen_uncompressed.prg

all: export_dir $(ALL)

export_dir:
	mkdir export

./title_screen_uncompressed.prg: ./title_screen_uncompressed.s ./maps/title_cm.s ./maps/title_map.s ./chars/title_char.s
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

clean:
	rm -rf export
