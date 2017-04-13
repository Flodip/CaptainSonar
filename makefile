CC=ozc
LDFLAGS=
SOURCES=GUI.oz Input.oz Main.oz PlayerManager.oz Player000Random.oz Player000RandomBis.oz Player000Flo1.oz Player000Flo2.oz
OBJECTS=$(SOURCES:.oz=.ozf)
EXECUTABLE=captainSonar

captainSonar: $(SOURCES)
	$(CC) -c $(SOURCES)

.PHONY: clean

clean:
	rm -f $(OBJECTS)