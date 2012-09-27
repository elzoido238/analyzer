### SET OPTIONAL #defines HERE ###
DEFINITIONS=-DDISPLAY_MODULES

### Variable definitions
SRC=$(PWD)/src
OBJ=$(PWD)/obj
CINT=$(PWD)/cint
DRLIB=$(PWD)/lib

ROOTGLIBS = $(shell root-config --glibs) -lXMLParser -lThread -lTreePlayer
RPATH    += -Wl,-rpath,$(ROOTSYS)/lib -Wl,-rpath,$(PWD)/lib
DYLIB=-shared
FPIC=-fPIC
INCFLAGS=-I$(SRC) -I$(CINT) -I$(USER) $(USER_INCLUDES)
DEBUG=-ggdb -O0 -DDEBUG
CXXFLAGS=$(DEBUG) $(INCFLAGS) -L$(PWD)/lib $(STOCK_BUFFERS) -DBUFFER_TYPE=$(USER_BUFFER_TYPE) $(DEFINITIONS)


ifdef ROOTSYS
ROOTGLIBS = -L$(ROOTSYS)/lib $(shell $(ROOTSYS)/bin/root-config --glibs) -lXMLParser -lThread -lTreePlayer
CXXFLAGS += -L$(ROOTSYS)/lib $(shell $(ROOTSYS)/bin/root-config --cflags) -I$(ROOTSYS)/include
else
ROOTGLIBS = $(shell root-config --glibs --cflags) -lXMLParser -lThread -lTreePlayer
endif

UNAME=$(shell uname)
ifeq ($(UNAME),Darwin)
CXXFLAGS += -DOS_LINUX -DOS_DARWIN
ifdef MIDASSYS
CXXFLAGS += -DMIDASSYS
MIDASLIBS = -L$(MIDASSYS)/darwin/lib -lmidas
INCFLAGS += -I$(MIDASSYS)/include
endif

DYLIB=-dynamiclib -single_module -undefined dynamic_lookup
FPIC=
RPATH=

endif

CXX=g++ -Wall
#CXX=clang++ -I/opt/local/include/ -I/opt/local/include/root

CC=gcc -Wall
#CC=clang -I/opt/local/include/ -I/opt/local/include/root

LINK=$(CXX) $(CXXFLAGS) $(ROOTGLIBS) $(RPATH) $(DEFAULTS) -I/user/gchristian/soft/develop/rootbeer/src -DMIDAS_BUFFERS

CXX+=$(CXXFLAGS) $(RPATH) $(DEF_EXT) $(DEFAULTS) -I/user/gchristian/soft/develop/rootbeer/src -DMIDAS_BUFFERS

CC+=$(CXXFLAGS) $(RPATH) $(DEF_EXT) $(DEFAULTS) -I/user/gchristian/soft/develop/rootbeer/src -DMIDAS_BUFFERS

ROOTCINT=rootcint

#### DRAGON LIBRARY ####
OBJECTS=$(OBJ)/vme/V792.o $(OBJ)/vme/V1190.o $(OBJ)/vme/IO32.o \
$(OBJ)/dragon/Modules.o $(OBJ)/dragon/Dragon.o \
$(OBJ)/dragon/HeavyIon.o \
$(OBJ)/dragon/DSSSD.o $(OBJ)/dragon/IonChamber.o \
$(OBJ)/dragon/MCP.o $(OBJ)/dragon/SurfaceBarrier.o \
$(OBJ)/dragon/Auxillary.o $(OBJ)/dragon/Bgo.o  \
$(OBJ)/tstamp/TStamp.o $(OBJ)/midas/Odb.o $(OBJ)/midas/Xml.o $(OBJ)/midas/Event.o \
$(OBJ)/midas/internal/TMidasFile.o $(OBJ)/midas/internal/TMidasEvent.o \
$(OBJ)/midas/internal/mxml.o $(OBJ)/midas/internal/strlcpy.o \
$(OBJ)/dragon/Head.o

HEADERS=$(SRC)/*/*.hxx $(SRC)/*/*.h $(SRC)/*/*/*.h

### DRAGON LIBRARY ###
all: $(DRLIB)/libDragon.so

lib: $(DRLIB)/libDragon.so

$(DRLIB)/libDragon.so: $(CINT)/DragonDictionary.cxx $(OBJECTS)
	$(LINK) $(DYLIB) $(FPIC) -o $@ $(MIDASLIBS) $(OBJECTS) \
-p $(CINT)/DragonDictionary.cxx  \


### OBJECT FILES ###

$(OBJ)/*/%.o: $(SRC)/*/%.cxx $(CINT)/DragonDictionary.cxx
	$(CXX) $(FPIC) -c \
-o $@ -p $< \

$(OBJ)/*/%.o: $(SRC)/*/%.c $(CINT)/DragonDictionary.cxx
	$(CC) $(FPIC) -c \
-o $@ -p $< \

### CINT DICTIONARY ###
dict: $(CINT)/DragonDictionary.cxx
$(CINT)/DragonDictionary.cxx:  $(HEADERS) $(CINT)/Linkdef.h
	rootcint -f $@ -c $(CXXFLAGS) -p $(HEADERS) $(CINT)/Linkdef.h \


#### REMOVE EVERYTHING GENERATED BY MAKE ####

clean:
	rm -f $(DRLIB)/*.so rootbeer $(CINT)/DragonDictionary.* $(OBJECTS)


#### FOR DOXYGEN ####

doc::
	doxygen doc/Doxyfile


#### FOR UNIT TESTING ####

V792: $(OBJ)/vme/V792.o
V1190: $(OBJ)/vme/V1190.o
IO32: $(OBJ)/vme/IO32.o
Modules: $(OBJ)/dragon/Modules.o
Dragon: $(OBJ)/dragon/Dragon.o
MidasEvent: $(OBJ)/dragon/MidasEvent.o
TMidasEvent: $(OBJ)/midas/TMidasEvent.o
TMidasFile: $(OBJ)/midas/TMidasFile.o
HeavyIon: $(OBJ)/dragon/HeavyIon.o
DSSSD: $(OBJ)/dragon/DSSSD.o
IonChamber: $(OBJ)/dragon/IonChamber.o
MCP: $(OBJ)/dragon/MCP.o
SurfaceBarrier: $(OBJ)/dragon/SurfaceBarrier.o
Auxillary: $(OBJ)/dragon/Auxillary.o
Gamma: $(OBJ)/dragon/gamma/Gamma.o
Head: $(OBJ)/dragon/Head.o
Bgo: $(OBJ)/dragon/Bgo.o
TStamp: $(OBJ)/tstamp/TStamp.o
Odb: $(OBJ)/midas/Odb.o
MidasXML: $(OBJ)/midas/MidasXML.o
mxml: $(OBJ)/midas/mxml.o
strlcpy: $(OBJ)/midas/strlcpy.o
odbtest: $(DRLIB)/libDragon.so
	$(LINK) src/midas/Odb.cxx -o odbtest -DMIDAS_BUFFERS -lDragon -L$(DRLIB) -DODB_TEST

