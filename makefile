CC=ozc
LDFLAGS=
SOURCES=GUI.oz Input.oz Main.oz PlayerManager.oz Player009Random.oz Player009BasicAI.oz
OBJECTS=$(SOURCES:.oz=.ozf)
EXECUTABLE=captainSonar

captainSonar: $(SOURCES)
	$(CC) -c $(SOURCES)

.PHONY: clean

clean:
	rm -f $(OBJECTS)