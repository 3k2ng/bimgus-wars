ALL = test.s

all: $(ALL)

test.s: test
	python ./maps.py < $< > $@

clean:
	$(RM) *.s
