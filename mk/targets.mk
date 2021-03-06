default: help

# convenient targets for our supported boards
sitl: HAL_BOARD = HAL_BOARD_SITL
sitl: TOOLCHAIN = NATIVE
sitl: all

sitl-arm: HAL_BOARD = HAL_BOARD_SITL
sitl-arm: TOOLCHAIN = RPI
sitl-arm: all

apm1 apm1-1280 apm2 apm2beta:
	$(error $@ is deprecated on master branch; use master-AVR)

flymaple flymaple-hil:
	$(error $@ is deprecated on master branch; use master-AVR)

f4light: HAL_BOARD = HAL_BOARD_F4LIGHT
f4light: TOOLCHAIN = ARM
f4light: all

qflight: HAL_BOARD = HAL_BOARD_LINUX
qflight: TOOLCHAIN = QFLIGHT
qflight: all

qurt: HAL_BOARD = HAL_BOARD_QURT
qurt: TOOLCHAIN = QURT
qurt: all

# cope with HIL targets
%-hil: EXTRAFLAGS += "-DHIL_MODE=HIL_MODE_SENSORS "
%-hilsensors: EXTRAFLAGS += "-DHIL_MODE=HIL_MODE_SENSORS "

# cope with OBC targets
%-obc: EXTRAFLAGS += "-DOBC_FAILSAFE=ENABLED "

# support debug build
%-debug: OPTFLAGS = -g -O0

# support address sanitiser
%-asan: OPTFLAGS = -g -O0 -fsanitize=address -fno-omit-frame-pointer
%-asan: LDFLAGS += -fsanitize=address

# cope with copter and hil targets
FRAMES = heli
BOARDS = apm1 apm2 apm2beta apm1-1280 px4-v1 px4-v2 px4-v3 px4-v4 px4-v4pro sitl flymaple
BOARDS += vrbrain
BOARDS += vrbrain-v51 vrbrain-v52 vrbrain-v52E vrbrain-v54
BOARDS += vrcore-v10
BOARDS += vrubrain-v51 vrubrain-v52

define frame_template
$(1)-$(2) : EXTRAFLAGS += "-DFRAME_CONFIG=$(shell echo $(2) | tr a-z A-Z | sed s/-/_/g)_FRAME "
$(1)-$(2) : $(1)
$(1)-$(2)-hil : $(1)-$(2)
$(1)-$(2)-debug : $(1)-$(2)
$(1)-$(2)-mavlink1 : $(1)-$(2)
$(1)-$(2)-debug-mavlink1 : $(1)-$(2)
$(1)-$(2)-hilsensors : $(1)-$(2)
$(1)-$(2)-upload : $(1)-$(2)
$(1)-$(2)-upload : $(1)-upload
endef

define board_template
$(1)-hil : $(1)
$(1)-debug : $(1)
$(1)-mavlink1 : $(1)
$(1)-debug-mavlink1 : $(1)-debug
$(1)-asan : $(1)
$(1)-hilsensors : $(1)
endef

USED_BOARDS := $(foreach board,$(BOARDS), $(findstring $(board), $(MAKECMDGOALS)))
USED_FRAMES := $(foreach frame,$(FRAMES), $(findstring $(frame), $(MAKECMDGOALS)))

# generate targets of the form BOARD-FRAME and BOARD-FRAME-HIL
$(foreach board,$(USED_BOARDS),$(eval $(call board_template,$(board))))
$(foreach board,$(USED_BOARDS),$(foreach frame,$(USED_FRAMES),$(eval $(call frame_template,$(board),$(frame)))))

sitl-mount: EXTRAFLAGS += "-DMOUNT=ENABLED"
sitl-mount: sitl

.PHONY: etags
etags:
	cd .. && etags -f ArduCopter/TAGS --lang=c++ $$(git ls-files ArduCopter libraries)
	cd .. && etags -f ArduPlane/TAGS --lang=c++ $$(git ls-files ArduPlane libraries)
	cd .. && etags -f APMrover2/TAGS --lang=c++ $$(git ls-files APMrover2 libraries)

clean:
	@rm -fr $(BUILDROOT)

include $(MK_DIR)/modules.mk
include $(MK_DIR)/uavcangen.mk
include $(MK_DIR)/mavgen.mk
