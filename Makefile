BUILD_NAME = bars
BUILD_PATH = target/release/bars

default: clean build

build:
	cargo build --release
install: kill
	 cp $(BUILD_PATH) /usr/local/bin
run:
	$(BUILD_PATH)&
kill:
	pkill $(BUILD_NAME) || true
clean:
	rm $(BUILD_PATH)
