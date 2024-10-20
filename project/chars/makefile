ALL = tank.s wall.s title_char.s

all: $(ALL)

tank.s: tank.txt
	python ./chars.py < $< > $@

wall.s: wall.txt
	python ./chars.py < $< > $@

title_char.s: title_char.txt
	python ./chars.py < $< > $@

clean:
	$(RM) *.s
