#
# minimum_objc
#

TARGET     = min_objc
#ARCH_BITS  = 64
#BUILD      = DEBUG
LANG       = OBJC

###############################################################################
#
# NOTE: for most projects should not need to modify anything below
#
###############################################################################

#
# TODO: setup auto-dependency generation
#

CC         = clang
CFLAGS     = -framework Cocoa -x objective-c

#LDFLAGS    =

#
# TODO: automatically output object files into objs/
#

SOURCES    = minWindow.m

#
# TODO: need to change CFLAGS to compile object files
#
OBJECTS    = objs/*.o


#
# TODO: add support for linking external libs and dependencies
#


.PHONY: all clean

all: $(TARGET)
default: $(TARGET)

dirs:
	mkdir -p objs/

$(OBJECTS):
	$(CC) $(SOURCES) $(CFLAGS)
	mv *.o objs/

$(TARGET): dirs $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $(TARGET)

#
# TODO: use make automatic variables
#
#%.o : %.cpp

clean:
	rm -rf objs/*.o $(TARGET)
	rmdir objs

rebuild: clean $(TARGET)

