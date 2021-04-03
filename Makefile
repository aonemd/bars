BUILD_NAME = bars
BUILD_PATH = target/release/bars

default: clean build

build:
	cargo build --release
install: stop
	 cp $(BUILD_PATH) /usr/local/bin
run:
	$(BUILD_PATH)&
stop:
	pkill $(BUILD_NAME) || true
clean:
	rm $(BUILD_PATH)
