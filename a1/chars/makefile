ALL = test.s tank.s wall.s title_char.s

all: $(ALL)

test.s: test
	python ./chars.py < $< > $@

tank.s: tank
	python ./chars.py < $< > $@

wall.s: wall
	python ./chars.py < $< > $@

title_char.s: title_char
	python ./chars.py < $< > $@

clean:
	$(RM) *.s
