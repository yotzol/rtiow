SRC_DIR    = src
EXECUTABLE = rtiow
OUTPUT_DIR = output
IMAGE_FILE = $(OUTPUT_DIR)/image.ppm
FLAGS      = -o:aggressive -microarch:native -disable-assert -no-bounds-check

.PHONY: all build run time clean

all: build

build:
	@odin build $(SRC_DIR) $(FLAGS) -out:$(EXECUTABLE)

run: build
	@mkdir -p $(OUTPUT_DIR)
	@./$(EXECUTABLE) > $(IMAGE_FILE)

time: build
	@mkdir -p $(OUTPUT_DIR)
	@time ./$(EXECUTABLE) > $(IMAGE_FILE)

clean:
	@rm -f ./$(EXECUTABLE)
	@rm -rf $(OUTPUT_DIR)
